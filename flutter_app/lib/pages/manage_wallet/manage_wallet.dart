import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';

class ManageWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<ManageWallet> {

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: new ListView(
          children: <Widget>[
            walleCard(context),
            new MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: 300, // 控制按钮宽度
              child: new Text('创建钱包'),
              onPressed: () {
                // ...
                Navigator.pushNamed(context, "set_wallet_name");
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('钱包管理'),
      //leading: new Icon(Icons.account_balance_wallet),
    );
  }

  // 构建单个钱包卡片
  Widget walleCard(BuildContext context) {
    return new Card(
        color: Colors.white,//背景色
        child:  new Container(
            padding: const EdgeInsets.all(28.0),
            child: new Row(
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  decoration: new BoxDecoration(
                    border: new Border.all(width: 2.0, color: Colors.black26),
                    borderRadius: new BorderRadius.all(new Radius.circular(20.0)),
                  ),
                  child: new Image.asset(
                    'assets/images/icon.png',
                    height: 40.0,
                    width: 40.0,
                    fit: BoxFit.cover,
                  ),
                ),
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text(
                        'TFT',
                        style: new TextStyle(fontSize: 32.0,color: Colors.black),
                      ),
                      new Text('0xxxxxxxxxxxxxxxxxxxxx'),
                    ],
                  ),
                ),
                new Container(
                    child: new Column(
                      children: <Widget>[
                        new IconButton(
                          icon: new Icon(Icons.settings ),
                          onPressed: () {
                            // ...
                            Navigator.pushNamed(context, "set_wallet");
                          },
                        ),
                      ],
                    )
                )
              ],
            )
        )
    );
  }
}
