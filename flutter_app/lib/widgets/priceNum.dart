import 'package:flutter/material.dart';

class priceNum extends StatelessWidget {
  final double size;
  final double fontSize;
  final color = Color.fromARGB(255, 255, 170, 71);

  priceNum({Key key, this.size = 18.0, this.fontSize = 13.0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> DataList = [];
    for(var i = 0; i < 6; i++) {
      DataList.add(new Container(
        color: Colors.black12, //16进制颜色
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.only(top: 10.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Text('0.123456'),
            new Icon(
              Icons.close,
              size: 20.0,
            ),
            new Text('0.123456'),
          ],
        ),
      ));
    }
    return Container(
      child: Column(
        children: DataList,
      ),
    );
  }
}