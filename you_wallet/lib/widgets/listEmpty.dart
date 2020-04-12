import 'package:flutter/material.dart';


class ListEmpty extends StatelessWidget {

  String text = ""; // 提示文字

  // 构造函数
  ListEmpty({
    Key key,
    this.text = "暂时没有内容哦～",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: <Widget>[
//          Icon(IconData(0xe6a6, fontFamily: 'iconfont'),size: 50.0),
          Image.asset(
            'images/empty.png',
            width: 200.0,
            height: 200.0,
          ),
          Text(
            this.text,
            style: TextStyle(
                color: Colors.grey
            ),
          )

        ],
      ),
    );

  }

}