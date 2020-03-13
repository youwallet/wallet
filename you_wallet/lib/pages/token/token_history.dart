import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/menu.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:common_utils/common_utils.dart';
import 'package:youwallet/bus.dart';
import 'package:youwallet/service/trade.dart';

class TokenHistory extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<TokenHistory> {

  List list = [];

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    this._getHistory();
  }

  Widget layout(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: new Scaffold(
        appBar: buildAppBar(context),
        body: new TabBarView(
          children: [
            _getHistoryToken(1),
            _getHistoryToken(2),
            _getHistoryToken(3),
            _getHistoryToken(4),
            _getHistoryToken(5)
          ],
        ),
        bottomNavigationBar: new BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: new SizedBox(
                  height: 50.0,
                  child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0))
                    ),
                    elevation: 0,
                    icon: Icon(IconData(0xe6eb, fontFamily: 'iconfont')),
                    label: Text(
                        "兑换",
                    ),
                    onPressed: (){
                      eventBus.fire(TabChangeEvent(1));
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: new SizedBox(
                  height: 50.0,
                  child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0))
                    ),
                    elevation: 0.0,
                    icon: Icon(IconData(0xe624, fontFamily: 'iconfont'),color: Colors.white),
                    color: Colors.blue,
                    highlightColor: Colors.blue,
                    splashColor: Colors.blue,
                    label: Text(
                        "收款",
                        style: new TextStyle(
                            color: Colors.white
                        )
                    ),
                    onPressed: () {
                      eventBus.fire(TabChangeEvent(2));
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                flex: 1,
              ),
              Expanded(
                child: new SizedBox(
                  height: 50.0,
                  child: RaisedButton.icon(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(0))
                    ),
                    elevation: 0,
                    icon: Icon(IconData(0xe616, fontFamily: 'iconfont'),color: Colors.white),
                    label: Text(
                        "转账",
                        style: new TextStyle(
                            color: Colors.white
                        )
                    ),
                    color: Colors.green,
                    onPressed: (){
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                flex: 1,
              ),
            ],
          ),
        ),
      )
    );

  }

  // 构建app bar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        backgroundColor: Colors.white,
        title: new Text('转账记录'),
        bottom: new TabBar(
          tabs: [
            new Tab(text: '日期'),
            new Tab(text: '今天'),
            new Tab(text: '三天'),
            new Tab(text: '本周'),
            new Tab(text: '本月')
          ],
        )
      //leading: new Icon(Icons.account_balance_wallet),
    );
  }

  // 构建tabbar
  _buildBar() {
    return Container(
        decoration: new BoxDecoration(
           border: Border(bottom: BorderSide(color: Colors.black12,width: 1.0))
        ),
        padding: new EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBarItem('日期'),
            new Text('今日'),
            new Text('三天'),
            new Text('本周'),
            new Text('本月'),
          ],
        )
    );
  }

  _buildBarItem(str) {
    return Container(
      child: GestureDetector(
        onTap: (){
          debugPrint("onTap");
        },
        child: Text(str),
      ),
    );
  }

  // 查询所有记录
  _getHistoryToken(int i) {
    return new Container(
      padding: new EdgeInsets.all(16.0),
      child: new Column(
        children: this.list.reversed.map((item) => _buildToken(item)).toList()
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
    this.list.forEach((item) async {
      print('开始查询${item}');
      if(item['status'] == null && item['txnHash'].length == 66) {

        Map blockHash = await Trade.getTransactionByHash(item['txnHash']);
        print('进入查询, 查询到blockHash=>${blockHash}');
        if(blockHash['blockHash'] != null) {
          await this.updateTransferStatus(item['txnHash']);
        } else {
          print('blockHash为null');
        }
      } else {
        print('订单不需要查询，状态不为null或者hash长度不符合格式');
      }
    });

  }

  Future<void> updateTransferStatus(String txnHash) async {
    print('开始更新数据表 =》 ${txnHash}');
    var sql = SqlUtil.setTable("transfer");
    int i = await sql.update({'status':'成功'}, 'txnHash', txnHash);
    print('更新完毕=》${i}');
  }

}
