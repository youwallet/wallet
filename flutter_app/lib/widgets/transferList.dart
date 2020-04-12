import 'package:flutter/material.dart';
import 'package:common_utils/common_utils.dart';

class transferList extends StatelessWidget {

  final color = Color.fromARGB(255, 255, 170, 71);
  List arr = [];

  transferList({Key key, this.arr }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(bottom: 12.0), // 四周填充边距32像素
        child: new Column(
          children: this.arr.map((item) => buildItem(item, context)).toList()
        )
    );
  }


  Widget buildItem(item, context) {
    String date = DateUtil.formatDateMs( int.parse( item['createTime']), format: DataFormats.full);
    double singlePrice = int.parse(item['price']) / int.parse(item['amount']);
    return new Container(
        padding: const EdgeInsets.all(10.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
           border: Border(bottom: BorderSide(color: Colors.black26,width: 1.0)),
        ),
        child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Text(
                      '${item['orderType']}',
                      style: new TextStyle(
                          color: item['orderType']== '买入' ? Colors.green : Colors.deepOrange
                      )
                  ),
                  new Text('   ${date}'),
                ],
              ),
              new Text(
                  '转账中',
                  style: new TextStyle(
                      color: Colors.deepOrange
                  )
              )
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(
                  '${item['price']} (${item['baseTokenName']})',
              ),
              new Text(
                  '${item['amount']}/${singlePrice}(${item['tokenName']})',
                  style: new TextStyle(
                      color: Colors.lightBlue
                  )
              )
            ],
          ),

        ],
      )
    );

  }

}