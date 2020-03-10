import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share/share.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' ;
import 'package:youwallet/service/trade.dart';

class OrderDetail extends StatefulWidget {

  final arguments;

  OrderDetail({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page(arguments: this.arguments);
  }
}

// 收款tab页
class Page extends State<OrderDetail> {

  Page({this.arguments});

  Map arguments;
  final globalKey = GlobalKey<ScaffoldState>();
  Map detail;

  @override // override是重写父类中的函数
  void initState()  {
    print(this.arguments);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }


  Widget layout(BuildContext context) {
    return new Scaffold(
      key: globalKey,
      appBar: buildAppBar(context),
      body: FutureBuilder(
        future: this.getDetail(),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          /*表示数据成功返回*/
          if (snapshot.hasData) {
            Map response = snapshot.data;
            return buildPage(response);
          } else {
            return LoadingWidget();
          }
        },
      )
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('详情'),
//      actions: this.appBarActions(),
    );
  }

  Widget LoadingWidget() {
    return Text('加载中。。。。。。。。。。');
  }

  Widget buildPage(Map item) {
    return new Container(
      alignment: Alignment.topCenter,
      child: new Container(
        padding: const EdgeInsets.only(top: 40.0),
        child: new Column(
          children: <Widget>[
            Icon(IconData(0xe617, fontFamily: 'iconfont'),size: 100.0, color: Colors.green),
            new Text(
                '交易成功',
                style: new TextStyle(
                    fontSize: 30.0,
                    color: Colors.black38
                )
            ),
            new Column(
              children: <Widget>[
                new Row(children: <Widget>[
                  buildName('矿工费用'),
                  Text(item['gas'])
                ]),
                new Row(children: <Widget>[
                  buildName('钱包地址'),
                  Text(item['from'])
                ]),
                new Row(children: <Widget>[
                  buildName('合约地址'),
                  Text(item['to'])
                ]),
                new Row(children: <Widget>[
                  buildName('交易号'),
                  Text(item['gas'])
                ]),
                new Row(children: <Widget>[
                  buildName('区块'),
                  Text(item['nonce'])
                ]),
              ],
            ),
              new Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 20.0), // 四周填充边距32像素
                  color: Color(0xFFFFFFFF),
                  child: new Column(
                    children: <Widget>[
                      QrImage(
                        backgroundColor:Colors.white,
                        data: item['hash'],
                        size: 100.0,
                      ),
                    ],
                  )

              ),
          ],
        ),
      ),

    );
  }

  Widget buildName(String val) {
    return new Container(
      width: 100.0,
      height: 40.0,
      alignment: Alignment.centerRight,
      child: Text(
          val + ':',
          style: TextStyle(
              color: Colors.black38,
              fontSize: 18.0
          ),
      ),
    );
  }

  void  _copyAddress() {
    ClipboardData data = new ClipboardData(text:this.arguments['address']);
    Clipboard.setData(data);
    this.showSnackbar('复制成功');
  }

  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  Future<Map> getDetail() async {
    Map response = await Trade.getTransactionByHash( this.arguments['hash']);
    setState(() {
      detail = response;
    });
    return response;
  }

}
