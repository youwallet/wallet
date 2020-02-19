import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:web3dart/credentials.dart';
import 'package:youwallet/util/md5_encrypt.dart';
import 'package:youwallet/util/wallet_crypt.dart';
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';

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

  // 当前的钱包对象
  Map currentWalletObject = {};

  Map _nowWallet = {};

  // 获取钱包列表
  List<Map> get items => _items;

  // 获取当前钱包对象
  Map get  nowWallet=> _nowWallet;

  // 获取缓存的钱包
  Future<List> _fetchWallet() async {
    var sql = SqlUtil.setTable("wallet");
    List res = await sql.get();
    this._items = [];
    res.forEach((f){
      this._items.add(f);
    });

    // 设置当前的钱包
    this.changeWallet("");
  }

  // 切换钱包,如果没有参数，就从缓存中获取
  void changeWallet(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(address.length == 0) {
      address = prefs.getString("currentWallet");
    } else {
      prefs.setString("currentWallet", address);
    }

    this.currentWallet = address;
    this._items.forEach((f){
      if (f['address'] == address) {
        this.currentWalletObject = f;
      }
    });
    print('changeWallet done');
    print('address   => ${address}');
    print('currentWallet   => ${this.currentWallet}');
    print('currentWalletObject   => ${this.currentWalletObject}');
    notifyListeners();
  }


  // 将 [item] 到钱包的数据表中
  Future<int> add(Map item,String pwd) async {
    // 0. 计算钱包的address
    EthereumAddress ethereumAddress = await TokenService.getPublicAddress(item['privateKey']);
    String address = ethereumAddress.toString();

    // 1. 获取钱包的balance
    String balance = await TokenService.getBalance(address);

    // 2. 获取钱包缓存名字
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("new_wallet_name");
    prefs.setString("new_wallet_name", ""); // name被使用后，要清空

    // 3. 加密
    item['privateKey'] = await WalletCrypt(pwd,item['privateKey']).encrypt();
    item['mnemonic']   = await WalletCrypt(pwd,item['mnemonic']).encrypt();

    var sql = SqlUtil.setTable("wallet");
    String sqlInsert ='INSERT INTO wallet(name, mnemonic, privateKey, address, balance) VALUES(?, ?, ?, ?, ?)';
    List list = [name,item['mnemonic'], item['privateKey'], address, balance];
    int id = await sql.rawInsert(sqlInsert, list);

    print('wallet add done');
    print("name        => ${name}");
    print("pwd         => ${pwd}");
    print("address     => ${address}");
    print("balance     => ${balance}");
    print("privateKey  => ${item['privateKey']}");
    print("mnemonic    => ${item['mnemonic']}");
    print("钱包id       => ${id}");

    item['id'] = id;
    item['name'] = name;
    item['address'] = address;
    item['balance'] = balance;
    _items.add(item);

    // 新添加的钱包，要设置为当前钱包,当前钱包地址必须写入缓存中
    this.currentWallet = item['address'];
    this.currentWalletObject = item;
    await prefs.setString("currentWallet", address);

    // 全局广播，通知当前钱包变更
    notifyListeners();
    return id;
  }

  /// 删除指定钱包
  Future<int> remove(Map wallet) async {
    _items.remove(wallet);
    var sql = SqlUtil.setTable("wallet");
    int i = await sql.delete('address', wallet['address']);
    if (_items.length > 0 && wallet['address'] == this.currentWallet) {
      this.changeWallet(_items[0]['address']);
    } else {
      notifyListeners();
    }
    return i;
  }

  // 根据地址导出指定钱包私钥
  String exportPrivateKey(String address) {
    String key = "";
    this._items.forEach((item){
      if (item['address'] == address) {
        key = item['privateKey'];
      }
    });
    return key;
  }

  // 更新钱包名字到数据库
  Future<int> updateName(String address, String name) async {
    var sql = SqlUtil.setTable("wallet");
    int i = await sql.update({'name': name}, 'address', address);
    this._fetchWallet();
    return i;
  }

  // 根据address刷新指定wallet
  Future<int> updateWallet(String address) async{
    String balance = await TokenService.getBalance(address);
    var sql = SqlUtil.setTable("wallet");
    int i = await sql.update({'balance': balance}, 'address', address);
    print('updateWallet done');
    print("balance  => ${balance}");
    print("address  => ${address}");
    this._fetchWallet();
    return i;
  }

}