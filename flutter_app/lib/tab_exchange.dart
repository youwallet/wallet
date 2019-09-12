import 'package:flutter/material.dart';
import 'package:youwallet/widgets/rating.dart';
import 'package:youwallet/widgets/menu.dart';

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
          Menu(['导出助记词','导出私钥'])
        ],
      ),
    );
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(title: const Text('兑换'));
  }

}
