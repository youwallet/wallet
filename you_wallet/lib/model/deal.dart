import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';

/// ChangeNotifier 是 Flutter SDK 中的一个简单的类。
/// 它用于向监听器发送通知。换言之，如果被定义为 ChangeNotifier，
/// 你可以订阅它的状态变化。（这和大家所熟悉的观察者模式相类似）。

/// 在 provider 中，ChangeNotifier 是一种能够封装应用程序状态的方法。
/// 对于特别简单的程序，你可以通过一个 ChangeNotifier 来满足全部需求。
/// 在相对复杂的应用中，由于会有多个模型，所以可能会有多个 ChangeNotifier。
/// (不是必须得把 ChangeNotifier 和 provider 结合起来用，不过它确实是一个特别简单的类)。

class Deal extends ChangeNotifier {
//  User get user => _profile.user;

  // 构造函数，获取本地保存的token'
  List<Map> _items = [];

  // 获取钱包列表
  List<Map> get items => _items;

  /// 从数据库获取当前兑换列表，
  Future<List> getTraderList() async {
    var sql = SqlUtil.setTable("trade");
    List list = await sql.get();
    return list;
  }

  /// 更新订单匹配的交易额到数据库
  Future<int> updateFilled(Map item, String filled) async {
    var sql = SqlUtil.setTable("trade");
    print('update sql: ${filled}');
    int i = await sql.update({'filled': filled}, 'txnHash', item['txnHash']);
    print(i);
    return i;
  }

  /// 更新订单状态
  Future<int> updateOrderStatus(String txnHash, String status) async {
    var sql = SqlUtil.setTable("trade");
    int i = await sql.update({'status': status}, 'txnHash', txnHash);
    return i;
  }

  /// 根据id删除指定的交易记录
  Future<int> deleteTrader(int id) async {
    var sql = SqlUtil.setTable("trade");
    int i = await sql.delete('id', id);
    return i;
  }

  /// 保存兑换的订单到数据库
  Future<void> saveTrader(List list) async {
    var sql = SqlUtil.setTable("trade");
    String sqlInsert =
        'INSERT INTO trade(orderType, price, amount,filled, token,tokenName, baseToken,baseTokenname, txnHash, odHash, bqHash, sqHash,createtime,status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
    int id = await sql.rawInsert(sqlInsert, list);
    print("db trade id => ${id}");
    return id;
  }
}
