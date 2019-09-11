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
    return new AppBar(title: const Text('首页'));
  }

  // 构建顶部卡片
  Widget topCard(BuildContext context) {
    return new Card(
      elevation: 4.0,//阴影
      color: Colors.grey,//背景色
      child: new Container(
        color: Colors.lightBlue,
        width: 200.0,
        height: 150.0,
      ),
    );
  }

  // 构建列表的表头菜单
  Widget listTopBar(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(8.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text('Token'),
          new Text('+'),
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
