import 'package:flutter/material.dart';
import 'package:youwallet/global.dart';

class HotToken extends StatelessWidget {
  final onHotTokenCallBack;
  HotToken({Key key, this.onHotTokenCallBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        spacing: 10.0, // 主轴(水平)方向间距
        runSpacing: 4.0, // 纵轴（垂直）方向间距
        children: Global.hotToken.map((item) => buildTagItem(item)).toList());
  }

  // 构建wrap用的小选项
  Widget buildTagItem(item) {
    if (item['network'] == Global.getPrefs('network')) {
      return new Chip(
          avatar: Icon(IconData(item['icon'], fontFamily: 'iconfont'),
              size: 20.0, color: item['color']),
          label: GestureDetector(
            child: new Text(item['name']),
            onTap: () {
              this.onHotTokenCallBack(item);
            },
          ));
    } else {
      return SizedBox();
    }
  }
}
