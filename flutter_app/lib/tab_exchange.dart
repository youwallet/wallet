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
      body: new Container(
        padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
        child: new Column(
          children: <Widget>[
            buildPageTop(context),
            new MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: 300, // 控制按钮宽度
              child: new Text('历史兑换'),
              onPressed: () {
                // ...
                Navigator.pushNamed(context, "token_history");
              },
            ),
          ],
        )
      ),
    );
  }

  // 构建顶部标题栏
  Widget buildAppBar(BuildContext context) {
    return new AppBar(title: const Text('兑换'));
  }

  // 构建页面上半部分区域
  Widget buildPageTop(BuildContext context) {
    return new Row(
      children: <Widget>[
        buildPageToken(context)
      ],
    );
  }

  // 构建页面左侧token区域
  Widget buildPageToken(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Text('Token')
      ],
    );
  }

// 构建左侧token区域
//  Widget buildLeftToken(BuildContext context) {
//    return new ListView(
//      children: <Widget>[
//        new Text('Token')
//      ],
//    );
//  }

}
