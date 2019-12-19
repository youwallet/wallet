
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import "package:hex/hex.dart";
import 'package:web3dart/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:youwallet/util/eth_amount_formatter.dart' ;

//abstract class TokenService {
//  String generateMnemonic();
//  String maskAddress(String address);
//  String getPrivateKey(String mnemonic);
//  Future<EthereumAddress> getPublicAddress(String privateKey);
//  Future<bool> setupFromMnemonic(String mnemonic);
//  Future<bool> setupFromPrivateKey(String privateKey);
//  String entropyToMnemonic(String entropyMnemonic);
//}

class TokenService {
//  IConfigurationService _configService;
//  AddressService(this._configService);



  // 获取助记词
  static String generateMnemonic() {
    String randomMnemonic = bip39.generateMnemonic();
    return randomMnemonic;
  }


//  static String getPrivateKey(String randomMnemonic) {
//
//    String hexSeed = bip39.mnemonicToSeedHex(randomMnemonic);
//
//    KeyData master = ED25519_HD_KEY.getMasterKeyFromSeed(hexSeed);
//    return HEX.encode(master.key);
//  }

  static  maskAddress(String address) {
    if (address.length > 0) {
      return "${address.substring(0, 8)}...${address.substring(address.length - 12, address.length)}";
    } else {
      return address;
    }
  }

  String entropyToMnemonic(String entropyMnemonic) {
    return bip39.entropyToMnemonic(entropyMnemonic);
  }


   // 助记词转密钥
  static String getPrivateKey(String mnemonic) {
    String seed = bip39.mnemonicToSeedHex(mnemonic);
    KeyData master = ED25519_HD_KEY.getMasterKeyFromSeed(seed);
    return HEX.encode(master.key);
  }

  static Future<EthereumAddress> getPublicAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    return address;
  }

  @override
  Future<bool> setupFromMnemonic(String mnemonic) async {
    final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
//    await _configService.setPrivateKey(null);
//    await _configService.setMnemonic(cryptMnemonic);
//    await _configService.setupDone(true);
    return true;
  }

  @override
  Future<bool> setupFromPrivateKey(String privateKey) async {
//    await _configService.setMnemonic(null);
//    await _configService.setPrivateKey(privateKey);
//    await _configService.setupDone(true);
    return true;
  }

  /// 获取token的余额
  static Future<String> getBalance(String address) async {
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String network = prefs.getString("network");
//    var client = Client();
//    var payload = {
//      "jsonrpc": "2.0",
//      "method": "eth_getBalance",
//      "params": [address,"latest"],
//      "id": DateTime.now().millisecondsSinceEpoch
//    };
//    String url = 'https://' + network + '.infura.io/';
//    print(url);
//    var rsp = await client.post(
//        url,
//        headers:{'Content-Type':'application/json'},
//        body: json.encode(payload)
//    );
//
//    Map body = jsonDecode(rsp.body);
//    String hexBalance = body['result'].replaceAll('0x', '');
//    print(EthAmountFormatter(body['result']).format());
//    return  hexBalance;

      String rpcUrl = await getNetWork();
      final client = Web3Client(rpcUrl, Client(), enableBackgroundIsolate: true);

//      final credentials = await client.credentialsFromPrivateKey(privateKey);
//      final address = await credentials.extractAddress();
       EtherAmount balance = await client.getBalance(EthereumAddress.fromHex(address));
       double b = balance.getValueInUnit(EtherUnit.ether);
       return  b.toStringAsFixed(2);
  }

  static Future<String> getNetWork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return 'https://' + prefs.getString('network') + '.infura.io/';
  }

  /// 搜索指定token
  static Future<Map> searchToken(String address) async {
    Map token = new Map();
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [{
        "to": address,
        "data": "0x95d89b41"
      },"latest"],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    String url = await getNetWork();
    var rsp = await client.post(
        url,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    if (result.containsKey('error') ) {
      return token['error'] = result['error'];
    } else {
      String res = result['result'];
      print("name => ${res}");
      String name = res.replaceFirst('0x', '');
      String nameString = '';
      for(var i = 0; i < name.length; i = i + 2) {
        String subStr = name.substring(i, i+2);
        if (subStr != "00" && subStr != "20" && subStr != "03") {
          print(name.substring(i, i+2));
          String str = String.fromCharCode(int.parse(name.substring(i, i+2), radix: 16));
          nameString = nameString + str;
        }
      }

      token['address'] = address;
      token['name'] = nameString;
      token['balance'] = await getBalance(address);
      return token;
    }
  }

  /// h获取token余额


}
