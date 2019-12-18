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
class Global {
  static SharedPreferences _prefs;
//  static Profile profile = Profile();
//  // 网络缓存对象
//  static NetCache netCache = NetCache();
  static String network = "";

  // 可选的主题列表
  static List<MaterialColor> get themes => _themes;

  // 是否为release版
  static bool get isRelease => bool.fromEnvironment("dart.vm.product");

  /**初始化全局信息，会在APP启动时执行
   * 初始化用户当前选择的网络
   * 初始化用户的当前钱包
   **/
  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
    network =  _prefs.getString("network");

//    if (_profile != null) {
//      try {
//        profile = Profile.fromJson(jsonDecode(_profile));
//      } catch (e) {
//        print(e);
//      }
//    }

    // 如果没有缓存策略，设置默认缓存策略
//    profile.cache = profile.cache ?? CacheConfig()
//      ..enable = true
//      ..maxAge = 3600
//      ..maxCount = 100;

    //初始化网络请求相关配置
    //Git.init();
  }

  // 持久化Profile信息
//  static saveProfile() =>
//      _prefs.setString("profile", jsonEncode(profile.toJson()));
}