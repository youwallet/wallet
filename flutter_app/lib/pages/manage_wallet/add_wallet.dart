import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/menu.dart';

class AddWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<AddWallet> {

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


          ],
        ),
      ),
    );
  }

  // 构建顶部tabBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: new TextField(
        decoration: InputDecoration(
            hintText: "输入合约地址",
            fillColor: Colors.black12,
            contentPadding: new EdgeInsets.all(6.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
            )
        ),
        onChanged: (text) {//内容改变的回调
          print('change $text');
        },
      ),
      actions: this.appBarActions(),
    );
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(Icons.camera_alt ),
          onPressed: () {
            // ...
            //Navigator.pushNamed(context, "login");
            // _getETHVersion();
          },
        ),
      )
    ];
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
                          icon: new Icon(Icons.arrow_forward_ios ),
                          onPressed: () {
                            // ...
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
