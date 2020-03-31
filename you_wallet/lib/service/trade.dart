
import 'dart:math';

import 'package:web3dart/credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/crypto.dart';

import 'package:youwallet/db/sql_util.dart';
import 'package:youwallet/global.dart';
import 'package:youwallet/util/md5_encrypt.dart';
import 'package:youwallet/util/wallet_crypt.dart';
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:decimal/decimal.dart';
import 'package:youwallet/util/number_format.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/deal.dart';

class Trade {

  //  static final taxAddress = "0xA9535b10EE96b4A03269D0e0DEf417aF97477FD6";

  // 这个定义多大?
  static final gasTokenAmount = "0000000000000000000000000000000000000000000000000000000000000000";

  static final Map func = {
    'filled(bytes32)': '0x288cdc91',
    'getOrderQueueInfo(address,address,bool)': '0x22f42f6b',
    'transfer(address,uint256)': '0xa9059cbb',
    'getOrderInfo(bytes32,bytes32,bool)': '0xb7f92b4a',
    'takeOrder()': '0xefe29415',
    'approve()': '0x095ea7b3'
  };

  // Trade内的私有变量
  String tokenA = '';
  String tokenAName = ''; // 左边token的名字
  String tokenB = '';
  String tokenBName = ''; // 右边token的名字
  String amount = '1';
  String price = '';
  bool   isBuy = true;
  String trader = "";     // 当前交易的用户钱包地址
  String configData = ""; // 协议版本号码、是否买单，计算配置信息
  String privateKey = "";        // 私钥

  String rpcUrl = "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2";

  String odHash = "";     // odHash,用来查询兑换订单
  String bqHash = "";     // b代表buy, 买单的hash
  String sqHash = "";     // s代表sell，卖单的hash

  String txnHash = "";     // 下单成功会返回txnHash

  String oldPrice = "";   // 保留原始的价格数据
  String oldAmount = "";  // 保留原始的数量


  Trade(String token, String tokenName, String baseToken, String baseTokenName, String amount, String price, bool isBuy, String privateKey) {
     this.tokenA = token;
     this.tokenAName = tokenName;
     this.tokenB = baseToken;
     this.tokenBName = baseTokenName;
     // 数量需要转化成16进制，
     this.amount = amount;
     this.oldAmount = amount;
     // 密码，先进行md5加密，再使用AES揭秘私钥
     this.privateKey = privateKey;
     //需要换一个名字
     this.price = price;
     this.oldPrice = price;
     this.isBuy = isBuy;


  }

  /* 获取订单参数中的data
   * is_sell: true 为卖单, false 为买单
   *
   * 返回值：
   * bytes32 data
   *
   * function getConfigData(bool is_sell);
   * */
  static Future<String> getConfigData(bool isBuy) async{
    String configData = '';
    if (isBuy) {
      configData = '0';  // 参数编码中0表示false，1表示你true
    } else {
      configData = '1';
    }
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from": Global.tempMatchAddress, // 这里的form随便写一个
          "to": Global.tempMatchAddress,
          "data": "0xfeee047e000000000000000000000000000000000000000000000000000000000000000${configData}"
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rsp = await client.post(
        "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2",
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

  static padingZero(int n){
    String str = '';
    int i = 0;
    while(i < n)
    {
      str = str + '0';
      i++;
    }
    return str;
  }

  // 下单，返回订单的hash
  // 用户输入的价格和数量在提交时需要格式化，规则如下
  // https://github.com/youwallet/wallet/issues/35#issuecomment-586881171
   Future<String> takeOrder() async {
    this.trader =  formatParam(Global.getPrefs("currentWallet"));
    this.configData = await getConfigData(this.isBuy);

    // token的小数位数默认18位
    this.price = (Decimal.parse(this.amount) * Decimal.parse(price)*Decimal.parse(pow(10, 18).toString())).toStringAsFixed(0) ;
    this.price = BigInt.parse(this.price).toRadixString(16);

    this.amount = (Decimal.parse(this.amount) * Decimal.parse(pow(10, 18).toString())).toStringAsFixed(0) ;
    this.amount = BigInt.parse(this.amount).toRadixString(16);

    print("takeOrder price  => ${this.price}");
    print("takeOrder amount  => ${this.amount}");

    String signature = await getConfigSignature();

    String postData = Global.funcHashes['takeOrder()'] + trader + formatParam(this.amount) + formatParam(this.price) + gasTokenAmount;
    postData = postData + this.configData + signature + formatParam(this.tokenA) + formatParam(this.tokenB) + formatParam(Global.taxAddress);

    final client = Web3Client(rpcUrl, Client());
    var credentials = await client.credentialsFromPrivateKey(privateKey);

    var rsp = await client.sendTransaction(
        credentials,
        Transaction(
            to: EthereumAddress.fromHex(Global.tempMatchAddress),
            gasPrice: EtherAmount.inWei(Global.gasPrice),
            maxGas: Global.gasLimit,
            value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
            data: hexToBytes(postData)
        ),
        chainId: 3
    );
//    print("transaction => ${rsp}");
    await client.dispose();
    this.txnHash = rsp;
    // 保存订单到本地数据库，
    // 注意这时订单还在打包中，只有hash值，不算成功
    await this.saveTrader();
    return this.txnHash;
  }

  // 根据 RVS计算订单的签名
    /* 获取交易签名数据
   * v: 签名v值
   * r: 签名r值
   * s: 签名s值
   * signMethod: 签名方法, 0为eth.sign, 1为EIP712
   *
   * 返回值：
   * OrderSignature 结构体
   *
   *  function getConfigSignature(bytes1 v,  bytes32 r, bytes32 s, uint8 signMethod);
   * */

  Future<String> getConfigSignature() async{
    Map BQODHash = await getBQODHash();
    Map sign = await ethSign(BQODHash['od_hash']);

    String _v = sign['v'] + "00000000000000000000000000000000000000000000000000000000000000";
    String postData = "0x0b973ca2" + _v + sign['r'] + sign['s'] + formatParam('0');

    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from": Global.tempMatchAddress,
          "to": Global.tempMatchAddress, // 合约地址
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    Map result = jsonDecode(rsp.body);
    print("getConfigSignature body =>${result}");
    return result['result'].replaceFirst("0x", "");
  }

  // 调用web3dart，对od_hash使用私钥进行签名，这一步必须在客户端做
  Future<Map> ethSign(String od_hash) async {
    final key = EthPrivateKey(hexToBytes(this.privateKey));
    final signature = await key.signPersonalMessage(hexToBytes(od_hash));
    final sign = bytesToHex(signature);
    final r = sign.substring(0,64);
    final s = sign.substring(64,128);
    final v = sign.substring(128);
    return {
      'r': r,
      's': s,
      'v': v
    };
  }

  Future<String> loadPrivateKey(String pwd) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address =  prefs.getString("currentWallet");

    var sql = SqlUtil.setTable("wallet");
    var map = {'address': address};
    List json = await sql.query(conditions: map);

    String md5Pwd = Md5Encrypt(pwd).init();
    String privateKey = await FlutterAesEcbPkcs5.decryptString(json[0]['privateKey'], md5Pwd);
    this.privateKey = privateKey;
    if (this.privateKey == null) {
      throw '钱包解密失败，请确认密码是否正确';
    } else {
      return this.privateKey;
    }
  }



  /*
  * 获取订单相关hash值, 返回值是长度为128位的一个字符串，前64位是bq_hash
 * bq_hash: base-token/quote-token buy  哈希值
 * sq_hash: base-token/quote-token sell 哈希值
 * od_hash: 订单哈希值
  */
   Future<Map> getBQODHash() async {
    // 此时还没有signature字段，所以随便填充三个32byte的字段
    String signature = this.configData + this.configData + this.configData;
    //    print('getBQODHash functionName             =》${functionName}');
    //    print('getBQODHash this.trader              =》${this.trader}');
    //    print('getBQODHash formatParam(this.amount) =》${formatParam(this.amount)}');
    //    print('getBQODHash formatParam(this.price)  =》${formatParam(this.price)}');
    //    print('getBQODHash gasTokenAmount           =》${gasTokenAmount}');
    //    print('getBQODHash this.configData          =》${this.configData}');
    //    print('getBQODHash signature                =》${signature}');
    //    print('getBQODHash formatParam(this.tokenA) =》${formatParam(this.tokenA)}');
    //    print('getBQODHash formatParam(this.tokenB) =》${formatParam(this.tokenB)}');
    //    print('getBQODHash formatParam(taxAddress)  =》${formatParam(Global.taxAddress)}');
    String postData = Global.funcHashes['getBQODHash()'] + this.trader + formatParam(this.amount) + formatParam(this.price) + gasTokenAmount + this.configData + signature + formatParam(this.tokenA) + formatParam(this.tokenB) + formatParam(Global.taxAddress);
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":Global.tempMatchAddress,
          "to": Global.tempMatchAddress,
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
//    print("getBQODHash =》 ${rsp.body}");
    Map result = jsonDecode(rsp.body);

    String  res = result['result'].replaceFirst("0x", ""); // 得到一个64字节的数据
    String sq_hash = res.substring(0,64);
    String bq_hash = res.substring(64,128);
    String od_hash = res.substring(128);
//    print("bq_hash =》 ${bq_hash}");
//    print("od_hash =》 ${od_hash}");
    this.odHash = od_hash;
    this.bqHash = bq_hash;
    this.sqHash = sq_hash;
    return {
      'od_hash': od_hash,
      'bq_hash': bq_hash,
      'sq_hash': sq_hash
    };
  }

  // 保存兑换订单到本地数据库
  Future<void> saveTrader() async {
    var sql = SqlUtil.setTable("trade");
    String orderType = '';
    if (this.isBuy) {
      orderType = '买入';
    } else {
      orderType = '卖出';
    }
    List list = [orderType,this.oldPrice, this.oldAmount, '0.00',this.tokenA,this.tokenAName,this.tokenB,this.tokenBName,this.txnHash,this.odHash, this.bqHash, this.sqHash,DateTime.now().millisecondsSinceEpoch,'打包中'];
    String sqlInsert ='INSERT INTO trade(orderType, price, amount,filled, token,tokenName, baseToken,baseTokenname, txnHash, odHash, bqHash, sqHash,createtime,status) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
    int id = await sql.rawInsert(sqlInsert, list);
    print("db trade id => ${id}");
   }

  /// 从数据库获取当前兑换列表，
  static Future<List> getTraderList() async {
    var sql = SqlUtil.setTable("trade");
    List list = await sql.get();
    return list;
  }

  /// 获取订单匹配情况
  static Future getFilled(String odHash) async {

    String postData = func['filled(bytes32)'] + odHash;
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":Global.hydroAddress,
          "to": Global.hydroAddress,
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    return BigInt.parse(result['result'].replaceFirst("0x",''), radix: 16)/BigInt.from(pow(10 ,18));
  }

  // 0x22f42f6b
  // 根据token和basetoken获取订单队列
  static Future<String> getOrderQueueInfo(String baseToken, String quoteToken, bool isSell) async {
    String strSell = isSell ? '1' : '0';
    String params = formatParam(baseToken) + formatParam(quoteToken) + formatParam(strSell);
    String postData = func['getOrderQueueInfo(address,address,bool)'] + params;
//    print(postData);
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":Global.tempMatchAddress,
          "to": Global.tempMatchAddress,
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    return result['result'];
  }

  static Future<String> getNetWork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String network =  prefs.getString('network');
    return 'https://' + network + '.infura.io/' + 'v3/37caa7b8b2c34ced8819de2b3853c8a2';
  }


  // 自定义转账
  // data的组成，
  // 0x + 要调用的合约方法的function signature
  // + 要传递的方法参数，每个参数都为64位
  // (对transfer来说，第一个是接收人的地址去掉0x，第二个是代币数量的16进制表示，去掉前面0x，然后补齐为64位)

  static Future<String> sendToken(String fromAddress, String toAddress, String num, Map token, String pwd) async {
    String rpcUrl = await getNetWork();
    String privateKey = pwd;

    final client = Web3Client(rpcUrl, Client());
    var credentials = await client.credentialsFromPrivateKey(privateKey);

    final hexNum = (BigInt.parse(num)*BigInt.from(1000000000000000000)).toRadixString(16);
    String postData = '${func['transfer(address,uint256)']}${formatParam(toAddress)}${formatParam(hexNum)}';
    print("postData=>$postData");

    var rsp = await client.sendTransaction(
        credentials,
        Transaction(
            to: EthereumAddress.fromHex(token['address']),
            gasPrice: EtherAmount.inWei(Global.gasPrice),
            maxGas: Global.gasLimit,
            value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
            data: hexToBytes(postData)
        ),
        chainId: 3 // 没有这个参数会报RPCError: got code -32000 with msg "invalid sender".
    );
    print("transaction => $rsp");
    return rsp;
  }

  // 根据hash查询订单
  // 下面这个订单是没有授权交易的失败订单
  // 0x7e6c3534a5acdaf52aef4f13b2dd6cdd2f9496098cd59728c5c065fb0d5f4b7a
  static Future<Map> getTransactionByHash(String hash) async{
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_getTransactionByHash",
      "params": [hash],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rsp = await client.post(
        "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );

    Map result = jsonDecode(rsp.body);
    return result['result'];
  }

  // 获取订单中的信息
  // String bqHash + String odHash
  // 这里直接把bqHash和odHash拼接好传进来
  /**
   * 000000000000000000000000ab890808775d51e9bf9fa76f40ee5fff124dece5
   * 0000000000000000000000000000000000000000000000000000000000000300
   * 0000000000000000000000000000000000000000000000000000000000000900
   * 0000000000000000000000000000000000000000000000000000000000000000
   * 02000000600571c8000000000000000000000000000000000000000000000000
   * 1c0000000000000000000000000000000000000000000000000000000000000074d75996ead9f1eebd2e43e14fd80fe66da236f6051aba3b3f151d093cb588153d05e9a1244a41bdf3104ca0d28d5ad375731a58f200d43c0e70e5dc1959321a
   * 000000000000000000000000000000000000000000000000000000000000024e
   * 0000000000000000000000000000000000000000000000000000000000000000
   *
   */
  static Future getOrderInfo(String hash, bool isSell) async {
    String strSell = isSell ? '1' : '0';
    String postData = Global.funcHashes['getOrderInfo(bytes32,bytes32,bool)'] + hash.replaceFirst('0x', '') + formatParam(strSell);
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":Global.tempMatchAddress,
          "to": Global.tempMatchAddress,
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rpcUrl = await Global.rpcUrl();
    var rsp = await client.post(
        rpcUrl,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
//    print(rsp.body);
    return result['result'];
  }

  // 交易授权
  // function approve(address spender, uint256 value);
  // 返回1表示true，接口调用成功，0表示false失败了
  static Future approve(String token, String privateKey) async {
    String value = BigInt.from(10).pow(27) .toString();
    String postData = Global.funcHashes['approve()'] + formatParam(Global.proxy) + formatParam(value);

    String rpcUrl = await Global.rpcUrl();

    final client = Web3Client(rpcUrl, Client());
    var credentials = await client.credentialsFromPrivateKey(privateKey);

    var rsp = await client.sendTransaction(
        credentials,
        Transaction(
            to: EthereumAddress.fromHex(token),
            gasPrice: EtherAmount.inWei(Global.gasPrice),
            maxGas: Global.gasLimit,
            value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
            data: hexToBytes(postData)
        ),
        chainId: 3
    );
    return rsp.toString();

  }

/* 取消订单 - W
 * 参数1: 买单的话就是bq hash，卖单的话就是sq hash
 * od_hash: 订单哈希值
 * function cancelOrder2(bytes32 bq_hash, bytes32 od_hash);
 */
  static Future cancelOrder2(Map item,String pwd) async {
    String hash = "";
    if(item['orderType']=='卖出') {
      hash = item['sqHash'];
    } else {
      hash = item['bqHash'];
    }
    String postData = Global.funcHashes['cancelOrder2(bytes32,bytes32)'] + formatParam(hash) + formatParam(item['odHash']);

    String rpcUrl = await Global.rpcUrl();

    final client = Web3Client(rpcUrl, Client());
    var credentials = await client.credentialsFromPrivateKey(pwd);

    var rsp = await client.sendTransaction(
        credentials,
        Transaction(
            to: EthereumAddress.fromHex(Global.tempMatchAddress),
            gasPrice: EtherAmount.inWei(Global.gasPrice),
            maxGas: Global.gasLimit,
            value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
            data: hexToBytes(postData)
        ),
        chainId: 3
    );
    return rsp.toString();
  }

  static Future orderFlag(item) async {
    String postData = Global.funcHashes['orderFlag(bytes32)'] + formatParam(item['odHash']);
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":Global.tempMatchAddress,
          "to": Global.tempMatchAddress,
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rpcUrl = await Global.rpcUrl();
    var rsp = await client.post(
        rpcUrl,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    return int.parse(result['result'].replaceFirst("0x",''), radix: 16);
  }

  // 返回指定交易的收据，使用哈希指定交易，判断ETH的写操作是否成功
  // 根据返回对象中的'status'，0x1就是成功，0x0失败
  // getTransactionReceipt必须等待以太坊操作结束后，
  // 在写链的过程中，这个接口一直返回null
  static Future getTransactionReceipt(Map item) async {
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_getTransactionReceipt",
      "params": [item['txnHash']],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rpcUrl = await Global.rpcUrl();
    var rsp = await client.post(
        rpcUrl,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    return result['result'];
  }

  // 本接口即将被废弃
  static Future getSellQueue(String bqHash) async {
    String postData = Global.funcHashes['sellQueue(bytes32)'] + bqHash.padLeft(64, '0');
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":Global.tempMatchAddress,
          "to": Global.tempMatchAddress,
          "data": postData
        },
      "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rpcUrl = await Global.rpcUrl();
    var rsp = await client.post(
        rpcUrl,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);
    return result['result'];
  }

  // 获取全部交易信息
  /* 获取深度列表 - R
 * sq_hash: base-token/quote-token sell 哈希值
 * bq_hash: base-token/quote-token buy 哈希值
 *
 * 返回值:
 * od_list_sell: OrderItem 数组
 * od_list_buy: OrderItem 数组
 *
 * 注意：返回值数组固定大小是10个，返回的OrderItem中任意一个参数为0，表示结束。
 */
  static Future<List> getOrderDepth(String leftToken, String rightToken) async {
    print('start getOrderDepth');
    String bqsq = await Trade.getBQHash(leftToken, rightToken);
    String postData = Global.funcHashes['getOrderDepth(bytes32)'] + bqsq;

    print('postData=> ${postData}');
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "to": Global.tempMatchAddress,
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rpcUrl = await Global.rpcUrl();
    var rsp = await client.post(
        rpcUrl,
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
//    print('start print rsp');
//    print(rsp);
//    print('start print rsp.body');
//    print(rsp.body);
    Map result = jsonDecode(rsp.body);
    return Trade.buildOrderDeep(result['result']);
  }

  // 解析deepOrder接口返回的深度字符串
  // 第一个64位的字符串是偏移量，表示每个数字的长度
  // 第二个64位的字符串是总长度，可以不关心
  // 第三个64的字符串是卖单长度
  // 第四个64位的字符串开始就是卖单
  // 卖单结束后，就是买单的长度，也是64位字符串，后面就是买单了
  static buildOrderDeep(String str) {
    print('start buildOrderDeep');
    String data = str.replaceFirst('0x', '');
    int sell_len = BigInt.parse(data.substring(128, 192), radix: 16).toInt();
    print('sell len => ${sell_len}');
    String sell_str = data.substring(192, 192 + sell_len*4*64);
    print(sell_str);
    List sell = Trade.buildOrderItem(sell_str);
    print(sell);
    String buy_str = data.substring(64*4 + sell_len*4*64);
    List buy = Trade.buildOrderItem(buy_str);
    sell = sell.reversed.toList();
    sell.addAll(buy);
    return sell;
  }

  // 拿到卖单和买单的字符串，按照偏移量解析出来
  static List buildOrderItem(String data) {
    print('start buildOrderItem');
    int n = 4; // orderItem由几个字段构成
    int index = (data.length/256).toInt();
    int i = 0;
    List arr = [];
    while( i<index) {
      print("======================");
      String item = data.substring(i*n*64, i*n*64 + n*64);
      Decimal baseTokenAmount  = Decimal.parse((BigInt.parse(item.substring(0, 64), radix: 16)/BigInt.from(pow(10,18))).toString());
      print(baseTokenAmount);
      Decimal quoteTokenAmount = Decimal.parse((BigInt.parse(item.substring(64, 128), radix: 16)/BigInt.from(pow(10,18))).toString());
      print(quoteTokenAmount);
      Decimal amount = Decimal.parse((BigInt.parse(item.substring(128, 192), radix: 16)/BigInt.from(pow(10,18))).toString());
      print(amount);
      bool is_sell = BigInt.parse(item.substring(192), radix: 16) == BigInt.from(0)? false:true;
      print(is_sell);
      if(baseTokenAmount.toString() != '0') {
        String price = (quoteTokenAmount/baseTokenAmount).toString();
        arr.add({
          'price': price,
          'amount': amount.toString(),
          'is_sell': is_sell
        });
        print(arr);
      }
      i = i+1;
    }
    print(arr);
    return arr;
  }


  /*
  * 获取订单相关hash值, 返回值是长度为128位的一个字符串，前64位是bq_hash
 * bq_hash: base-token/quote-token buy  哈希值
 * sq_hash: base-token/quote-token sell 哈希值
 * od_hash: 订单哈希值
  */
  static Future<String> getBQHash(String leftToken, String rightToken) async {
    String postData = Global.funcHashes['getBQHash()'] + formatParam(leftToken) + formatParam(rightToken);
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":Global.tempMatchAddress,
          "to": Global.tempMatchAddress,
          "data": postData
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };

    var rsp = await client.post(
        "https://ropsten.infura.io/v3/37caa7b8b2c34ced8819de2b3853c8a2",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    Map result = jsonDecode(rsp.body);

    String  res = result['result'].replaceFirst("0x", ""); // 得到一个64字节的数据
    print(res);
    return res;
//    String sq_hash = res.substring(0,64);
//    String bq_hash = res.substring(64,128);
//    return {
//      'sq_hash': sq_hash,
//      'bq_hash': bq_hash,
//    };
  }

}
