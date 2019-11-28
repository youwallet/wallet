import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:youwallet/pages/splash/splash.dart'; // 启动页面
import 'package:youwallet/pages/routers.dart'; // 添加币种

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



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'youWallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white
      ),
      routes: routers,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: SplashWidget(tabIndex: 0),
      ),
    );
  }
}


