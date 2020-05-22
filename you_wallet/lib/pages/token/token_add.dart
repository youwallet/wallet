import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/widgets/tokenList.dart';
import 'package:youwallet/widgets/tokenLogo.dart';
import 'package:youwallet/widgets/hotToken.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/global.dart';
import 'package:youwallet/bus.dart';

class AddToken extends StatefulWidget {

  final arguments;

  AddToken({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<AddToken> {

  List tokenArr = new List();
  Map  token = {};
  bool showHotToken = true;

  final globalKey = GlobalKey<ScaffoldState>();


  //数据初始化
  @override
  void initState() {
    super.initState();
    print('start initState');
    print(widget.arguments);
    // initState在整个生命周期中只执行一次，
    // 所以把初始化异步获取数据的代码放在这里
    // 为什么不放在didChangeDependencies里面呢？因为它会导致这个逻辑被自行两次
    // 这里一定要用Future.delayed把异步逻辑包起来，
    // 因为页面还没有build，没有context，执行执行会发生异常
    if (!widget.arguments.isEmpty) {
      Future.delayed(Duration.zero, (){
        this.startSearch(widget.arguments['address']);
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      key: globalKey,
      appBar: buildAppBar(context),
      body: Builder (
        builder:  (BuildContext context) {
          return new Container(
            padding: const EdgeInsets.all(16.0),
            child: buildPage(this.showHotToken)
          );
        }
      )
    );
  }

  // 根据用户输入，决定是否显示热门token
  Widget buildPage(bool showHotToken) {
    if (showHotToken) {
      return HotToken(
          onHotTokenCallBack: (res) {
            this.startSearch(res['address']);
          }
      );
    } else {
      return ListView(
        children: <Widget>[
          buildItem(this.token)
        ],
      );

    }
  }

  Widget buildItem(Map item){
    if (item.containsKey('name')) {
      return new Card(
        color: Colors.white, //背景色
        child: new Container(
            padding: const EdgeInsets.all(28.0),
            child: new Row(
              children: <Widget>[
                new Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: TokenLogo(address: item['address'])
                ),
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Row(
                        children: <Widget>[
                          new Text(
                            item['name'] ?? '--',
                            style: new TextStyle(
                                fontSize: 32.0, color: Colors.black),
                          ),
                          new IconButton(
                            icon: Icon(IconData(0xe600,
                                fontFamily: 'iconfont')),
                            onPressed: () {
                              print(item);
                              Navigator.pushNamed(
                                  context, "token_info", arguments: {
                                'address': item['address'],
                              });
                            },
                          ),
                        ],
                      ),
                      GestureDetector(
                        child: new Text(
                            TokenService.maskAddress(item['address'])),
                        onTap: () async {
                          print(item['address']);
                        },
                      )

                    ],
                  ),
                ),
                new Container(
                    width: 60.0,
                    child: new Column(
                      children: <Widget>[
                        new Text(
                          item['balance'].toString(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: new TextStyle(fontSize: 16.0,
                              color: Color.fromARGB(100, 6, 147, 193)),
                        ),
                      ],
                    )

                )
              ],
            )
        ),
      );
    } else {
      print('start null');
      return Text('');
    }
  }

  // 构建顶部tabBar
  Widget buildAppBar(BuildContext context) {
    return  new AppBar(
      title: new Container(
        padding: const EdgeInsets.only(left: 8.0),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
          border: new Border.all(width: 1.0, color: Colors.black26),
        ),
        height: 35.0,
        child: new TextField(
          style: TextStyle(fontSize: 18.0),
          decoration: InputDecoration(
            hintText: "输入合约地址",
            fillColor: Colors.black12,
            contentPadding: EdgeInsets.all(2),
            border: OutlineInputBorder(
                borderSide: BorderSide.none
            ),
          ),
          onSubmitted: (text) async {
            //内容提交(按回车)的回调
            this.startSearch(text);
          },
        ),
      ),
      actions: this.appBarActions(),
    );
  }

  void startSearch(String text) async {

    if (!text.startsWith('0x')) {
      this.showSnackbar('合约地址必须0x开头');
      return;
    }

    if (text.length != 42) {
      this.showSnackbar('地址长度不42位');
      return;
    }
    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog( //调用对话框
            text: '搜索中...',
          );
        });
    // 获取token小数点、名字、余额这三个异步操作可以做成一个链式调用
    Future(() async {
      int decimals = await  TokenService.getDecimals(text);
      return Future.value(decimals);
    }).then((res){
      Future.wait([TokenService.getTokenName(text),TokenService.getTokenBalance({'address': text, 'decimals': res})]).then((list) {
        print(list);
        Map token = {};
        token['address'] = text;
        token['wallet'] = Global.getPrefs("currentWallet");
        token['name'] = list[0];
        token['balance'] = list[1];
        token['decimals'] = res;
        token['rmb'] = '';
        token['network'] =  Global.getPrefs("network");
        setState(() {
          this.token = token;
          this.showHotToken = false;
        });
        saveToken(token);
      }).catchError((e){
        this.showSnackbar('没有搜索到token');
      }).whenComplete(() {
        print("名字和余额查询完毕");
      });
    }).catchError((onError){
      print('catchError');
      print(onError);
      this.showSnackbar('当前网络没有搜索到该token');
    }).whenComplete((){
      print("全部完成");
      Navigator.pop(context);
    });
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(IconData(0xe61d, fontFamily: 'iconfont')),
          onPressed: () async {
            String code = await Global.scan(context);
            if (code == null) {
              return;
            }
            List arr = code.split(':');
            if (arr[1] == 'token') {
              Navigator.pushNamed(context, "add_token",arguments: {
                'address': arr[0]
              });
            } else if (arr[1] == 'transfer') {
              Global.setToAddress(arr[0]);
              eventBus.fire(TabChangeEvent(3));
            } else {
              // print(code);
              // 如果模式无法匹配，就跳转扫码结果页面，显示扫码内容
              Navigator.pushNamed(context, "scan",arguments: {
                'res': code,
                'allowCopy': true
              });
            }
          },
        ),
      )
    ];
  }
  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }




  // SHT智能合约地址,测试用
  // 0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef


  // 将搜索到的token填充到页面中
  buildTokenList(arr) {
    return new tokenList(arr: arr);
  }

  void saveToken(Map token) async {
    int id = await Provider.of<Token>(context).add(token);
    print(id);
    if (id == 0) {
      this.showSnackbar('token已经添加，不可以重复添加');
    } else {
      this.showSnackbar('token添加成功');
    }
  }
}


