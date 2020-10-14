import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:web3dart/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:bip32/bip32.dart' as bip32;
import 'package:web3dart/crypto.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' as walletModel;
import 'package:youwallet/global.dart';
import 'package:youwallet/util/http_server.dart';
import "package:hex/hex.dart";
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'dart:convert' show json;

//abstract class TokenService {
//  String generateMnemonic();
//  String maskAddress(String address);
//  String getPrivateKey(String mnemonic);
//  Future<EthereumAddress> getPublicAddress(String privateKey);
//  Future<bool> setupFromMnemonic(String mnemonic);
//  Future<bool> setupFromPrivateKey(String privateKey);
//  String entropyToMnemonic(String entropyMnemonic);
//}

class APPService {
//  IConfigurationService _configService;
//  AddressService(this._configService);
  String customeAgent = "";

  /// 获取指定钱包的余额，这里获取的是ETH的余额
  static Future<String> getBalance(String address) async {
    String rpcUrl = Global.getBaseUrl();
    final client = Web3Client(rpcUrl, Client());
    EtherAmount balance =
        await client.getBalance(EthereumAddress.fromHex(address));
    double b = balance.getValueInUnit(EtherUnit.ether);
    return b.toStringAsFixed(4);
  }

  /* 获取APP最新版本信息 - R
   * 从github的release上读取
   * */
  static Future<String> getVersion() async {
    String url = 'https://github.com/youwallet/wallet/tags';
    var response = await new Dio().get(url);
    var document = parse(response.data);
    // var app = document.querySelector(".commit-title").querySelectorAll("a");
    List<Element> app = document.querySelectorAll('.commit-title > a');
    // print('app====>${app}');
    var data = List.generate(app.length, (i) {
      // return app[i].attributes['href'];
      return app[i].innerHtml;
    });
    return data[0].trim();
  }

  /* 获取第三方gas信息 - R
  *
  * 返回值:
  * 
  */
  static Future<List> getGasList() async {
    String url = 'https://www.gasnow.org/api/v3/gas/price?utm_source=youwallet';
    var response = await new Dio().get(url);
    print(response);
    var jsonList = json.decode(response.toString());
    return [
      {'name': '极速', 'checked': false, 'value': jsonList['data']['rapid']},
      {'name': '快速', 'checked': true, 'value': jsonList['data']['fast']},
      {'name': '标准', 'checked': false, 'value': jsonList['data']['standard']},
      {'name': '慢速', 'checked': false, 'value': jsonList['data']['slow']}
    ];
  }
}
