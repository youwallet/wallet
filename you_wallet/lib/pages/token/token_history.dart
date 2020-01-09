import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:youwallet/widgets/menu.dart';
import 'package:youwallet/db/sql_util.dart';

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
            _getHistoryToken(),
            _getHistoryToken(),
            _getHistoryToken(),
            _getHistoryToken(),
            _getHistoryToken()
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
                    icon: Icon(Icons.search),
                    label: Text("兑换"),
                    onPressed: (){
                      Navigator.pushNamed(context, "tab_exchange");
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
                    icon: Icon(Icons.search),
                    color: Colors.blue,
                    highlightColor: Colors.blue,
                    splashColor: Colors.blue,
                    label: Text("收款"),
                    onPressed: () {
                      Navigator.pushNamed(context, "tab_transfer");
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
                    icon: Icon(Icons.search),
                    label: Text("转账"),
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

  _getHistoryToken() {
    return new Container(
      padding: new EdgeInsets.all(16.0),
      child: new Column(
        children: this.list.map((item) => _buildToken(item)).toList()
      ),
    );
  }

  Widget _buildToken(item) {
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
                new Text('收款-${item['fromAddress']}'),
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

  @override
  _onClick() {
    debugPrint("onTap");
  }

  void _getHistory() async {
    var sql = SqlUtil.setTable("transfer");
    List arr = await sql.get();
    print(arr);
    setState(() {
      this.list = arr;
    });
  }

//  void _onTabChanged() {
//
//  }

}
