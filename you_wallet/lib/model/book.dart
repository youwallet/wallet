import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';

/// ChangeNotifier 是 Flutter SDK 中的一个简单的类。
/// 它用于向监听器发送通知。换言之，如果被定义为 ChangeNotifier，
/// 你可以订阅它的状态变化。（这和大家所熟悉的观察者模式相类似）。

/// 在 provider 中，ChangeNotifier 是一种能够封装应用程序状态的方法。
/// 对于特别简单的程序，你可以通过一个 ChangeNotifier 来满足全部需求。
/// 在相对复杂的应用中，由于会有多个模型，所以可能会有多个 ChangeNotifier。
/// (不是必须得把 ChangeNotifier 和 provider 结合起来用，不过它确实是一个特别简单的类)。

class Book extends ChangeNotifier {

  // 构造函数
  Book() {
    this.getBookList();
  }

  List<Map> _items = [];


  // 获取列表
  List<Map> get items => _items;


  /// 从数据库获取当前兑换列表，
  void getBookList() async {
    var sql = SqlUtil.setTable("book");
    List list = await sql.get();
    this._items = list;
    notifyListeners();
  }

  /// 更新订单匹配的交易额到数据库
//  Future<int> updateFilled(Map item, String filled ) async {
//    var sql = SqlUtil.setTable("trade");
//    String status = '进行中';
//    if(double.parse(item['amount']) == double.parse(filled)) {
//      status = '成功';
//    }
//    int i = await sql.update({'filled': filled, 'status': status}, 'txnHash', item['txnHash']);
//    return i;
//  }

  /// 更新联系人备注
  Future updateBookReamrk(Map item) async {
    var sql = SqlUtil.setTable("book");
    int i = await sql.update({'remark': item['remark']}, 'address', item['address']);
    this.getBookList();
  }

  /// 根据id删除指定的交易记录
//  Future<int> deleteTrader(int id) async {
//    var sql = SqlUtil.setTable("trade");
//    int i = await sql.delete('id', id);
//    return i;
//  }

  /// 保存联系人地址和备注到数据库
  Future<int> saveBookAddress(List list) async {
    bool result = items.any((element)=>(element['address']==list[0]));
    if (result) {
      print('当前地址已保存，直接下一步');
      return 0;
    }
    var sql = SqlUtil.setTable("book");
    String sqlInsert ='INSERT INTO book(address, remark) VALUES(?,?)';
    int id = await sql.rawInsert(sqlInsert, list);
    this.getBookList();
    return id;
  }

}