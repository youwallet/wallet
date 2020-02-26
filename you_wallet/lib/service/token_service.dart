
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

  /// 交易所合约地址
//  static final contractAddress= "0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364";

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

  /// 获取token的余额，这里获取的是ETH的余额
  static Future<String> getBalance(String address) async {
      String rpcUrl = await getNetWork();
      final client = Web3Client(rpcUrl, Client());
      EtherAmount balance = await client.getBalance(EthereumAddress.fromHex(address));
      double b = balance.getValueInUnit(EtherUnit.ether);
      return  b.toStringAsFixed(2);
  }

  static Future<String> getNetWork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String network =  prefs.getString('network');
    String myKey = 'v3/37caa7b8b2c34ced8819de2b3853c8a2';
    return 'https://' + network + '.infura.io/' + myKey;
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
        headers:{'Content-Type':'application/json','User-Agent':'youwallet'},
        body: json.encode(payload)
    );

    Map result = jsonDecode(rsp.body);
    print(result);
    if (result.containsKey('error') ) {
      return token['error'] = result['error'];
    } else {
      String res = result['result'];
      String name = res.replaceFirst('0x', '');
      String nameString = '';
      for(var i = 0; i < name.length; i = i + 2) {
        String subStr = name.substring(i, i+2);
        if (subStr != "00" && subStr != "20" && subStr != "03") {
          String str = String.fromCharCode(int.parse(name.substring(i, i+2), radix: 16));
          nameString = nameString + str;
        }
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      token['address'] = address;
      token['wallet'] = prefs.getString("currentWallet");
      token['name'] = nameString;
      token['balance'] = await getTokenBalance(address);
      token['decimals'] = await getDecimals(address);
      token['rmb'] = '';
      token['network'] =  prefs.getString("network");

      return token;
    }

  }

  // https://yq.aliyun.com/articles/600706/
  // 这里获取的是指定token的余额
  static Future<String> getTokenBalance(String address) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String myAddress = await prefs.getString("currentWallet");
    print('my Address => ${myAddress}');
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params":  [{
         "to": address,
         "data": "0x70a08231000000000000000000000000" + myAddress.replaceFirst('0x', '')
      },"latest"],

      "id": DateTime.now().millisecondsSinceEpoch
    };

    String rpcUrl = await getNetWork();

    var rsp = await client.post(
        rpcUrl,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    Map body = jsonDecode(rsp.body);
    // print('token balance getPublicAddress=> ${body}');
    double balance = BigInt.parse(body['result'])/BigInt.from(1000000000000000000);
    // print('token balance => ${balance}');
    // int decimals = await getDecimals(address);
    // print("token decimals => ${decimals}");
    if (balance == 0.0) {
      return '0';
    } else {
      //int len = balance.length;
      return balance.toStringAsFixed(3);
    }
  }

  /// 获取代币的小数位数
  static Future<int> getDecimals(String address) async {

    var client = Client();
    var payload = {
    "jsonrpc": "2.0",
    "method": "eth_call",
    "params": [{
      "to": address,
      "data": "0x313ce567"
    },"latest"],
    "id": DateTime.now().millisecondsSinceEpoch
    };

    String rpcUrl = await getNetWork();

    var rsp = await client.post(
      rpcUrl,
      headers:{'Content-Type':'application/json'},
      body: json.encode(payload)
    );

    Map body = jsonDecode(rsp.body);
    return int.parse(body['result'].replaceFirst("0x",''), radix: 16);
  }


  /* 获取授权代理额度 - R
   * owner: 授权人账户地址，就是用户钱包地址
   * spender: 代理人账户地址,就是proxy的合约地址
   *
   * 返回值
   * uint256 value: 代理额度
   * */
  static Future<String> allowance(context,String token) async{
    String myAddress = Provider.of<walletModel.Wallet>(context).currentWalletObject['address'];
    String postData = Global.funcHashes['allowance'] + formatParam(myAddress) + formatParam(Global.proxy);
//    print("token     => ${token}");
//    print("owner     => ${myAddress}");
//    print("proxy     => ${Global.proxy}");
//    print("postData  => ${postData}");
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params":  [{
        "to": token,
        "data": postData
      },"latest"],

      "id": DateTime.now().millisecondsSinceEpoch
    };

    String rpcUrl = await getNetWork();

    var rsp = await client.post(
        rpcUrl,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map body = jsonDecode(rsp.body);
//    print(body);
    return BigInt.parse(body['result']).toString();
  }
  static formatParam(String para) {
    para = para.replaceFirst('0x', '');
    String str = '';
    int i = 0;
    while(i < 64 - para.length)
    {
      str = str + '0';
      i++;
    }
    return str + para;
  }



//  /// 通过web3dart获取代币余额
//  static Future<void> getTokenBalanceByWeb3(String address) async {
//    String rpcUrl = await getNetWork();
//    final client = Web3Client(rpcUrl, Client(), enableBackgroundIsolate: true);
//
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String myAddress = prefs.getString("currentWallet");
//
//    final EthereumAddress contractAddr =
//    EthereumAddress.fromHex(address);
//
////    var appDocDir = await rootBundle.loadString('assets/TempMatch.json');
////
////    print(appDocDir);
//
//
//    final abiCode = await rootBundle.loadString('assets/TempMatch.json');
//
//    final contract =
//    DeployedContract(ContractAbi.fromJson(abiCode, 'TempMatch'), contractAddr);
//
//    final balanceFunction = contract.function('getBalance');
//
//
//    final balance = await client.call(
//        contract: contract, function: balanceFunction, params: [myAddress]);
//    print('We have ${balance.first} MetaCoins');
//
//  }

}
