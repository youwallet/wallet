import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ChangeNotifier 是 Flutter SDK 中的一个简单的类。
/// 它用于向监听器发送通知。换言之，如果被定义为 ChangeNotifier，
/// 你可以订阅它的状态变化。（这和大家所熟悉的观察者模式相类似）。

/// 在 provider 中，ChangeNotifier 是一种能够封装应用程序状态的方法。
/// 对于特别简单的程序，你可以通过一个 ChangeNotifier 来满足全部需求。
/// 在相对复杂的应用中，由于会有多个模型，所以可能会有多个 ChangeNotifier。
/// (不是必须得把 ChangeNotifier 和 provider 结合起来用，不过它确实是一个特别简单的类)。

class Wallet extends ChangeNotifier {
//  User get user => _profile.user;

  // 构造函数，获取本地保存的token'
  Wallet() {
    this._fetchWallet();
  }

  // 获取缓存的钱包
  Future<List> _fetchWallet() async {
    var sql = SqlUtil.setTable("wallet");
    sql.get().then((res) {
      res.forEach((f){
        this._items.add(f);
      });
      setWallet();
    });

    notifyListeners();
  }

  //设置当前的钱包
  void setWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString("currentAddress");
    this.currentWallet = address??'--';
  }


  /// 所有钱包
  List<Map> _items = [];

  /// 当前钱包
  String currentWallet = "";

  // 获取所有token
  List<Map> get items => _items;

  ///  将 [item] 到token列表中
  void add(Map item) {
    _items.add(item);
    notifyListeners();
  }

// 获取token列表
//  List get(){
//    return _items;
//  }

}