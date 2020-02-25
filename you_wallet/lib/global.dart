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
//  static Profile profile = Profile();
//  // 网络缓存对象
//  static NetCache netCache = NetCache();
  static String network = "";

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 代理合约，用来给token授权
  static final proxy = "0x141A60c20026d88385a5339191C3950285e41072";


  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    network =  _prefs.getString("network");

    //初始化网络请求相关配置
    //Git.init();
  }

}