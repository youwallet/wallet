
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

  static final tempMatchAddress= "0x3762fF9389feaE5C7C00aC765C1f0056f9B53eCB";

  // 水龙头合约地址
  // static final tempMatchAddress = "0x81b7e08f65bdf5648606c89998a9cc8164397647";

  // 获取订单匹配情况的合约
  static final hybridExchangeAddress = "0xC34528755ACBcf1872FeE04c5Cf4BbE112cdafA2";


  // 收取交易费的账户，测试阶段用SHT的合约账户代替
   static final taxAddress = "0x3d9c6c5a7b2b2744870166eac237bd6e366fa3ef";

//  static final taxAddress = "0x3D9c6C5A7b2B2744870166EaC237bd6e366fa3ef";

  // 这个定义多大?
  static final gasTokenAmount = "0000000000000000000000000000000000000000000000000000000000000000";

  static final Map func = {
    'filled(bytes32)':'0x288cdc91',
    'getOrderQueueInfo(address,address,bool)': '0x22f42f6b',
    'transfer(address,uint256)': '0xa9059cbb'
  };

  // Trade内的私有变量
  String tokenA = '';
  String tokenAName = ''; // 左边token的名字
  String tokenB = '';
  String tokenBName = ''; // 右边token的名字
  String amount = '1';
  String price = '';
  bool   isBuy = true;
  String trader = ""; // 当前交易的用户钱包地址
  String configData = ""; // 协议版本号码、是否买单，计算配置信息
  String privateKey = "";

  String rpcUrl = "https://ropsten.infura.io/";

  String odHash = "";  // od_hash,用来查询每个订单的匹配情况

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
     print('baseToken => ${baseToken}');
     print('isBuy => ${isBuy}');
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
    // 参数编码中0表示false，1表示你true
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
          "from": tempMatchAddress, // 这里的form随便写一个
          "to": tempMatchAddress,
          "data": "0xfeee047e000000000000000000000000000000000000000000000000000000000000000${configData}"
        },
        "latest"
      ],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rsp = await client.post(
        "https://ropsten.infura.io/",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    print("订单的getConfigData => ${rsp.body}");
    Map result = jsonDecode(rsp.body);
    //    return result['result'].replaceFirst('0x', '');
    return '020000005ffb17bc000000000000000000000000000000000000000000000000';
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
   Future<String> takeOrder() async{

    String functionName = '0xefe29415';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.trader =  formatParam(prefs.getString("currentWallet"));
//     this.trader =  formatParam('0xAB890808775D51e9bF9fa76f40EE5fff124deCE5');
    print('当前下单的钱包地址 =》 ${this.trader}');

    this.configData = await getConfigData(this.isBuy);

    String signature = await getConfigSignature();
    /**
     * trader 钱包地址
     * configData 买单卖单计算的config
     * signature  签名
     * taxAddress 收手续费的一个地址
     */
    String postData = functionName + trader + formatParam(this.amount) + formatParam(this.price) + gasTokenAmount;
    postData = postData + this.configData + signature + formatParam(this.tokenA) + formatParam(this.tokenB) + formatParam(taxAddress);

    print("takeOrder post => ${postData}");
    /**
     *  0xefe29415000000000000000000000000ab890808775d51e9bf9fa76f40ee5fff124dece5000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000020000005ff0603c000000000000000000000000000000000000000000000000000000000000000000000000e898663A2CbDf7a371bB4B6a5dd7aC93d4505C9a0000000000000000000000002e01154391F7dcBf215c77DBd7fF3026Ea7514ce0000000000000000000000003d9c6c5a7b2b2744870166eac237bd6e366fa3ef
     *
     *  trader=000000000000000000000000ab890808775d51e9bf9fa76f40ee5fff124dece5
     *  formatParam(this.amount) = 0000000000000000000000000000000000000000000000000000000000000001
     *  formatParam(this.price) = 0000000000000000000000000000000000000000000000000000000000000001
     *  gasTokenAmount = 0000000000000000000000000000000000000000000000000000000000000000
     */


    final client = Web3Client(rpcUrl, Client());
    var credentials = await client.credentialsFromPrivateKey(privateKey);

    try {
      var rsp = await client.sendTransaction(
          credentials,
          Transaction(
              to: EthereumAddress.fromHex(tempMatchAddress),
              gasPrice: EtherAmount.inWei(BigInt.from(20000000000)),
              maxGas: 7000000,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
              data: hexToBytes(postData)
          ),
          chainId: 3
      );
      print("transaction => ${rsp}");
      await client.dispose();
      this.txnHash = rsp;
      await this.saveTrader();
      return this.txnHash;
    } catch (e) {
      print("catch error =》 ${e}");
      return e.toString();
    }

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
          "from": tempMatchAddress,
          "to": tempMatchAddress, // 合约地址
          "data": postData
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
    print("getConfigSignature body =>${result}");
    return result['result'].replaceFirst("0x", "");
  }

  // 调用web3dart，对od_hash使用私钥进行签名，这一步必须在客户端做
  Future<Map> ethSign(String od_hash) async {
    String privateKey = await loadPrivateKey();
    print("ethSign od_hash =》54793c08f2aa87ec02c025fbbfa7eee9ac8665088e0a28a17428a0269934f807");
    print("ethSign hexToBytes(od_hash) =》${hexToBytes('54793c08f2aa87ec02c025fbbfa7eee9ac8665088e0a28a17428a0269934f807')}");
    final key = EthPrivateKey(hexToBytes(privateKey));
    //final signature = await key.sign(hexToBytes(od_hash), chainId: 3);
    //final signature = await key.sign(hexToBytes('54793c08f2aa87ec02c025fbbfa7eee9ac8665088e0a28a17428a0269934f807'));
    //final signature = await key.sign('54793c08f2aa87ec02c025fbbfa7eee9ac8665088e0a28a17428a0269934f807');
    final signature = await key.signPersonalMessage(hexToBytes(od_hash));
    print("ethSign signature =》${signature}");
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

    var sql = SqlUtil.setTable("wallet");
    var map = {'address': address};
    List json = await sql.query(conditions: map);
    print("json => ${json}");
    this.privateKey = json[0]['privateKey'];
    print('钱包地址 => ${address}');
    print('钱包私钥 => ${this.privateKey}');
    return this.privateKey;
  }

  // static 方法获取用户私钥
  static Future<String> getPrivateKey() async{
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
   Future<Map> getBQODHash() async {

    String functionName = '0xefe331cf';

    // 此时还没有signature字段，所以随便填充三个32byte的字段
    String signature = this.configData + this.configData + this.configData;
    print('getBQODHash functionName             =》${functionName}');
    print('getBQODHash this.trader              =》${this.trader}');
    print('getBQODHash formatParam(this.amount) =》${formatParam(this.amount)}');
    print('getBQODHash formatParam(this.price)  =》${formatParam(this.price)}');
    print('getBQODHash gasTokenAmount           =》${gasTokenAmount}');
    print('getBQODHash this.configData          =》${this.configData}');
    print('getBQODHash signature                =》${signature}');
    print('getBQODHash formatParam(this.tokenA) =》${formatParam(this.tokenA)}');
    print('getBQODHash formatParam(this.tokenB) =》${formatParam(this.tokenB)}');
    print('getBQODHash formatParam(taxAddress)  =》${formatParam(taxAddress)}');
    String postData = functionName + this.trader + formatParam(this.amount) + formatParam(this.price) + gasTokenAmount + this.configData + signature + formatParam(this.tokenA) + formatParam(this.tokenB) + formatParam(taxAddress);

    print('getBQODHash postData=》${postData}');
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":tempMatchAddress,
          "to": tempMatchAddress,
          "data": postData
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
    print("getBQODHash =》 ${rsp.body}");
    Map result = jsonDecode(rsp.body);

    String  res = result['result'].replaceFirst("0x", ""); // 得到一个64字节的数据
    String bq_hash = res.substring(0,64);
    String od_hash = res.substring(64);
    print("bq_hash =》 ${bq_hash}");
    print("od_hash =》 ${od_hash}");
    this.odHash = od_hash;
    return {
      'od_hash': od_hash,
      'bq_hash': bq_hash
    };
  }

  Future<void> saveTrader() async {
    var sql = SqlUtil.setTable("trade");
    String sql_insert ='INSERT INTO trade(orderType, price, amount, token,tokenName, baseToken,baseTokenname, txnHash, odHash, createtime) VALUES(?, ?, ?, ?,?,?,?,?,?,?)';
    String orderType = '';
    if (this.isBuy) {
      orderType = '买入';
    } else {
      orderType = '卖出';
    }
    List list = [orderType,this.price, this.amount, this.tokenA,this.tokenAName,this.tokenB,this.tokenBName,this.txnHash,this.odHash,DateTime.now().millisecondsSinceEpoch];
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

  /// 获取订单匹配情况
  static Future getFilled(String odHash) async {

    String postData = func['filled(bytes32)'] + odHash;
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":hybridExchangeAddress,
          "to": hybridExchangeAddress,
          "data": postData
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
    print("getFilled =》 ${rsp.body}");
  }

  // 0x22f42f6b
  // 根据token和basetoken获取订单队列
  static Future getOrderQueueInfo(String baseToken, String quoteToken, bool isSell) async {
    String functionName = func['getOrderQueueInfo(address,address,bool)'];
    String strSell = isSell ? '1' : '0';
    String params = formatParam(baseToken) + formatParam(quoteToken) + formatParam(strSell);
    String postData = functionName + params;
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_call",
      "params": [
        {
          "from":tempMatchAddress,
          "to": tempMatchAddress,
          "data": postData
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
    print("getOrderQueueInfo =》 ${rsp.body}");

  }

  static Future<String> getNetWork() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String network =  prefs.getString('network');
    return 'https://' + network + '.infura.io/';
  }


  // 自定义转账
  // data的组成，
  // 0x + 要调用的合约方法的function signature
  // + 要传递的方法参数，每个参数都为64位
  // (对transfer来说，第一个是接收人的地址去掉0x，第二个是代币数量的16进制表示，去掉前面0x，然后补齐为64位)

  static Future<String> sendToken(String fromAddress, String toAddress, String num, Map token) async {
    String rpcUrl = await getNetWork();
    String privateKey = await getPrivateKey();

    final client = Web3Client(rpcUrl, Client());
    var credentials = await client.credentialsFromPrivateKey(privateKey);

    // 用户输入的是10进制的整数，这里要根据该token的小数位数计算它的16进制
    // 先直接使用10进制
    //    String tokenNum = num + padingZero(token['decimals']);
    //    print("tokenNum => ${tokenNum}");
    //    print("token['address'] => ${token['address']}");

    String postData = '${func['transfer(address,uint256)']}${formatParam(toAddress)}${formatParam(num)}';
    print("postData=>${postData}");
    try {
      var rsp = await client.sendTransaction(
          credentials,
          Transaction(
              to: EthereumAddress.fromHex(token['address']),
              gasPrice: EtherAmount.inWei(BigInt.from(1000000000)),
              maxGas: 7000000,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0),
              data: hexToBytes(postData)
          ),
          chainId: 3 // 没有这个参数会报RPCError: got code -32000 with msg "invalid sender".
      );
      print("transaction => ${rsp}");
      return rsp;
    } catch (e) {
      print("catch error =》 ${e}");
      return e.toString();
    }
  }

  // 根据hash查询订单
  static Future<String> getTransactionByHash(String hash) async{
    var client = Client();
    var payload = {
      "jsonrpc": "2.0",
      "method": "eth_getTransactionByHash",
      "params": [hash],
      "id": DateTime.now().millisecondsSinceEpoch
    };
    var rsp = await client.post(
        "https://ropsten.infura.io/",
        headers:{'Content-Type':'application/json'},
        body: json.encode(payload)
    );
    print("根据订单hash查询状态 => ${rsp.body}");
    Map result = jsonDecode(rsp.body);
    return result['result']['blockHash'];
  }


}
