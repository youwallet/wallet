import 'package:flutter/material.dart';

class TabWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<TabWallet> {

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new ListView(
        children: <Widget>[
          topCard(context),
          listTopBar(context),
          walleCard(context),
          walleCard(context),
          walleCard(context),
          walleCard(context),
        ],
      ),
    );
  }

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
            color: Colors.lightBlue,
            image: new DecorationImage(
                image: new NetworkImage('http://h.hiphotos.baidu.com/zhidao/wh%3D450%2C600/sign=0d023672312ac65c67506e77cec29e27/9f2f070828381f30dea167bbad014c086e06f06c.jpg'),
                fit: BoxFit.fill
            ),
        ),
        width: 200.0,
        height: 150.0,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            new Text('我的钱包'),
            new Text('KDA'),
            new Text(
                '￥3000000',
                // 因为外层设置了crossAxisAlignment，导致TextAlign失效，思考其他办法
                textAlign: TextAlign.end,
                style: new TextStyle(
                  fontSize: 32.0,
                )
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
                  Navigator.pushNamed(context, "wallet_guide");
              },
          ),

        ],
      ),
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
                  new Text(
                    '14000.00',
                    style: new TextStyle(fontSize: 16.0,color: Color.fromARGB(100, 6, 147, 193)),
                  ),
                  new Text('14000.00'),
                ],
              )

            )
          ],
        )
      )
    );
  }
}
