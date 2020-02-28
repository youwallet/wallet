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
  /// 所有钱包
  List<Map> _items = [];


  // 获取钱包列表
  List<Map> get items => _items;


  /// 从数据库获取当前兑换列表，
  Future<List> getTraderList() async {
    var sql = SqlUtil.setTable("trade");
    List list = await sql.get();
    return list;
  }

  // 更新订单匹配的交易额到数据库
  Future<int> updateFilled(Map item, String filled ) async {
    var sql = SqlUtil.setTable("trade");
    String status = '转账中';
    if(double.parse(item['amount']) == double.parse(filled)) {
      status = '成功';
    }
//    print(status);
//    print(item['amount']);
//    print(filled);
    int i = await sql.update({'filled': filled, 'status': status}, 'txnHash', item['txnHash']);
    return i;
  }

}