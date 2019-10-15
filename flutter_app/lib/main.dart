import 'package:flutter/material.dart';
import 'package:youwallet/debug_page.dart'; // 全局调试
import 'package:youwallet/pages/login/login.dart'; // 解锁登录
import 'package:youwallet/wallet_guide.dart'; // 钱包引导页

import 'package:youwallet/tab_wallet.dart'; // 钱包引导页TabExchange
import 'package:youwallet/tab_exchange.dart'; // 钱包引导页
import 'package:youwallet/tab_receive.dart'; // 钱包引导页
import 'package:youwallet/tab_transfer.dart'; // 钱包引导页
import 'package:youwallet/pages/create_wallet/set_wallet_name.dart'; // 新建钱包名字

// 应用入口，所有的一起都是从这里开始发生的
void main() => runApp(MyApp());
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'You Wallet',
      // 在Flutter中使用ThemeData来在应用中共享颜色和字体样式，Theme有两种：全局Theme和局部Theme。
      // 全局Theme是由应用程序根MaterialApp创建的Theme
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white
      ),
      //注册路由表
      routes:{
        "debug_page": (context) => new DebugPage(),
        "wallet_guide": (context) => new WalletGuide(),
        "set_wallet_name": (context) => new NewWalletName(),
        "login": (context) => new Login(),
      },
      home: MyHomePage(title: 'youwallet'),
    );
  }
}

// 启动页，程序进来后的第一个页面
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _tabIndex = 0;
  var tabImages;
  var appBarTitles = ['钱包', '兑换', '收款','转账'];
  /*
   * 存放4个页面，跟fragmentList一样
   */

  var _pageList;

  /*
   * 根据选择获得对应的normal或是press的icon
   */
  Image getTabIcon(int curIndex) {
    if (curIndex == _tabIndex) {
      return tabImages[curIndex][1];
    }
    return tabImages[curIndex][0];
  }

  /*
   * 获取bottomTab的颜色和文字
   */
  Text getTabTitle(int curIndex) {
    if (curIndex == _tabIndex) {
      return new Text(appBarTitles[curIndex],
          style: new TextStyle(fontSize: 14.0, color: const Color(0xff1296db)));
    } else {
      return new Text(appBarTitles[curIndex],
          style: new TextStyle(fontSize: 14.0, color: const Color(0xff515151)));
    }
  }
  /*
   * 根据image路径获取图片
   */
  Image getTabImage(path) {
    return new Image.asset(path, width: 24.0, height: 24.0);
  }


  void initData() {
    /*
     * 初始化选中和未选中的icon
     */
    tabImages = [
      [getTabImage('assets/images/home.png'), getTabImage('assets/images/home-active.png')],
      [getTabImage('assets/images/home.png'), getTabImage('assets/images/home-active.png')],
      [getTabImage('assets/images/home.png'), getTabImage('assets/images/home-active.png')],
      [getTabImage('assets/images/home.png'), getTabImage('assets/images/home-active.png')]
    ];
    /*
     * 四个子界面
     */
    _pageList = [
      new TabWallet(),
      new TabExchange(),
      new TabReceive(),
      new TabTransfer()
    ];
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    initData();
    return Scaffold(
      bottomNavigationBar: new BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          new BottomNavigationBarItem(
              icon: getTabIcon(0), title: getTabTitle(0)),
          new BottomNavigationBarItem(
              icon: getTabIcon(1), title: getTabTitle(1)),
          new BottomNavigationBarItem(
              icon: getTabIcon(2), title: getTabTitle(2)),
          new BottomNavigationBarItem(
              icon: getTabIcon(3), title: getTabTitle(3)),
        ],
        type: BottomNavigationBarType.fixed,
        //默认选中首页
        currentIndex: _tabIndex,
        iconSize: 24.0,
        //点击事件
        onTap: (index) {
          setState(() {
            _tabIndex = index;
          });
        },
      ),
      body: _pageList[_tabIndex] // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
