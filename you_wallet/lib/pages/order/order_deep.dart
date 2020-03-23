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

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }



  Widget layout(BuildContext context) {
    return DefaultTabController(
        length: 5,
        child: new Scaffold(
          appBar: buildAppBar(context),
          body: Text('ok')
        )
    );

  }

  // 构建app bar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        backgroundColor: Colors.white,
        title: new Text('转账记录')
      //leading: new Icon(Icons.account_balance_wallet),
    );
  }

  // 查询所有记录
  // timestamp 过滤记录用的时间戳
  // 需要优化
  _getHistoryToken(String para) {
    int timestamp = 0;
    int now = DateTime.now().millisecondsSinceEpoch;
    int hour = DateTime.now().hour;
    int minute = DateTime.now().minute;
    int second = DateTime.now().second;
    int today = now - (hour*60*60 + minute*60 + second)*1000;
    if (para == 'three') {
      timestamp = today - 3*24*60*60*1000;
    } else if (para == 'week') {
      timestamp = today - (DateTime.now().weekday - 1)*24*60*60*1000;
    } else if (para == 'month') {
      timestamp = today - (DateTime.now().day - 1)*24*60*60*1000;
    } else if (para == 'today') {
      timestamp = now - (hour*60*60 + minute*60 + second)*1000;
    } else {
      timestamp = 0;
    }
    List arr = List.from(this.list);
    arr.retainWhere((e)=>(int.parse(e['createTime'])>timestamp));

    return new Container(
      padding: new EdgeInsets.all(16.0),
      child: new Column(
          children: arr.reversed.map((item) => _buildToken(item)).toList()
      ),
    );
  }

  Widget _buildToken(item) {
    String date = DateUtil.formatDateMs( int.parse( item['createTime']), format: DataFormats.full);
    return new Container(
        padding: const EdgeInsets.only(top: 12.0,bottom: 12.0), // 四周填充边距32像素
        decoration: new BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.black12,width: 1.0))
        ),
        child: GestureDetector(
          child: new Column(
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text('转账-${item['tokenName']}'),
                  new Text(
                      '-${item['num']} token',
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
                      '${date}',
                      style: new TextStyle(
                          color: Colors.black38
                      )
                  ),
                  new Text(
                      '${item['status']??'转账中'}',
                      style: new TextStyle(
                          color: Colors.deepOrange
                      )
                  )
                ],
              ),
            ],
          ),
          onTap: (){
            print(item);
            Navigator.pushNamed(context, "order_detail", arguments: item);
          },
        )
    );
  }

  void _getHistory() async {
    var sql = SqlUtil.setTable("transfer");
    List arr = await sql.get();
    setState(() {
      this.list = arr;
    });
    print(arr);
//    this.list.forEach((item) async {
//      print('开始查询${item}');
//      if(item['status'] == null && item['txnHash'].length == 66) {
//
//        Map blockHash = await Trade.getTransactionByHash(item['txnHash']);
//        print('进入查询, 查询到blockHash=>${blockHash}');
//        if(blockHash['blockHash'] != null) {
//          await this.updateTransferStatus(item['txnHash']);
//        } else {
//          print('blockHash为null');
//        }
//      } else {
//        print('订单不需要查询，状态不为null或者hash长度不符合格式');
//      }
//    });

  }

  Future<void> updateTransferStatus(String txnHash) async {
    print('开始更新数据表 =》 ${txnHash}');
    var sql = SqlUtil.setTable("transfer");
    int i = await sql.update({'status':'成功'}, 'txnHash', txnHash);
    print('更新完毕=》${i}');
  }

}
