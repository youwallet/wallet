import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 提供五套可选主题色
const _themes = <MaterialColor>[
  Colors.blue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.red,
];

// 全局共享变量
// 修改全局变量后，安卓studio需要重新启动应用，热加载不会自动更新全局变量
// 参考：https://book.flutterchina.club/chapter15/globals.html
class Global {

  // 全局调用_prefs实现KV保存和读取
  static SharedPreferences _prefs;
  // static Profile profile = Profile();
  // 网络缓存对象
  // static NetCache netCache = NetCache();
  static String network = "";

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 代理合约，用来给token授权
  static final proxy = "0x141A60c20026d88385a5339191C3950285e41072";

  // youWallet钱包合约
  static final tempMatchAddress= "0x3edde3202e42a6c129A399a7e063C6E236239202";

  // 收取交易费的账户，测试阶段用SHT的合约账户代替
  static final taxAddress = "0xA9535b10EE96b4A03269D0e0DEf417aF97477FD6";

  // 当前用户的钱包地址，就是单纯的地址，0x开头的字符串
  static String currentWallet = '';

  // 所有function hash
  static final funcHashes= {
    'filled(bytes32)': '0x288cdc91',
    'getOrderQueueInfo(address,address,bool)': '0x22f42f6b',
    'transfer(address,uint256)': '0xa9059cbb',
    'getOrderInfo(bytes32,bytes32,bool)': '0xb7f92b4a',
    'takeOrder()': '0xefe29415',
    'approve()': '0x095ea7b3',
    'allowance': '0xdd62ed3e'
  };

  static final myKey = "v3/37caa7b8b2c34ced8819de2b3853c8a2";

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();

    // 获取当前的以太坊网络
    network =  _prefs.getString("network");

    currentWallet = _prefs.getString("currentWallet");
    //初始化网络请求相关配置
    //Git.init();
  }

  static Future<String> rpcUrl() async {
    String network =  _prefs.getString("network");
    return "https://" + network + ".infura.io/" + myKey;
  }

  // 获取缓存中数据
  static String getPrefs(String key) {
    return _prefs.getString(key);
  }



}