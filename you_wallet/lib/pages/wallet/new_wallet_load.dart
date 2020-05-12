
import 'package:flutter/material.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'package:web3dart/crypto.dart';
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:web3dart/credentials.dart';
import "package:hex/hex.dart";
//import 'package:stellar_hd_wallet/stellar_hd_wallet.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youwallet/service/local_authentication_service.dart';
import 'package:youwallet/service/service_locator.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/widgets/customButton.dart';


import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' as myWallet;


class LoadWallet extends StatefulWidget {

  final arguments;
  LoadWallet({Key key ,this.arguments}) : super();

  @override
  State<StatefulWidget> createState()  => new Page(arguments: this.arguments);

}


class Page extends State<LoadWallet> {

  Page({this.arguments});

  String name;
  String randomMnemonic;
  String privateKey;
  TextEditingController _name = TextEditingController();
  TextEditingController _key = TextEditingController();
  final LocalAuthenticationService _localAuth = locator<LocalAuthenticationService>();
  final globalKey = GlobalKey<ScaffoldState>();
  Map arguments;


  @override
  // override是重写父类中的函数 每次初始化的时候执行一次，类似于小程序中的onLoad
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (this.arguments == null) {
      print("没有参数");
    } else {
      String key = Provider.of<myWallet.Wallet>(context).exportPrivateKey(this.arguments['address']);
      print('查询到的key=》${key}');
      setState(() {
        this._key.text = key;
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        initialIndex: 1,
        child: Scaffold(
          key: globalKey,
          appBar: buildAppBar(context),
          body: new TabBarView(
            children: [
              buildPage('输入助记词,用空格分隔'),
              buildKeyPage('输入明文私钥'),
            ],
          ),
        )
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('恢复身份'),
        actions: appBarActions(),
        bottom: new TabBar(
            tabs: [
              new Tab(text: '助记词'),
              new Tab(text: '私钥'),
            ],
          onTap: (index) {
            //your currently selected index
            print('current index => ${index}');
          },
        )
    );
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(Icons.camera_alt ),
          onPressed: () {
            print("123");
//            _localAuth.authenticate().then((result){
//              print(result);
//            });
          },
        ),
      )
    ];
  }

  // 构建助记词page
  buildPage(placeholder){
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.all(32.0), // 四周填充边距32像素
            color: Colors.white,
            child: new Column(
              children: <Widget>[
                buildText(placeholder),
                new TextField(
                  controller: this._name,
                  maxLines: 3,
                  decoration: InputDecoration(
                      filled: true,
                      hintText: placeholder,
                      fillColor: Colors.black12,
                      contentPadding: new EdgeInsets.all(6.0), // 内部边距，默认不是0
                      border:InputBorder.none, // 没有任何边线
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide(
                          width: 0, //边线宽度为2
                        ),
                      )
                  ),

                  onSubmitted: (text) {
                    print('change $text');
                  },
                ),
              ],
            )
          ),
          new CustomButton(
              content: '添加账户密码',
              onSuccessChooseEvent:(res){
                this.loadWalletByMnemonic();
              }
          )
//          new Padding(
//              padding: new EdgeInsets.all(30.0),
//              child: Column(
//                children: <Widget>[
//                  Text("免密设制"),
//                  Text("目前不支持指纹识别，直接点击指纹图标即可")
//                ],
//              )
//          ),
//          new Container(
//            margin: const EdgeInsets.only(top: 10.0),
//            child: GestureDetector(
//               child: new Image.asset(
//                   'images/fingerprint.png'
//               ),
//              onTap: () async {
//                 saveWallet();
//              },
//              )
//          ),
        ],
      ),
    );
  }

  // 构建私钥page
  buildKeyPage(placeholder){
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
              padding: const EdgeInsets.all(32.0), // 四周填充边距32像素
              color: Colors.white,
              child: new Column(
                children: <Widget>[
                  buildText(placeholder),
                  new TextField(
                    controller: this._key,
                    maxLines: 3,
                    decoration: InputDecoration(
                        filled: true,
                        hintText: placeholder,
                        fillColor: Colors.black12,
                        contentPadding: new EdgeInsets.all(6.0), // 内部边距，默认不是0
                        border:InputBorder.none, // 没有任何边线
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          borderSide: BorderSide(
                            width: 0, //边线宽度为2
                          ),
                        )
                    ),

                    onSubmitted: (text) {
                      print('change $text');
                    },
                  ),
                ],
              )
          ),
          new CustomButton(
              content: '添加账户密码',
              onSuccessChooseEvent:(res){
                this.saveWalletByKey('');
              }
          ),
//          new Padding(
//              padding: new EdgeInsets.all(30.0),
//              child: new Text('免密设置')
//          ),
//          new Container(
//              margin: const EdgeInsets.only(top: 10.0),
//              child: GestureDetector(
//                child: new Image.asset(
//                    'images/fingerprint.png'
//                ),
//                onTap: () async {
//                  saveWalletByKey();
//                },
//              )
//          ),
        ],
      ),
    );
  }


  buildText(p) {
    if (p == '输入明文私钥') {
      return new Container(
        child: new Text('输入私钥文件内容至输入框，或通过扫描私钥内容生成的二维码录入，注意字符大小写。'),
      );
    } else {
      return new Container(
        child: null
      );
    }
  }

  _getWalletName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("new_wallet_name");
    print("new name => ${name}");
    setState(() {
      this.name = name;
    });
  }

  // 通过助记词导入
  void loadWalletByMnemonic() async {

    if (this._name.text.length == 0) {
      this.showSnackbar('请输入助记词');
      return ;
    }

    if (this._name.text.split(' ').length != 12) {
      this.showSnackbar('助记词是12个单词，你输入的是${this._name.text.split(' ').length}个单词');
      return ;
    }

    String privateKey = TokenService.getPrivateKey(this._name.text);

    Map item = {
      'privateKey': privateKey,
      'mnemonic': this._name.text,
    };

    this.doSave(item);
  }

  // 通过私钥 key导入钱包
  void saveWalletByKey(String pwd) async {

    if (this._key.text.length == 0) {
      this.showSnackbar('私钥不能为空');
      return;
    }

    if (this._key.text.length != 64) {
      this.showSnackbar('标准密钥长度64位，你的是${this._key.text.length}位');
      return;
    }

    // 使用账户密码对私钥进行AES对称
    // var encryptText = await FlutterAesEcbPkcs5.encryptString(this._key.text, pwd);
    // print('加密后的私钥为=》${encryptText}');
    // flutter 的aes加密库加密后解密失败，蛋疼

    Map item = {
      'privateKey': this._key.text,
      'mnemonic': '',
    };

    this.doSave(item);
  }

  // 跳转密码设置页面
  void doSave(Map item) {
    Navigator.of(context).pushNamed('password').then((data){
      print(data);
      if (data == null) {
        print('input nothing');
      } else {
        this.saveDone(item, data);
      }
    });
  }

  /// 保存用户的钱包到本地数据库
  void saveDone(Map item, String pwd) async {
    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog( //调用对话框
            text: '保存钱包...',
          );
        });

    int id;
    try {
      id = await Provider.of<myWallet.Wallet>(context).add(item,pwd);
    } catch (e) {
      print(e);
      Navigator.pop(context);
    }

    if (id > 0) {
       Navigator.pushNamedAndRemoveUntil(context, "wallet_success", (route) => route == null);
      // 删除路由栈中除了顶级理由之外的路由
      // 然后添加目标页面进入路由，并且跳转

    } else {
      this.showSnackbar('钱包保存失败');
    }
  }

  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

}
