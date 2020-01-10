import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youwallet/bus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/model/wallet.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:youwallet/widgets/inputDialog.dart';

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
                  if (this.wallet['mnemonic'].length > 0) {
                    Navigator.pushNamed(context, "wallet_mnemonic",arguments:{
                      'mnemonic': this.wallet['mnemonic'],
                    });
                  } else {
                    this.showSnackbar('私钥导入的钱包没有助记词');
                  }
                },
              ),
              ListTile(
                title: Text('导出私钥'),
                trailing: new Icon(Icons.keyboard_arrow_right),
                onTap: () {
                  // 跳转load_wallet页面，然后通过address查询对应的key
                  Navigator.pushNamed(context, "load_wallet",arguments:{
                    'address': this.wallet['address'],
                    'initialIndex': 1
                  });
                },
              ),
              new Container(
                padding: const EdgeInsets.all(40.0),
                child: new RaisedButton(
                  child: Text("删除钱包"),
                  elevation: 0, // 按钮阴影高度
                  color: Colors.red,
                  textColor: Colors.white,
                  onPressed: () {
                    this.delWallet();
                  },
                ),
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
//                this.showSnackbar('取消');
              },
              onSuccessChooseEvent: () {
                print(this.arguments);
                this.showSnackbar('点击了确认，先不删除');
                Navigator.pop(context);
              });
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
                print(this._input.text);

                Navigator.pop(context);
              });
        });
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
