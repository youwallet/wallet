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

class Token extends ChangeNotifier {
//  User get user => _profile.user;

  // 构造函数，获取本地保存的token'
  Token() {
    this._fetchToken();
  }

  Future<List> _fetchToken() async {
    var sql = SqlUtil.setTable("tokens");
    sql.get().then((res) {
      res.forEach((f){
        this._items.add(f);
      });
    });
    notifyListeners();
  }

  // APP是否登录(如果有用户信息，则证明登录过)
//  bool get isLogin => user != null;

  //用户信息发生变化，更新用户信息并通知依赖它的子孙Widgets更新
//  set user(User user) {
//    if (user?.login != _profile.user?.login) {
//      _profile.lastLogin = _profile.user?.login;
//      _profile.user = user;
//      notifyListeners();
//    }
//  }

  ///
  List<Map> _items = [];


  // 获取所有token
  List<Map> get items => _items;

  ///  保存一个token，注意token重复保存
  Future<int> add(Map token) async {

    var sql = SqlUtil.setTable("tokens");
    var map = {'address': token['address'],'wallet': token['wallet'],'network': token['network']};
    List json = await sql.query(conditions: map);

    if (json.isEmpty) {
      _items.add(token);

      String sql_insert ='INSERT INTO tokens(address, wallet, name, decimals, balance, rmb, network) VALUES(?, ?, ?, ?, ?, ?, ?)';
      List list = [token['address'], token['wallet'], token['name'], token['decimals'], token['balance'],token['rmb'], token['network']];
      int id = await sql.rawInsert(sql_insert, list);
      print(id);

      notifyListeners();
      return id;

    } else {
      print('token添加重复');
      return 0;
    }
  }

  /// 移除一个token
  void remove(Map item) {
    _items.remove(item);
    var sql = SqlUtil.setTable("tokens");
    sql.delete('id', item['id']).then((result) {
      print("remove =》 ${result}");
    });
    notifyListeners();
  }

  /// 在授权表中增加一份记录
  Future<int> approveAdd(Map item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var sql = SqlUtil.setTable("approve");
    String sqlInsert ='INSERT INTO approve(tokenAddress, walletAddress) VALUES(?, ?)';
    String walletAddress = prefs.getString("currentWallet");
    List list = [item['address'], walletAddress];
    int id = await sql.rawInsert(sqlInsert, list);
    return id;
  }

}