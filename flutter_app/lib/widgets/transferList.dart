import 'package:flutter/material.dart';

class transferList extends StatelessWidget {
  final double size;
  final double fontSize;
  final color = Color.fromARGB(255, 255, 170, 71);

  transferList({Key key, this.size = 18.0, this.fontSize = 13.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(top: 12.0,bottom: 12.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12,width: 1.0))
        ),
        child: new Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text('收款-fromtoken'),
                new Text(
                    '+0.123 token',
                    style: new TextStyle(
                        color: Colors.lightBlue
                    )
                )
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                    '2019-11-11 10:11:12',
                    style: new TextStyle(
                        color: Colors.black38
                    )
                ),
                new Text(
                    '转账中',
                    style: new TextStyle(
                        color: Colors.deepOrange
                    )
                )
              ],
            ),
          ],
        )
    );
  }


}