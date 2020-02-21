import 'package:flutter/material.dart';
import 'package:youwallet/db/sql_util.dart';
import 'dart:io';
import 'package:youwallet/pages/routers.dart';
import 'package:youwallet/global.dart';
import 'package:youwallet/service/service_locator.dart';
import 'package:youwallet/db/provider.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:event_bus/event_bus.dart';
import 'package:provider/provider.dart';


// 引入model
import 'package:youwallet/model/token.dart';
import 'package:youwallet/model/wallet.dart';
import 'package:youwallet/model/network.dart';
import 'package:youwallet/model/deal.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  // 启动数据库
  final provider = new ProviderSql();
  await provider.init();

  await Global.init(); // 全局变量, 还没想清楚怎么用
  Provider.debugCheckInvalidValueType = null;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<Token>(create: (_) => Token()),
        ChangeNotifierProvider<Wallet>(create: (_) => Wallet()),
        ChangeNotifierProvider<Network>(create: (_) => Network()),
        ChangeNotifierProvider<Deal>(create: (_) => Deal())
      ],
      child: MyApp(),
    ),
  );
}

// APP最外层的widget，每个app都是这样
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //关闭调试
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.white
      ),
      initialRoute: 'splash',
      //routes: routes, // 因为定义了onGenerateRoute，所以就不需要routes这个参数了
      onGenerateRoute: onGenerateRoute // 为了传递参数
      //home: new SplashWidget(tabIndex: 0)
    );
  }
}


