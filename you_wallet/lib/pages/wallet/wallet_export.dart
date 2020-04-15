import 'package:flutter/material.dart';
import 'package:youwallet/model/wallet.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:youwallet/widgets/inputDialog.dart';
import 'package:youwallet/widgets/customButton.dart';
import 'package:youwallet/util/wallet_crypt.dart';
import 'package:flutter/services.dart';

class WalletExport extends StatefulWidget {

  final arguments;


  WalletExport({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page(arguments: this.arguments);
  }
}

class Page extends State<WalletExport> {

  Map wallet = {
    'name': '',
    'address':''
  };
  TextEditingController _input = TextEditingController();

  Map arguments;
  Page({this.arguments});

  final globalKey = GlobalKey<ScaffoldState>();

  @override // override是重写父类中的函数
  void initState() {
    super.initState();
    print("wallet export init => ${this.arguments}");

  }

  void _setWallet(String address) {
    List arr =  Provider.of<Wallet>(context).items;
    arr.forEach((f){
      if (f['address'] == address) {
        setState(() {
          this.wallet = f;
        });
      }
    });
  }

  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._setWallet(this.arguments['address']);
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    String name = this.wallet['name'].length > 0 ? this.wallet['name']:'Account${this.wallet['id']}';
    return new Scaffold(
      key: globalKey,
      appBar: buildAppBar(context),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
            children: <Widget>[
               new Card(
                  color: Colors.white, //背景色
                  child: new Container(
                      padding: const EdgeInsets.all(28.0),
                      child: new Row(
                        children: <Widget>[
                          new Expanded(
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                new Text(
                                  name,
                                  style: new TextStyle(fontSize: 32.0, color: Colors.black),
                                ),
                                new Text(this.wallet['address']),
                              ],
                            ),
                          ),
                          new Container(
                            child: new IconButton(
                              icon: new Icon(Icons.keyboard_arrow_right),
                              onPressed: () {
//                                print(this.wallet);
                                // 修改钱包名字
                                this.updateWalletName();
                              },
                            ),

                          )
                        ],
                      )
                  )
              ),
              ListTile(
                title: Text('导出助记词'),
                trailing: new Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).pushNamed('getPassword').then((data) async {
                    final mnemonic = await WalletCrypt(data, this.wallet['mnemonic']).decrypt();
                    print(mnemonic);
                    if (mnemonic.split(" ").length == 12) {
                      Clipboard.setData(new ClipboardData(text: mnemonic));
                      this.showSnackbar('助记词已复制');
                    } else {
                      this.showSnackbar('助记词导出错误，请核对密码');
                    }
                  });
                },
              ),
              ListTile(
                title: Text('导出私钥'),
                trailing: new Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  Navigator.of(context).pushNamed('getPassword').then((pwd) async{
                     final key = await WalletCrypt(pwd,this.wallet['privateKey']).decrypt();
                     if (key.length != 64){
                       this.showSnackbar('导出失败，请核对密码');
                     } else {
                       ClipboardData data = new ClipboardData(text:key);
                       Clipboard.setData(data);
                       this.showSnackbar('已复制');
                     }
                  });

                },
              ),
              Container(
                  padding: const EdgeInsets.all(80.0),
                  child: new CustomButton(
                    content: '删除钱包',
                    type:"danger",
                    onSuccessChooseEvent:(res){
                      this.delWallet();
                    }
                  )
              )
            ],
        )

      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('钱包设置'),
//      actions: this.appBarActions(),
      //leading: new Icon(Icons.account_balance_wallet),
    );
  }

  void delWallet(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '确定删除钱包?',
              content: '',
              onCancelChooseEvent: () {
                Navigator.pop(context);
                // this.showSnackbar('取消');
              },
              onSuccessChooseEvent: () async {
                 await Provider.of<Wallet>(context).remove(this.wallet);
                // Navigator.pop(context); //关闭对话框

                // 每次删除钱包后，判断当前还有多少个钱包
                // 如果钱包没有钱包，则自动跳转新建钱包引导页
                if (Provider.of<Wallet>(context).items.length == 0) {
                  // Navigator.pushReplacementNamed(context, 'wallet_guide');
                  // 销毁当前路由栈，回退到钱包列表页面
                  Navigator.of(context).pushNamedAndRemoveUntil('wallet_guide', (Route<dynamic> route) => false);
                } else {
                  Navigator.of(context).pop('back');
                }
              });
    }).then((val) {
      // 如果你点击确定删除了钱包，这里继续回退
      if (val == 'back') {
        Navigator.pop(context);
      }
    });
  }

  // 更新钱包名字
  updateWalletName(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return InputDialog(
              title: '请输入钱包名字',
              hintText: '请输入',
              controller: this._input,
              onCancelChooseEvent: () {
                Navigator.pop(context);
              },
              onSuccessChooseEvent: () {
                this.clickSuccess();
              });
        });
  }

  void clickSuccess() async {
    Provider.of<Wallet>(context).updateName(this.wallet['address'], this._input.text);
    Navigator.pop(context);
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(Icons.add_circle_outline ),
          onPressed: () {
            Navigator.pushNamed(context, "wallet_guide");
          },
        ),
      )
    ];
  }


  Widget walletCard(item) {
    print(item);
    String name = item['name'].length > 0 ? item['name']:'Account${item['id']}';
    return new Card(
        color: Colors.white, //背景色
        child: new Container(
            padding: const EdgeInsets.all(28.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text(
                        name,
                        style: new TextStyle(fontSize: 32.0, color: Colors.black),
                      ),
                      new Text(item['address']),
                    ],
                  ),
                ),
                new Container(
                  child: new IconButton(
                    icon: new Icon(Icons.keyboard_arrow_right),
                    onPressed: () {
                      print(item);
//                      Navigator.pushNamed(context, "token_info",arguments:{
//                        'address': item['address'],
//                      });
                    },
                  ),

                )
              ],
            )
        )
    );


  }
}
