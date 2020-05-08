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
import 'package:bitcoin_flutter/bitcoin_flutter.dart' as bf;
import "package:pointycastle/digests/sha256.dart";
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:crypto/crypto.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:hex/hex.dart';
import 'package:bitcoin_flutter/src/payments/p2pkh.dart';
import 'package:convert/convert.dart';
import 'package:decimal/decimal.dart';
import 'dart:math';
import 'package:youwallet/util/number_format.dart';

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
              child: Text("Future调试"),
              textColor: Colors.blue,
              onPressed: () async {
////                print(double.parse('1234.12').toStringAsFixed(4));
//                 print(NumberFormat(1.5000).format());
//                 print(NumberFormat('100.00').format());
//                 print(NumberFormat(0.010000).format());
//                var f1 = Future(() {
//                  return 'f1';
//                });
//                var f2 = Future(() {
//                  return 'f2';
//                });
//                await Future.wait({f1,f2}).then(print).catchError(print);
//                print("111");
//                var future1 = new Future.delayed(new Duration(seconds: 1), () => 1);
//                var future2 = new Future.delayed(new Duration(seconds: 2), () => 2);
//                var future3 = new Future.delayed(new Duration(seconds: 3), () => 3);
//                Future.wait({future1,future2,future3}).then(print).catchError(print);
//                var future1 = new Future.delayed(new Duration(seconds: 1), () => 1);
//                var future2 =new Future.delayed(new Duration(seconds: 2), () => throw "throw error2");
//                var future3 = new Future.delayed(new Duration(seconds: 3), () => throw "throw error3");
//                Future.wait({future1,future2,future3}).then(print).catchError(print);
                var random = new Random();
                var totalDelay = 0;
                Future.doWhile(() {
                  if (totalDelay > 10) {
                    print('total delay: $totalDelay seconds');
                    return false;
                  }
                  var delay = random.nextInt(5) + 1;
                  totalDelay += delay;
                  return new Future.delayed(new Duration(seconds: delay), () {
                    print('waited $delay seconds');
                    return true;
                  });
                }).then(print)
                .catchError(print);
              },
            ),
            FlatButton(
              child: Text("设置密码"),
              textColor: Colors.blue,
              onPressed: () {
                  String a = '900000000000000000000000';
                  String b = '300000000000000000000000';
                  double aa = BigInt.parse(a)/BigInt.from(pow(10,18));
                  double bb = BigInt.parse(b)/BigInt.from(pow(10,18));
                  print(aa/bb);

                  String c = '13717407282579000000000000';
                  String d = '123456789000000000000000000';
                  Decimal cc = Decimal.parse(  ( BigInt.parse(c) / BigInt.from(pow(10,18))).toString()  );
                  Decimal dd =  Decimal.parse((BigInt.parse(d)/BigInt.from(pow(10,18))).toString());
                  print(cc/dd);
                },
            ),
            FlatButton(
              child: Text("删除交易记录数据库"),
              textColor: Colors.blue,
              onPressed: () async {
//                final provider = new ProviderSql();
//                await provider.clearTrade();
                print(Decimal.parse(pow(10, 18).toString()));
              },
            ),
//            FlatButton(
//              child: Text("输入支付密码"),
//              textColor: Colors.blue,
//              onPressed: () async {
//                print('开始输入支付');
//                Navigator.pushNamed(context, "keyboard_main").then((data){
//                  //接受返回的参数
//                  print(data.toString());
//                });
//              },
//            ),
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
                var hdWallet = new bf.HDWallet.fromSeed(seed1);
                print(hdWallet.address);
                // => 12eUJoaWBENQ3tNZE52ZQaHqr3v4tTX4os
                print(hdWallet.pubKey);
                // => 0360729fb3c4733e43bf91e5208b0d240f8d8de239cff3f2ebd616b94faa0007f4
                print(hdWallet.privKey);
                // => 01304181d699cd89db7de6337d597adf5f78dc1f0784c400e41a3bd829a5a226
                print(hdWallet.wif);
                var wallet = bf.Wallet.fromWIF(hdWallet.wif);
                print(wallet.address);
                // => 19AAjaTUbRjQCMuVczepkoPswiZRhjtg31
                print(wallet.pubKey);
                // => 03aea0dfd576151cb399347aa6732f8fdf027b9ea3ea2e65fb754803f776e0a509
                print(wallet.privKey);
                // => 3095cb26affefcaaa835ff968d60437c7c764da40cdd1a1b497406c7902a8ac9
                print(wallet.wif);
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
                var data = "razor romance foot shell monkey fatal deer exile wood merge income roof";

                var password = "123456";

                var digest = md5.convert(new Utf8Encoder().convert(password));

                print(hex.encode(digest.bytes));
                //加密
                var encryptText = await FlutterAesEcbPkcs5.encryptString(data, hex.encode(digest.bytes));

                print(encryptText);
                //解密
                var decryptText  = await FlutterAesEcbPkcs5.decryptString(encryptText, hex.encode(digest.bytes));

                print(decryptText);
              },

            ),
            FlatButton(
              child: Text("HMAC-SHA512"),
              textColor: Colors.blue,
              onPressed: () async {
                String randomMnemonic = bip39.generateMnemonic();
                print(randomMnemonic);
                var key = utf8.encode('');
                var bytes = utf8.encode(randomMnemonic);
                var hmacSha256 = new Hmac(sha512, key); // HMAC-SHA256
                var digest = hmacSha256.convert(bytes);
                print("HMAC digest as bytes: ${digest.bytes}");
                print("HMAC digest as hex string: $digest");
              },
            ),
            FlatButton(
              child: Text("derivePath"),
              textColor: Colors.blue,
              onPressed: () async {
                const mnemonic = 'praise you muffin lion enable neck grocery crumble super myself license ghost';
                final seed = bip39.mnemonicToSeed(mnemonic);
                final root = bip32.BIP32.fromSeed(seed);
                final child1 = root.derivePath("m/44'/60'/0'/0/0");
                print( bytesToHex(child1.publicKey));
                print( bytesToHex(child1.privateKey));
                final private = EthPrivateKey.fromHex(bytesToHex(child1.privateKey));
                final address = await private.extractAddress();
                print(address);
              },
            ),
            FlatButton(
              child: Text("BigInt"),
              textColor: Colors.blue,
              onPressed: () async {
                print(BigInt.from(200));
                print(BigInt.parse('2000'));
                print(BigInt.from(10).pow(18)); // 10的18次方
                print(BigInt.from(10).pow(3));
//                print(1234 * BigInt.from(10).pow(18));
               // String val = '8ac7230489e80000';
                // print(int.parse(val.replaceFirst("0x",''), radix: 16));
                print(BigInt.parse('0x000000000000000000008ac7230489e80000'));
              },
            ),
            FlatButton(
              child: Text("密码输入"),
              textColor: Colors.blue,
              onPressed: (){
                //Navigator.pushNamed(context, "password");

                Navigator.pushNamed(context, "getPassword");
              },
            ),
            FlatButton(
              child: Text("设置密码"),
              textColor: Colors.blue,
              onPressed: (){
                Navigator.pushNamed(context, "password");

                //Navigator.pushNamed(context, "getPassword");
              },
            ),
            FlatButton(
              child: Text("int测试"),
              textColor: Colors.blue,
              onPressed: (){
//                print(int.parse('2.0'));
                print(double.parse('2'));
              },
            ),
          ],
        ),
      )
    );
  }
}
