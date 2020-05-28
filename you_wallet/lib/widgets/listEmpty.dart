import 'package:flutter/material.dart';


class ListEmpty extends StatelessWidget {

  String text = ""; // 提示文字

  // 构造函数
  ListEmpty({
    Key key,
    this.text = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
         children: <Widget>[
           Padding(
             padding: new EdgeInsets.all(100.0),
             child: Icon(IconData(0xe6a6, fontFamily: 'iconfont'),size: 100.0, color: Colors.black12),
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