import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/widgets/tokenList.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/global.dart';

class AddWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<AddWallet> {

  List tokenArr = new List();
  Map  token = {};
  bool showHotToken = true;

  final globalKey = GlobalKey<ScaffoldState>();


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
      return Wrap(
           spacing: 10.0, // 主轴(水平)方向间距
           runSpacing: 4.0, // 纵轴（垂直）方向间距
           children: Global.hotToken.map((item) => buildTagItem(item)).toList()
      );
    } else {
      return new ListView(
        children: <Widget>[
          buildItem(this.token)
        ],
      );
    }
  }

  // 构建wrap用的小选项
  Widget buildTagItem(item) {
    return new Chip(
      avatar: new Icon(Icons.star),
      label: GestureDetector(
        child: new Text(item['name']),
        onTap: (){
          this.startSearch(item['address']);
        },
      )
    );
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
                    child: Icon(
                        IconData(0xe648, fontFamily: 'iconfont'), size: 50.0,
                        color: Colors.black26)
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
                        new Text('￥${item['rmb'] ?? '-'}'),
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
      title: new TextField(
        decoration: InputDecoration(
            hintText: "输入合约地址",
            fillColor: Colors.black12,
            contentPadding: new EdgeInsets.all(6.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
        ),
        onSubmitted: (text) async {//内容提交(按回车)的回调
            this.startSearch(text);
        },
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
    try {
      Map token = await TokenService.searchToken(text);
      Navigator.pop(context);
      print("搜索结果是${token}");
      if (token.containsKey('name')) {

        setState(() {
          this.token = token;
          this.showHotToken = false;
        });
        saveToken(token);
      } else {
        this.showSnackbar('没有搜索到token');
      }
    } catch (e) {
      Navigator.pop(context);
      if(e.toString().contains('FormatException: Could not parse BigInt')) {
        this.showSnackbar('搜索不到该token');
      } else {
        this.showSnackbar(e.toString());
      }
    }
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(IconData(0xe61d, fontFamily: 'iconfont')),
          onPressed: () {
            this.showSnackbar('还不能扫二维码');
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


