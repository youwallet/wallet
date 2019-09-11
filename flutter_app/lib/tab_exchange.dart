import 'package:flutter/material.dart';

class TabExchange extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<TabExchange> {
  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new ListView(
        children: [
          walleCard(context),
          walleCard(context),
          walleCard(context),
          walleCard(context),
          walleCard(context),
        ],
      ),
    );
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(title: const Text('兑换'));
  }

  // 构建单个钱包卡片
  Widget walleCard(BuildContext context) {
    return new Card(
      elevation: 4.0,//阴影
      color: Colors.grey,//背景色
      child: new Container(
        color: Colors.lightBlue,
        width: 200.0,
        height: 200.0,
      ),
    );
  }
}
