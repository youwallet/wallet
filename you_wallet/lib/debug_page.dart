import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart'; // 官方组件库
//import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:http/http.dart' as http;
//import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:local_auth/local_auth.dart';
import 'package:youwallet/db/provider.dart';
import 'package:youwallet/pages/keyboard/keyboard_main.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:sacco/sacco.dart';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';

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

    final snackBar = new SnackBar(content: new Text(authenticated ? '验证通过' : '验证失败'));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("调试"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
              onPressed: () {_checkBiometrics
                ();},
            ),
            FlatButton(
              child: Text("删除交易记录数据库"),
              textColor: Colors.blue,
              onPressed: () async {
                final provider = new ProviderSql();
                await provider.clearTrade();
              },
            ),
            FlatButton(
              child: Text("输入支付密码"),
              textColor: Colors.blue,
              onPressed: () async {
                print('开始输入支付');
                Navigator.pushNamed(context, "keyboard_main").then((data){
                  //接受返回的参数
                  print(data.toString());
                });
              },
            ),
            FlatButton(
              child: Text("点击生成助记词"),
              textColor: Colors.blue,
              onPressed: () async {
                String randomMnemonic = bip39.generateMnemonic();
                print(randomMnemonic);
              },
            ),
            FlatButton(
              child: Text("助记词转seed"),
              textColor: Colors.blue,
              onPressed: () async {
                String randomMnemonic = bip39.generateMnemonic();
                print(randomMnemonic);
                String seed = bip39.mnemonicToSeedHex(randomMnemonic);
                print(seed);
              },
            ),
            FlatButton(
              child: Text("助记词转私钥"),
              textColor: Colors.blue,
              onPressed: () async {
                String randomMnemonic = bip39.generateMnemonic();
                print(randomMnemonic);
                var seed1 = bip39.mnemonicToSeed(randomMnemonic);
                var hdWallet = new HDWallet.fromSeed(seed1);
                String wallet_priv_key = '0x' + hdWallet.privKey;
                print(wallet_priv_key);
              },
            ),
            FlatButton(
              child: Text("seed转PrivateKey"),
              textColor: Colors.blue,
              onPressed: () async {
                String randomMnemonic = bip39.generateMnemonic();
                print(randomMnemonic);
                String seed = bip39.mnemonicToSeedHex(randomMnemonic);
                print(seed);
              },
            ),
            FlatButton(
              child: Text("私钥加密解密"),
              textColor: Colors.blue,
              onPressed: () async {
                String key="279EFAC43AAE9405DCD9A470B9228C1A3C0F2DEFC930AD1D9B764E78D28DB1DF";
                String pwd = "890726";
                var encryptText = await FlutterAesEcbPkcs5.encryptString(key, pwd);
                print("encryptText => ${encryptText}");
                var decryptText = await FlutterAesEcbPkcs5.decryptString(encryptText, pwd);
                print("str => ${decryptText}");
              },
            ),
          ],
        ),
      )
    );
  }
}
