import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:youwallet/pages/routers.dart';
import 'package:youwallet/global.dart';
import 'package:youwallet/service/service_locator.dart';
import 'package:youwallet/db/provider.dart';
import 'package:provider/provider.dart';

// 引入model
import 'package:youwallet/model/token.dart';
import 'package:youwallet/model/wallet.dart';
import 'package:youwallet/model/network.dart';
import 'package:youwallet/model/deal.dart';
import 'package:youwallet/model/book.dart';

// 官方的国际化插件
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:youwallet/util/locale_util.dart';
import 'package:youwallet/util/translations.dart';

// 奔溃收集和日志上报
import 'package:flutter_bugly/flutter_bugly.dart';

void main() => FlutterBugly.postCatchedException(() async {
      WidgetsFlutterBinding.ensureInitialized();
      setupLocator();

      // 启动数据库
      final provider = new ProviderSql();
      await provider.init();

      // 全局变量, 其他页面导入global类即可以使用其中的变量
      // 全局变量就只是变量，它一般不更改，即使更改，也不需要通知其他组件
      await Global.init();
      Provider.debugCheckInvalidValueType = null;

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<Token>(create: (_) => Token()),
            ChangeNotifierProvider<Wallet>(create: (_) => Wallet()),
            ChangeNotifierProvider<Network>(create: (_) => Network()),
            ChangeNotifierProvider<Deal>(create: (_) => Deal()),
            ChangeNotifierProvider<Book>(create: (_) => Book())
          ],
          child: MyApp(),
        ),
      );

      // 当平台是安卓的时候
      // 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值
      if (Platform.isAndroid) {
        SystemUiOverlayStyle systemUiOverlayStyle =
            SystemUiOverlayStyle(statusBarColor: Colors.transparent);
        SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
      }
    });

// APP最外层的widget，每个app都是这样
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        // 本地化代理
        localizationsDelegates: [
          const TranslationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        // const Locale(languageCode,countryCode)
        // Locale类是用来标识用户的语言环境的，它包括语言和国家两个标志,languageCode和countryCode：
//        supportedLocales: [
//          const Locale('en', 'US'), // 美国英语
//          const Locale('zh', 'CN'), // 中文简体
//          //其它Locales
//        ],
        supportedLocales: localeUtil.supportedLocales(),
        debugShowCheckedModeBanner: false, //关闭调试
        theme:
            ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.white),
        initialRoute: 'splash',
        //routes: routes, // 因为定义了onGenerateRoute，所以就不需要routes这个参数了
        onGenerateRoute: onGenerateRoute // 为了传递参数
        //home: new SplashWidget(tabIndex: 0)
        );
  }
}
