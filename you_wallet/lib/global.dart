import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
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
  // static final proxy = "0x141A60c20026d88385a5339191C3950285e41072";
  static const proxy = "0x6BeE8B8a06F2Df4c3e3BE7E6ca8E489602378186";

  // youWallet钱包合约
  // static final tempMatchAddress= "0x3edde3202e42a6c129A399a7e063C6E236239202";
  // static final tempMatchAddress = "0x6c414F9b4daBfD4403F33EcC6d8B2142ff068C46";
  // static final tempMatchAddress = "0x675E05f5Dd6129bd5BE92DBF8319FC5DEB4dE94b";
  // static final tempMatchAddress = "0x4a5277ba2952Cb1f9a0d2E9F92c1F386ed4a41b7";
  // static final tempMatchAddress = "0xFf067F015Fc6803cDe9D9B0FfAB77803Ba4dF43A";
  static const tempMatchAddress = "0x950b5C568c46B1abcDC21F7348d9F29B7c64462a";

  // 收取交易费的账户relayer ，测试阶段用SHT的合约账户代替
  static const taxAddress = "0xA9535b10EE96b4A03269D0e0DEf417aF97477FD6";

  // 查询订单的匹配了多个额度在这个合约上查询
  static const hydroAddress = "0xbc6B59f5a1e86F262Ae92A81aE1c44F401521577";

  // 热门token
  static const hotToken = [
    {'name': 'BTAT', 'address':'0x8e4d8D520f52B044e1E8B054D763B723B7C3E716'},
    {'name': 'BTBT', 'address':'0x45e110F81bBf89041A63Bc2403058743bc552bAF'},
    {'name': 'BTCT', 'address':'0x7B29ed69368B0Ed0d3b21A857BaEeF788B13c626'},
    {'name': 'BTDT', 'address':'0x60423Ebc63245631Ea71bdF58CF23A3949329cDb'},
  ];


  // gas price 10Gwei
  static final gasPrice = BigInt.from(10000000000);
//  static const gasPrice = 10000000000;

  // gas limit 30万
  static const gasLimit = 5000000;

  // 当前用户的钱包地址，就是单纯的地址，0x开头的字符串
  static String currentWallet = '';

  // 全局配置数量的小数位数
  static int numDecimal = 4;

  // 全局配置价格的小数位数
  static int priceDecimal = 6;

  // 所有function hash
  static const funcHashes= {
    'filled(bytes32)': '0x288cdc91',
    'getOrderQueueInfo(address,address,bool)': '0x22f42f6b',
    'transfer(address,uint256)': '0xa9059cbb',
    'getOrderInfo(bytes32,bytes32,bool)': '0xb7f92b4a',
    'takeOrder()': '0xefe29415',
    'approve()': '0x095ea7b3',
    'allowance': '0xdd62ed3e',
    'cancelOrder2(bytes32,bytes32)':'0xa18d42d3',
    'orderFlag(bytes32)':'0xf8a8db0e',
    'sellQueue(bytes32)': '0xf875a998',
    'getOrderDepth(bytes32)': '0x3e8c0c4c',
    'getBQODHash()': '0xefe331cf',
    'getBQHash()': '0x30d598ed',
    'getDecimals()': '0x313ce567',
    'getTokenBalance()': '0x70a08231',
    'getConfigData()': '0xfeee047e',
    'getConfigSignature()': '0x0b973ca2'
};

  static const myKey = "v3/37caa7b8b2c34ced8819de2b3853c8a2";

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

  static String getBaseUrl() {
    return "https://" + getPrefs('network') + ".infura.io/" + myKey;
  }

  // https://ropsten.etherscan.io/tx/
  static String getDomain() {
    return "https://" + getPrefs('network') + ".etherscan.io/tx/";
  }
  // 获取缓存中数据
  static String getPrefs(String key) {
    return _prefs.getString(key);
  }

  // 设置缓存中数据
  static Future<bool> setPrefs(String key, String value) async {
    return _prefs.setString(key, value);
  }

  // 缩短钱包地址长度
  static  maskAddress(String address) {
    if (address.length > 0) {
      return "${address.substring(0, 8)}····${address.substring(address.length - 6, address.length)}";
    } else {
      return address;
    }
  }

  static Future scan(BuildContext context) async {
    try {
      // 此处为扫码结果，barcode为二维码的内容
      String barcode = await BarcodeScanner.scan();
//      return barcode;
      showSnackBar(context, barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        // 未授予APP相机权限
        showSnackBar(context, '未授予APP相机权限');
      } else {
        // 扫码错误
        print('扫码错误: $e');
        showSnackBar(context, e.toString());
      }
    } on FormatException{
      // 进入扫码页面后未扫码就返回
      print('进入扫码页面后未扫码就返回');
      showSnackBar(context, '取消扫码');
    } catch (e) {
      // 扫码错误
      showSnackBar(context, e.toString());
    }
  }

  // 显示 SnackBar
  static showSnackBar(BuildContext context, String val) {
    final snackBar = new SnackBar(content: new Text(val));
    Scaffold.of(context).showSnackBar(snackBar);
  }

}