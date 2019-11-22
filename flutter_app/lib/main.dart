import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:youwallet/pages/splash/splash.dart'; // 启动页面
import 'package:youwallet/debug_page.dart'; // 全局调试
import 'package:youwallet/pages/login/login.dart'; // 解锁登录
import 'package:youwallet/wallet_guide.dart'; // 钱包引导页

////四个tab页面
//import 'package:youwallet/tab_wallet.dart'; // 钱包引导页TabExchange
//import 'package:youwallet/tab_exchange.dart'; // 钱包引导页
//import 'package:youwallet/tab_receive.dart'; // 钱包引导页
//import 'package:youwallet/tab_transfer.dart'; // 钱包引导页


// 新建钱包
import 'package:youwallet/pages/create_wallet/set_wallet_name.dart';
import 'package:youwallet/pages/create_wallet/backup_wallet.dart';
import 'package:youwallet/pages/create_wallet/load_wallet.dart';

// 钱包管理和设置
import 'package:youwallet/pages/manage_wallet/manage_wallet.dart'; // 新建钱包名字
import 'package:youwallet/pages/manage_wallet/set_wallet.dart'; // 新建钱包名字
import 'package:youwallet/pages/manage_wallet/add_wallet.dart'; // 添加币种

// token
import 'package:youwallet/pages/token/token_history.dart'; // 添加币种

// 应用入口，所有的一起都是从这里开始发生的
void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    print('this is Android');
    // 可以在这里针对安卓和ios做一些区别设置
    //SystemUiOverlayStyle systemUiOverlayStyle =
    //SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    //SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

final routers = {
  "debug_page": (context) => new DebugPage(),
  "wallet_guide": (context) => new WalletGuide(),
  "set_wallet_name": (context) => new NewWalletName(),
  "manage_wallet": (context) => new ManageWallet(),
  "set_wallet": (context) => new SetWallet(),
  "add_wallet": (context) => new AddWallet(),
  "token_history":(context) => new TokenHistory(),
  "login": (context) => new Login(),
  "backup_wallet": (context) => new BackupWallet(),
  "load_wallet": (context) => new LoadWallet(),
};

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'youWallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white
      ),
      //注册路由表
      routes: routers,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SplashWidget(tabIndex: 0),
      ),
    );
  }
}


