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
  Trade() {}

  /// 所有钱包
  List<Map> _items = [];


  // 获取钱包列表
  List<Map> get items => _items;



  // 将 [item] 到钱包的数据表中
//  Future<int> add(Map item,String pwd) async {
//    // 0. 计算钱包的address
//    EthereumAddress ethereumAddress = await TokenService.getPublicAddress(item['privateKey']);
//    String address = ethereumAddress.toString();
//
//    // 1. 获取钱包的balance
//    String balance = await TokenService.getBalance(address);
//
//    // 2. 获取钱包缓存名字
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String name = prefs.getString("new_wallet_name");
//    prefs.setString("new_wallet_name", ""); // name被使用后，要清空
//
//    // 3. 加密
//    item['privateKey'] = await WalletCrypt(pwd,item['privateKey']).encrypt();
//    item['mnemonic']   = await WalletCrypt(pwd,item['mnemonic']).encrypt();
//
//    var sql = SqlUtil.setTable("wallet");
//    String sqlInsert ='INSERT INTO wallet(name, mnemonic, privateKey, address, balance) VALUES(?, ?, ?, ?, ?)';
//    List list = [name,item['mnemonic'], item['privateKey'], address, balance];
//    int id = await sql.rawInsert(sqlInsert, list);
//
//    print('wallet add done');
//    print("name        => ${name}");
//    print("pwd         => ${pwd}");
//    print("address     => ${address}");
//    print("balance     => ${balance}");
//    print("privateKey  => ${item['privateKey']}");
//    print("mnemonic    => ${item['mnemonic']}");
//    print("钱包id       => ${id}");
//
//    item['id'] = id;
//    item['name'] = name;
//    item['address'] = address;
//    item['balance'] = balance;
//    _items.add(item);
//
//    // 新添加的钱包，要设置为当前钱包,当前钱包地址必须写入缓存中
//    this.currentWallet = item['address'];
//    this.currentWalletObject = item;
//    await prefs.setString("currentWallet", address);
//
//    // 全局广播，通知当前钱包变更
//    notifyListeners();
//    return id;
//  }

  /// 删除指定钱包
//  Future<int> remove(Map wallet) async {
//    _items.remove(wallet);
//    var sql = SqlUtil.setTable("wallet");
//    int i = await sql.delete('address', wallet['address']);
//    if (_items.length > 0 && wallet['address'] == this.currentWallet) {
//      this.changeWallet(_items[0]['address']);
//    } else {
//      notifyListeners();
//    }
//    return i;
//  }

  // 根据地址导出指定钱包私钥
//  String exportPrivateKey(String address) {
//    String key = "";
//    this._items.forEach((item){
//      if (item['address'] == address) {
//        key = item['privateKey'];
//      }
//    });
//    return key;
//  }

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

  // 根据address刷新指定wallet
//  Future<int> updateWallet(String address) async{
//    String balance = await TokenService.getBalance(address);
//    var sql = SqlUtil.setTable("wallet");
//    int i = await sql.update({'balance': balance}, 'address', address);
//    print('updateWallet done');
//    print("balance  => ${balance}");
//    print("address  => ${address}");
//    this._fetchWallet();
//    return i;
//  }

}