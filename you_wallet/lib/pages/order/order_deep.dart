import 'package:flutter/material.dart';
import 'package:youwallet/service/trade.dart';
import 'dart:math';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/global.dart';
import 'package:decimal/decimal.dart';
import 'package:youwallet/util/number_format.dart';
import 'package:youwallet/widgets/listEmpty.dart';

class OrderDeep extends StatefulWidget {

  final arguments;

  OrderDeep({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<OrderDeep> {

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
        appBar: buildAppBar(context),
        body: FutureBuilder(
          future: this.getOrderDeep(),
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            /*表示数据成功返回*/
            if (snapshot.hasData) {
              List response = snapshot.data;
              if(response.length == 0) {
                return ListEmpty(
                  text: '还没有交易'
                );
              } else {
                return new ListView(
                  children: <Widget>[
                    Column(
                      children: response.map((item) => buildItem(item, context)).toList(),
                    )
                  ],
                );
              }
            } else {
              return LoadingDialog();
            }
          },
        )
    );
  }


  // 构建app bar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        backgroundColor: Colors.white,
        title: new Text('交易深度')
    );
  }

  // 获取所有的交易深度
  // 先用两个token获取到唯一的bq hash
  // 注意这里token的顺序，BTA-BTC和BTC-BTA的bq hash是不一样的
  // 同一个队列，卖单和买单的bq hash是一样的
  /* 订单深度条目
   * baseTokenAmount, quoteTokenAmount: 由这两个算出价格 = quoteTokenAmount / baseTokenAmount
   * amount: base-token 数量
   **/
  //  struct OrderItem
  //  {
  //    uint256 baseTokenAmount;
  //    uint256 quoteTokenAmount;
  //    uint256 amount;
  //  }

  Future<List> getOrderDeep() async {
    String leftToken = widget.arguments['leftToken']['address'];
    String rightToken = widget.arguments['rightToken']['address'];
    try {
      List arr = await Trade.getOrderDepth(leftToken, rightToken);
      print(arr);
      return arr;
    } catch (e) {
      this.showSnackBar(e.toString());
      return [];
    }
  }

  void showSnackBar(String text) {
    final snackBar = new SnackBar(content: new Text(text));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  Widget buildItem(Map item, context) {
    return new Container(
      color: Colors.black12, //16进制颜色
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(top: 10.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          new Text(
              item['price'],
              style: TextStyle(color: item['is_sell'] ? Colors.deepOrange : Colors.green)
          ),
//          new Icon(
//              Icons.close,
//              size: 20.0,
//              color: item['is_sell'] ? Colors.deepOrange : Colors.green
//          ),
          new Text(item['amount']),
        ],
      ),
    );
  }


}
