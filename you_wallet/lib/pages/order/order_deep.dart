import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/menu.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:common_utils/common_utils.dart';
import 'package:youwallet/bus.dart';
import 'package:youwallet/service/trade.dart';


class OrderDeep extends StatefulWidget {

  final arguments;

  OrderDeep({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<OrderDeep> {

  List list = [];
  int today = 0;
  int threeDay = 0;
  int weekday = 0;
  int month = 0;
  List deep = [];

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this.getOrderDeep();
  }



  Widget layout(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: new Scaffold(
          appBar: buildAppBar(context),
          body: Column(
              children: this.deep.map((item) => buildItem(item, context)).toList(),
          )
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
  void getOrderDeep() async {
    print(widget.arguments);
    print(widget.arguments['leftToken']);
    String leftToken = widget.arguments['leftToken']['address'];
    String rightToken = widget.arguments['rightToken']['address'];
    // 获取卖单的bq hash
    String hash = await Trade.getOrderQueueInfo(leftToken, rightToken, true);
    String bqHash = hash.replaceFirst('0x', '').substring(0,64);
    print(bqHash);
    String res = await Trade.getOrderDepth(bqHash);
    print(res);
  }

  Widget buildItem(Map item, context) {
    return Text('ok');
  }


}
