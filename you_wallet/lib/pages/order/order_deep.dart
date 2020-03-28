import 'package:flutter/material.dart';
import 'package:youwallet/service/trade.dart';
import 'dart:math';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/global.dart';
import 'package:decimal/decimal.dart';

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
              return new ListView(
                children: <Widget>[
                  Column(
                    children: response.map((item) => buildItem(item, context)).toList(),
                  )
                ],
              );
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

    String bqsq = await Trade.getBQHash(leftToken, rightToken);
//    print(obj);
    // 获取卖单的bq hash
    // String hash = await Trade.getOrderQueueInfo(leftToken, rightToken, true);
    // String bqHash = hash.replaceFirst('0x', '').substring(0,64);
  /* 订单深度条目
   * baseTokenAmount, quoteTokenAmount: 由这两个算出价格 = quoteTokenAmount / baseTokenAmount
   * amount: base-token 数量
   * is_sell: true for sell, false for buy
   *
   * struct OrderItem
    {
        uint256 baseTokenAmount;
        uint256 quoteTokenAmount;
        uint256 amount;
        bool is_sell;
    }
   **/
    String res = await Trade.getOrderDepth(bqsq);
    String data = res.replaceFirst('0x', '');
    int len = data.length;
    int n = 4; // orderItem由几个字段构成
    int index = (len/256).toInt();
    int i = 0;
    List arr = [];
    while( i<index) {
      String item = data.substring(i*n*64, i*n*64 + n*64);
      BigInt baseTokenAmount  = BigInt.parse(item.substring(0, 64), radix: 16);
      BigInt quoteTokenAmount = BigInt.parse(item.substring(64, 128), radix: 16);
      double amount = BigInt.parse(item.substring(128, 192), radix: 16)/BigInt.from(pow(10, 18));
      bool is_sell = BigInt.parse(item.substring(192), radix: 16) == BigInt.from(0)? false:true;
      String price = (quoteTokenAmount/baseTokenAmount).toStringAsFixed(Global.priceDecimal);
      print(baseTokenAmount);
      print(quoteTokenAmount);
      print(amount);
      print(is_sell);

      arr.add({
        'price': price,
        'amount': amount.toString(),
        'is_sell': is_sell
      });
      i = i+1;
    }
    return arr;
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
          new Icon(
              Icons.close,
              size: 20.0,
              color: item['is_sell'] ? Colors.deepOrange : Colors.green
          ),
          new Text(item['amount']),
        ],
      ),
    );
  }


}
