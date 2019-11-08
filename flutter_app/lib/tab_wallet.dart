import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/tokenList.dart';

class TabWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<TabWallet> {

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  // 通过JSON RPC获取以太坊节点版本
  void  _getETHVersionRPC() async{
    var httpClient = new Client();
    var rpc = new JsonRPC('http://localhost:8545',httpClient);
    var version = await rpc.call('web3_clientVersion').then((ret)=>ret.result);
    print('client version => ${version}');
  }

  // 通过http获取以太坊节点版本
  void  _getETHVersion() async{
    var client = Client();
    var payload = {
    "jsonrpc": "2.0",
    "method": "web3_clientVersion",
    "params": [],
    "id": DateTime.now().millisecondsSinceEpoch };
    print(payload);
    var rsp = await client.post(
      'HTTP://0.0.0.0:7545',
      headers:{'Content-Type':'application/json'},
      body: json.encode(payload)
    );
    print('rsp code => ${rsp.statusCode}');
  }

  // 构建页面
  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new ListView(
        children: <Widget>[
          topCard(context),
          listTopBar(context),
          new Container(
            child: new tokenList(),
          )
        ],
      ),
    );
  }

  // 构建AppBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('youwallet'),
        leading: new Icon(Icons.account_balance_wallet),
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
           // _getETHVersionRPC();
          },
        ),
      )
    ];
  }

  // 构建顶部卡片
  Widget topCard(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
        margin: const EdgeInsets.all(16.0),
        decoration: new BoxDecoration(
            borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
            color: Colors.lightBlue
        ),
        width: 200.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             new Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: <Widget>[
                 new Text(
                     '我的钱包',
                     style: new TextStyle(
                         color: Colors.white
                     )
                 ),
                 new IconButton(
                   icon: new Icon(
                       Icons.settings,
                       color: Colors.white
                   ),
                   onPressed: () {
                     // ...
                     Navigator.pushNamed(context, "manage_wallet");
                   },
                 ),
               ],
             ),
            new Text(
                'KDA',
                style: new TextStyle(
                    color: Colors.white
                )
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(''),
                new Text(
                    '￥30000.00',
                    style: new TextStyle(
                      fontSize: 32.0, color: Colors.white
                    )
                ),
              ],
            ),


          ]
        )

    );
  }

  // 构建列表的表头菜单
  Widget listTopBar(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(left: 16.0, right:16.0, top: 0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text('Token'),
          new IconButton(
              icon: new Icon(Icons.add_circle_outline ),
              onPressed: () {
                  Navigator.pushNamed(context, "add_wallet");
              },
          ),
        ],
      ),
    );
  }
}
