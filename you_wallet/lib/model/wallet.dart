import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:web3dart/credentials.dart';
import 'package:youwallet/util/md5_encrypt.dart';
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


  // 将 [item] 到钱包的数据表中
  // 0. 计算钱包的address
  // 1. 获取钱包的balance
  // 2. 获取钱包缓存名字
  // 3. 加密
  Future<int> add(Map item,String pwd) async {
    EthereumAddress ethereumAddress = await TokenService.getPublicAddress(item['privateKey']);
    String address = ethereumAddress.toString();

    String balance = await TokenService.getBalance(address);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("new_wallet_name");
    prefs.setString("new_wallet_name", ""); // name被使用后，要清空

    String passwordMd5 = Md5Encrypt(pwd).init();
    item['privateKey'] = await FlutterAesEcbPkcs5.encryptString(item['privateKey'], passwordMd5);
    item['mnemonic']   = await FlutterAesEcbPkcs5.encryptString(item['mnemonic'], passwordMd5);


    print('start model add');
    print("name        => ${name}");
    print("address     => ${address}");
    print("balance     => ${balance}");
    print("privateKey  => ${item['privateKey']}");
    print("mnemonic    => ${item['mnemonic']}");

    var sql = SqlUtil.setTable("wallet");
    String sql_insert ='INSERT INTO wallet(name, mnemonic, privateKey, address, balance) VALUES(?, ?, ?, ?, ?)';
    List list = [name,item['mnemonic'], item['privateKey'], address, balance];
    int id = await sql.rawInsert(sql_insert, list);
    print("钱包id       => ${id}");
    _items.add(item);

    // 新添加的钱包，要设置为当前钱包
    this.currentWallet = item['address'];
    // 当前钱包地址必须写入缓存中
    await prefs.setString("currentWallet", address);

    // 刷新钱包列表缓存
    this._fetchWallet();
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

}