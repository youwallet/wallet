import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart'; // 官方组件库
//import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:http/http.dart' as http;
//import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:youwallet/db/provider.dart';

class DebugPage extends StatefulWidget {
  DebugPage() : super();
  @override
  _DebugPageState createState()  => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  /// 本地认证框架
  final LocalAuthentication auth = LocalAuthentication();
  File _imageFile;
  bool _canCheckBiometrics; // 是否有可用的生物识别技术
  String _authorized = '验证失败';
  // 保存图片到相册
  void _onImageSaveButtonPressed() async {
    print("_onImageSaveButtonPressed");
    var response = await http
        .get('http://upload.art.ifeng.com/2017/0425/1493105660290.jpg');

    debugPrint(response.statusCode.toString());

//    var filePath = await ImagePickerSaver.saveFile(
//        fileData: response.bodyBytes);
//
//    var savedFile= File.fromUri(Uri.file(filePath));
//    debugPrint(filePath);
    setState(() {
      //_imageFile = Future<File>.sync(() => savedFile);
    });
  }

  // 打开相册选取图片
//  Future getImage() async {
//    var image = await ImagePicker.pickImage(source: ImageSource.camera);
//
//    setState(() {
//      _imageFile = image;
//    });
//  }


  void _incrementCounter() {
    print('++');
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      //_counter++;
    });
  }

  /// 检查是否有可用的生物识别技术
  Future<Null> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
      print(canCheckBiometrics);
      _authenticate();
    } catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  // 生物识别
  Future<Null> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: '扫描指纹进行身份验证',
          useErrorDialogs: true,
          stickyAuth: false);
    } catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? '验证通过' : '验证失败';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("调试页面"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("点击保存助记词到相册"),
              textColor: Colors.blue,
              onPressed: () {
                //导航到新路由
                print("ok");
                _onImageSaveButtonPressed();
              },
            ),
            FlatButton(
              child: Text("打开摄像头"),
              textColor: Colors.blue,
              onPressed: () {
                //导航到新路由
                _onImageSaveButtonPressed();
              },
            ),
            FlatButton(
              child: Text("指纹识别"),
              textColor: Colors.blue,
              onPressed: () {_checkBiometrics();},
            ),
            FlatButton(
              child: Text("删除交易记录数据库"),
              textColor: Colors.blue,
              onPressed: () async {
                final provider = new ProviderSql();
                await provider.clearTrade();
              },
            ),
          ],
        ),
      )
    );
  }
}
