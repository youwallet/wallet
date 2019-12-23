
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

  /// 交易所合约地址 这个要写入全局变量中，全局共用
  static final contractAddress= "0xf5ac3b07a86a68aCA2050253eF5e28ca02BD07f8";

  // 收取交易费的账户，测试阶段用SHT的合约账户代替
  static final taxAddress = "0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef";

  // 这个定义多大
  static final gasTokenAmount = "0000000000000000000000000000000000000000000000000000000000000000";

  // Trade内的私有变量
  String tokenA = '';
  String tokenAName = ''; // 左边token的名字
  String tokenB = '';
  String tokenBName = ''; // 右边token的名字
  String amount = '1';
  String price = '';
  bool   isBuy = true;
  String trader = ""; // 用户钱包地址
  String configData = ""; // 协议版本号码，是否买单，计算配置信息
  String privateKey="";

  String rpcUrl = "https://ropsten.infura.io/";

  String txnHash = ""; // 下单成功会返回txnHash

  Trade(String token, String tokenName, String baseToken, String baseTokenName, String amount, String price, bool isBuy) {
     this.tokenA = token;
     this.tokenAName = tokenName;
     this.tokenB = baseToken;
     this.tokenBName = baseTokenName;
     this.amount = amount;

     //需要换一个名字
     this.price = (int.parse(amount) * int.parse(price)).toString();
     this.isBuy = isBuy;
  }


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
   Future<String> takeOrder() async{

    String functionName = '0xefe29415';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.trader =  formatParam(prefs.getString("currentWallet"));

    this.configData = await getConfigData(this.isBuy);
    String signature = await getConfigSignature();


    String post_data = functionName + trader + formatParam(this.amount) + formatParam(this.price) + gasTokenAmount;
    post_data = post_data + this.configData + signature + formatParam(this.tokenA) + formatParam(this.tokenB) + formatParam(taxAddress);


    final client = Web3Client(rpcUrl, Client());
    var credentials = await client.credentialsFromPrivateKey(privateKey);
    try {
      var rsp = await client.sendTransaction(
          credentials,
          Transaction(
              to: EthereumAddress.fromHex(contractAddress),
              gasPrice: EtherAmount.inWei(BigInt.one),
              maxGas: 7000000,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
              data: hexToBytes(post_data)
          ),
          chainId: 3
      );
      print("transaction => ${rsp}");
      await client.dispose();
      this.txnHash = rsp;
      await this.saveTrader();
      return this.txnHash;
    } catch (e) {
//      Map json = jsonDecode(e);
//      print(json);
      return e.toString();
    }

  }

  // 根据 RVS计算订单的签名
  Future<String> getConfigSignature() async{
    Map BQODHash = await getBQODHash();
    Map sign = await ethSign(BQODHash['od_hash']);

    String functionHex = "0x0b973ca2";
    String _v = sign['v'] + "00000000000000000000000000000000000000000000000000000000000000";
    // signMethod: 签名方法, 0为eth.sign, 1为EIP712
    // 开发阶段默认为1
//    String _signMethod = "000000000000000000000000000000000000000000000000000000000000000" + '1';
    String post_data = functionHex + _v + sign['r'] + sign['s'] + formatParam('1');

    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from": contractAddress,
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
    return result['result'].replaceFirst("0x", "");
  }

  // 调用web3dart，对od_hash使用私钥进行签名，这一步必须在客户端做
  Future<Map> ethSign(String od_hash) async {
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

  Future<String> loadPrivateKey() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address =  prefs.getString("currentWallet");
    print('sql address => ${address}');
    var sql = SqlUtil.setTable("wallet");
    var map = {'address': address};
    List json = await sql.query(conditions: map);
    print("json => ${json}");
    this.privateKey = json[0]['privateKey'];
    return this.privateKey;
  }

  /*
  * 获取订单相关hash值, 返回值是长度为128位的一个字符串，前64位是bq_hash
  * String bq_hash = res.substring(0,64);
  * String od_hash = res.substring(64);
  */
   Future<Map> getBQODHash() async {

    String functionName = '0xefe331cf';

    String signature = this.configData + this.configData + this.configData;  // 此时还没有signature字段，所以随便填充三个32byte的字段


    String post_data = functionName + this.trader + formatParam(this.amount) + formatParam(this.price) + gasTokenAmount + this.configData + signature + formatParam(this.tokenA) + formatParam(this.tokenB) + formatParam(taxAddress);
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
    print(result);
    String  res = result['result'].replaceFirst("0x", ""); // 得到一个64字节的数据
    String bq_hash = res.substring(0,64);
    String od_hash = res.substring(64);
    return {
      'od_hash': od_hash,
      'bq_hash': bq_hash
    };
  }

  /// 保存一个交易
  ///    CREATE TABLE trade (
  //    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE,
  //    orderType TEXT,
  //    price TEXT,
  //    amount TEXT,
  //    token TEXT,
  //    baseToken TEXT,
  //    txnHash TEXT NOT NULL UNIQUE,
  //    createTime TEXT,
  //    status TEXT);
  //    """;
  Future<void> saveTrader() async {
    var sql = SqlUtil.setTable("trade");
    String sql_insert ='INSERT INTO trade(orderType, price, amount, token,tokenName, baseToken,baseTokenname, txnHash, createtime) VALUES(?, ?, ?, ?,?,?,?,?,?)';
    String orderType = '';
    if (this.isBuy) {
      orderType = '买入';
    } else {
      orderType = '卖出';
    }
    List list = [orderType,this.price, this.amount, this.tokenA,this.tokenAName,this.tokenB,this.tokenBName,this.txnHash, DateTime.now().millisecondsSinceEpoch];
    int id = await sql.rawInsert(sql_insert, list);
    print("db trade id => ${id}");
    return id;
  }

  /// 获取当前交易列表
  static Future<List> getTraderList() async {
    var sql = SqlUtil.setTable("trade");
    List list = await sql.get();
    return list;
  }
}
