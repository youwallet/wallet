import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart';

class transferList extends StatelessWidget {

  final color = Color.fromARGB(255, 255, 170, 71);
  List arr = [];

  transferList({Key key, this.arr }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(this.arr);
    return new Container(
        padding: const EdgeInsets.only(top: 12.0,bottom: 12.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12,width: 1.0))
        ),
        child: new Column(
          children: this.arr.map((item) => buildItem(item, context)).toList()
        )
    );
  }


  Widget buildItem(item, context) {
    String date = DateUtil.formatDateMs( int.parse( item['createTime']), format: DataFormats.full);
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Text('${item['orderType']}-fromtoken'),
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
                date,
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
    );
  }

}