import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ChangeNotifier 是 Flutter SDK 中的一个简单的类。
/// 它用于向监听器发送通知。换言之，如果被定义为 ChangeNotifier，
/// 你可以订阅它的状态变化。（这和大家所熟悉的观察者模式相类似）。

/// 在 provider 中，ChangeNotifier 是一种能够封装应用程序状态的方法。
/// 对于特别简单的程序，你可以通过一个 ChangeNotifier 来满足全部需求。
/// 在相对复杂的应用中，由于会有多个模型，所以可能会有多个 ChangeNotifier。
/// (不是必须得把 ChangeNotifier 和 provider 结合起来用，不过它确实是一个特别简单的类)。

class Network extends ChangeNotifier {

  // 构造函数，获取本地保存的token'
  Network()  {
    this._getNetwork();
  }


  String _network = "";

  //
  String  get network => _network;

  Future<void> _getNetwork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this._network = await prefs.getString("network")??'mainnet';
    notifyListeners();
  }


  void changeNetwork(String network) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("network", network);
    this._network = network;
    notifyListeners();
  }

}