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

  /// 所有钱包
  List<Map> _items = [];

  /// 当前钱包地址
  String currentWallet = "";

  // 名字
  String currentWalletName = "";

  Map _nowWallet = {};

  // 获取钱包列表
  List<Map> get items => _items;
  // 获取当前钱包对象
  Map get  nowWallet=> _nowWallet;

  // 获取缓存的钱包
  Future<List> _fetchWallet() async {
    var sql = SqlUtil.setTable("wallet");
    List res = await sql.get();
    res.forEach((f){
      this._items.add(f);
    });
    this.setWallet();
  }

  //设置当前的钱包
  void setWallet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString("currentWallet");
    this.currentWallet = address??'--';

    this._items.forEach((f){
      if (f['address'] == address) {
        this.currentWalletName = f['name'].length > 0 ? f['name']:'Account${f['id'].toString()}';
        this._nowWallet = f;
      }
    });
    notifyListeners();
  }

  // 切换钱包
  void changeWallet(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("currentWallet", address);
    print("当前缓存钱包地址=》${address}");
    this.currentWallet = address;
    this._items.forEach((f){
      if (f['address'] == address) {
        this.currentWalletName = f['name'].length > 0 ? f['name']:'Account${f['id'].toString()}';
        print("当前缓存钱包名字=》${this.currentWalletName}");
      }
    });
    notifyListeners();
  }


  ///  将 [item] 到列表中
  Future<int> add(Map item) async {


    var sql = SqlUtil.setTable("wallet");
    String sql_insert ='INSERT INTO wallet(name, mnemonic, privateKey, address, balance) VALUES(?, ?, ?, ?, ?)';
    List list = [item['name'],item['mnemonic'], item['privateKey'], item['address'], item['balance']];
    int id = await sql.rawInsert(sql_insert, list);
    print("rawInsert => ${id}");
//    if (item['name'].length == 0){
//      var map = {'name': 'Account${id}'};
//      int res = await sql.update(map, 'address', item['address']);
//    } else {
//
//    }
    this.currentWallet = item['address'];
    this.currentWalletName =  item['name'].length > 0 ? item['name'] : 'Account${id}';

    item['name'] = this.currentWalletName;
    _items.add(item);

    notifyListeners();
    return id;
  }

  /// 删除指定钱包
  void remove(Map wallet) {
    _items.remove(wallet);
    var sql = SqlUtil.setTable("wallet");
    sql.delete('address', wallet['address']).then((result) {
      print(result);
    });
    notifyListeners();
  }

}