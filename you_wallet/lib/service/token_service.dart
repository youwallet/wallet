
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
  String customeAgent = "";

  // 获取助记词
  static String generateMnemonic() {
    String randomMnemonic = bip39.generateMnemonic();
    return randomMnemonic;
  }


//  static String getPrivateKey(String randomMnemonic) {
//    String hexSeed = bip39.mnemonicToSeedHex(randomMnemonic);
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


   // 助记词转私钥Private Key
  static String getPrivateKey(String mnemonic) {
    final seed = bip39.mnemonicToSeed(mnemonic);
    final root = bip32.BIP32.fromSeed(seed);
    final child1 = root.derivePath("m/44'/60'/0'/0/0");
    return bytesToHex(child1.privateKey);
  }

  static Future<EthereumAddress> getPublicAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    return address;
  }


  /// 获取指定钱包的余额，这里获取的是ETH的余额
  static Future<String> getBalance(String address) async {
      String rpcUrl = Global.getBaseUrl();
      print('rpcurl => $rpcUrl');
      final client = Web3Client(rpcUrl, Client());
      EtherAmount balance = await client.getBalance(EthereumAddress.fromHex(address));
      double b = balance.getValueInUnit(EtherUnit.ether);
      print(b);
      return  b.toStringAsFixed(4);
  }

  /// 搜索指定token
  static Future<String> getTokenName(String address) async {
    Map params = {"data": "0x95d89b41"};
    var response = await Http().post(params: params, to: address);
    String res = response['result'];
    String name = res.replaceFirst('0x', '');
    String nameString = '';
    List hexList = HEX.decode(name);
    for(var i = 0; i < hexList.length; i++) {
      if (hexList[i] != 32 && hexList[i] != 4 && hexList[i] != 3 && hexList[i] != 0) {
        print(hexList[i]);
        String str = String.fromCharCode(hexList[i]);
        nameString = nameString + str;
      }
    }
    return nameString;
  }

  /// https://yq.aliyun.com/articles/600706/
  /// 这里获取的是指定token的余额
  /// 这里还要考虑小数点的问题，正常情况下token都是18位小数，特殊情况下有12位小数存在
  /// 计算balance，需根据当前token的小数点来除
  /// 当前还是固定的18位
  static Future<String> getTokenBalance(Map token) async {
    String myAddress = Global.getPrefs("currentWallet");
    Map params = {
      "data": Global.funcHashes['getTokenBalance()'] + myAddress.replaceFirst('0x', '').padLeft(64, '0')
    };
    var response = await Http().post(params: params, to: token['address']);
    double balance = BigInt.parse(response['result'])/BigInt.from(pow(10, token['decimals']));
    if (balance == 0.0) {
      return '0';
    } else {
      return balance.toStringAsFixed(3);
    }
  }

  /// 获取代币的小数位数
  static Future<int> getDecimals(String address) async {
    Map params = {
      "data": Global.funcHashes['getDecimals()']
    };
    var response = await Http().post(params: params, to: address);
    print(response);
    return int.parse(response['result'].replaceFirst("0x",''), radix: 16);
  }


  /* 获取授权代理额度 - R
   * owner: 授权人账户地址，就是用户钱包地址
   * spender: 代理人账户地址,就是proxy的合约地址
   * 拼接postData，每次都很长，如果更优雅的拼接postData呢
   * 返回值
   * uint256 value: 代理额度
   * */
  static Future<String> allowance(context,String token) async{
    String myAddress = Provider.of<walletModel.Wallet>(context).currentWalletObject['address'];
    String postData = Global.funcHashes['allowance'] + myAddress.replaceFirst('0x', '').padLeft(64, '0') + Global.proxy.replaceFirst('0x', '').padLeft(64, '0');
    var response = await Http().post(params: {"data": postData}, to: token);
    return BigInt.parse(response['result']).toString();
  }
}
