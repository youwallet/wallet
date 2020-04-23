import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/global.dart';
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

  /// 获取token，只获取当前网络下的token
  void _fetchToken() async {
    this._items = [];
    var sql = SqlUtil.setTable("tokens");
    List arr = await sql.get();
    String network = Global.getPrefs('network');
    arr.retainWhere((element)=>(element['network'] == network));
    this._items = arr;
    notifyListeners();
  }

  /// 供外部调用刷新token列表
  Future<void> refreshTokenList() async {
    this._fetchToken();
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


  /// 获取所有token
  List<Map> get items => _items;

  ///  保存一个token，注意token重复保存，
  ///  用户可能在不同的网络下添加同一种token
  Future<int> add(Map token) async {
    var sql = SqlUtil.setTable("tokens");
    var map = {'address': token['address'],'wallet': token['wallet'],'network': token['network']};
    List json = await sql.query(conditions: map);
    if (json.isEmpty) {
      String sql_insert ='INSERT INTO tokens(address, wallet, name, decimals, balance, rmb, network) VALUES(?, ?, ?, ?, ?, ?, ?)';
      List list = [token['address'], token['wallet'], token['name'], token['decimals'], token['balance'],token['rmb'], token['network']];
      int id = await sql.rawInsert(sql_insert, list);
      this._fetchToken();
      return id;
    } else {
      print('token添加重复');
      return 0;
    }
  }

  /// 移除一个token
  Future<int> remove(Map item) async {
    _items.remove(item);
    var sql = SqlUtil.setTable("tokens");
    int id = await sql.delete('id', item['id']);
    this._fetchToken();
  }

  /// 更新指定的token余额
  /// 余额变动话，主动重新_fetchToken
  /// 首页的token列表余额自动更新
  Future<void> updateTokenBalance(Map item,String balance) async {
    var sql = SqlUtil.setTable("tokens");
    int i = await sql.update({'balance': balance}, 'id', item['id']);
    print('updateTokenBalance => ${i}');
    this._fetchToken();
  }

  /// 在授权表中增加一份记录
  Future<int> approveAdd(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var sql = SqlUtil.setTable("approve");
    String sqlInsert ='INSERT INTO approve(tokenAddress, walletAddress) VALUES(?, ?)';
    String walletAddress = prefs.getString("currentWallet");
    List list = [address, walletAddress];
    int id = await sql.rawInsert(sqlInsert, list);
    return id;
  }

  /// 在授权表中查询该token是否被授权
  Future<int> approveSearch(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String walletAddress = prefs.getString("currentWallet");
    var sql = SqlUtil.setTable("approve");
    var map = {'tokenAddress': address, 'walletAddress': walletAddress};
    List json = await sql.query(conditions: map);
    return json.length;
  }

  /// 刷新当前用户token列表中所有token的余额
  /// address：用户当前钱包地址
  Future updateBalance(String address) async{
    for(var i = 0; i<this.items.length; i++) {
      String balance = await TokenService.getTokenBalance(this.items[i]);
      this.updateTokenBalance(this.items[i], balance);
    }
    this._fetchToken();
  }

  /// 根据token地址更新指定token的余额
  

}