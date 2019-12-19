
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import "package:hex/hex.dart";
import 'package:web3dart/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/credentials.dart';
import 'package:youwallet/util/eth_amount_formatter.dart' ;
import 'package:youwallet/db/sql_util.dart';


class Trade {

  /// youwalllet的合约地址
  static final contractAddress= "0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364";

  // 收取交易费的账户，测试阶段用SHT的合约账户代替
  static  String relayerAddress = "0000000000000000000000003d9c6c5a7b2b2744870166eac237bd6e366fa3ef";


  static Future<String> getConfigData(bool isBuy) async{
    String configData = '';
    if (isBuy) {
      configData = '0';
    } else {
      configData = '1';
    }
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from": contractAddress, // 这里的form随便写一个
          "to": contractAddress,
          "data": "0xfeee047e000000000000000000000000000000000000000000000000000000000000000"
          + configData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        'https://ropsten.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    return result['result'].replaceFirst('0x', '');
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

  // 下单，返回订单的hash
  static Future<String> takeOrder(String token, String baseToken, String amount, String price, bool isBuy) async{


    String functionName = '0xefe29415';

    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 用户钱包地址
    String trader =  formatParam(prefs.getString("currentWallet"));

    // 购买的token 数量
    String baseTokenAmount = formatParam(amount);

    // 剩下一个价格参数
    String quoteTokenAmount= formatParam(price);

    // 花费的gas
    String gasTokenAmount =  '0000000000000000000000000000000000000000000000000000000000000000';


    String data = await getConfigData(isBuy);

    String signature = await getConfigSignature(token,baseToken,amount,price,isBuy);
    print('signature => ${signature}');
    // 参数二
//    String baseToken = "0000000000000000000000008F48de31810deaA8bF547587438970EBD2e4be16";
//    String quoteToken= "000000000000000000000000414b26708362B024A28C7Bc309D5C1a8Ac14647E";
//    String relayer =   relayerAddress; // SHT合约地址
//
//    String post_data = functionName + trader + baseTokenAmount + quoteTokenAmount + gasTokenAmount + data + signature + baseToken + quoteToken + relayer;

//
//    final client = Web3Client(rpcUrl, Client());
//
//    // 加载私钥，准备加密
//    var credentials = await client.credentialsFromPrivateKey(privateKey);
//
//    var rsp = await client.sendTransaction(
//        credentials,
//        Transaction(
//            to: EthereumAddress.fromHex(faucet),
//            gasPrice: EtherAmount.inWei(BigInt.one),
//            maxGas: 100000,
//            value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
//            data: hexToBytes(post_data)
//        ),
//        chainId: 3
//    );
//
//    await client.dispose();
    // 返回值0x76a2fc80d8b14f9fa70e3f079509f92aa855acfc1351d444a17c14e4b87e3eaf，这是一个Transaction Hash
//    return rsp;
     return 'takeOrder返回';
  }

  static Future<String> getConfigSignature(String token, String baseToken, String amount, String price, bool isBuy) async{
    Map BQODHash = await getBQODHash(token,baseToken,amount,price,isBuy);
    Map sign = await ethSign(BQODHash['od_hash']);

    String functionHex = "0x0b973ca2";
    String _v = sign['v'] + "00000000000000000000000000000000000000000000000000000000000000";
    // signMethod: 签名方法, 0为eth.sign, 1为EIP712
    String _signMethod = "000000000000000000000000000000000000000000000000000000000000000" + '1';
    String post_data = functionHex + _v + sign['r'] + sign['s'] + _signMethod;

    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
          "to": contractAddress, // 合约地址
          "data": post_data
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        'https://ropsten.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    print('rsp code => ${rsp.statusCode}');
    print('rsp body => ${rsp.body}');
    Map result = jsonDecode(rsp.body);
    print(result);
    return result['result'].replaceFirst("0x", "");
  }

  // 调用web3dart，对od_hash使用私钥进行签名，这一步必须在客户端做
  static  Future<Map> ethSign(String od_hash) async {
    String privateKey = await loadPrivateKey();
    final key = EthPrivateKey(hexToBytes(privateKey));
    final signature = await key.sign(hexToBytes(od_hash), chainId: 3);
    final sign = bytesToHex(signature);
    final r = sign.substring(0,64);
    final s = sign.substring(64,128);
    final v = sign.substring(128);
    print('r => ${r}');
    print('s => ${s}');
    print('v => ${v}');
    return {
      'r': r,
      's': s,
      'v': v
    };
  }

  static Future<String> loadPrivateKey() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address =  prefs.getString("currentWallet");
    var sql = SqlUtil.setTable("wallet");
    var map = {'address': address};
    List json = await sql.query(conditions: map);
    return json[0]['privateKey'];
  }

  /*
  * 获取订单相关hash值, 返回值是长度为128位的一个字符串，前64位是bq_hash
  * String bq_hash = res.substring(0,64);
  * String od_hash = res.substring(64);
  */
  static Future<Map> getBQODHash(String token, String baseToken, String amount, String price, bool isBuy) async {

    String functionName = '0xefe331cf';

    // 用户钱包地址
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String trader =  formatParam(prefs.getString("currentWallet"));

    // 购买的token 数量
    String baseTokenAmount = formatParam(amount);

    // 剩下一个价格参数
    String quoteTokenAmount= formatParam(price);

    // 花费的gas
    String gasTokenAmount =  '0000000000000000000000000000000000000000000000000000000000000000';


    String data = await getConfigData(isBuy);

    String signature = data + data + data;  // 此时还没有signature字段，所以随便填充三个32byte的字段

    // 参数二
    token = formatParam(token);
    baseToken = formatParam(baseToken);

    String relayerAddress = "0000000000000000000000003d9c6c5a7b2b2744870166eac237bd6e366fa3ef";

    String post_data = functionName + trader + baseTokenAmount + quoteTokenAmount + gasTokenAmount + data + signature + token + baseToken + relayerAddress;
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":"0x7E999360d3327fDA8B0E339c8FC083d8AFe6A364",
          "to": contractAddress, // 合约地址
          "data": post_data
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        'https://ropsten.infura.io/',
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    Map result = jsonDecode(rsp.body);
    String  res = result['result'].replaceFirst("0x", ""); // 得到一个64字节的数据
    String bq_hash = res.substring(0,64);
    String od_hash = res.substring(64);
    return {
      'od_hash': od_hash,
      'bq_hash': bq_hash
    };
  }
}
