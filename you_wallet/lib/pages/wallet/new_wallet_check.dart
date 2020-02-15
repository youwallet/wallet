
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:web3dart/credentials.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' as myWallet;
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:youwallet/util/md5_encrypt.dart';

class WalletCheck extends StatefulWidget {
  TokenService _tokenService;
  @override
  Page createState()  => Page(this._tokenService);
}

class Page extends State<WalletCheck> {

  Page(this._tokenService);

  List randomMnemonic = [];
  List randomMnemonicAgain = [];
  TextEditingController _name = TextEditingController();
  TokenService _tokenService;

  final globalKey = GlobalKey<ScaffoldState>();

  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setRandomMnemonic();
  }

  void setRandomMnemonic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String randomMnemonic = prefs.getString("randomMnemonic");
    print("助记词=》${randomMnemonic}");
    print("私钥  =》${TokenService.getPrivateKey(randomMnemonic)}");

//    String privateKey = TokenService.getPrivateKey(randomMnemonic);
//    String passwordMd5 = Md5Encrypt('123456').init();
//    print("password md5 =》${passwordMd5}");
//    String encryptPrivateKey = await FlutterAesEcbPkcs5.encryptString(privateKey, passwordMd5);
//    String encryptMnemonic = await FlutterAesEcbPkcs5.encryptString(randomMnemonic.toString(), passwordMd5);
//    print('this is encryptPrivateKey => ${encryptPrivateKey}');
//    print('this is encryptMnemonic => ${encryptMnemonic}');

    setState(() {
      this.randomMnemonic = randomMnemonic.split(' ');
      this.randomMnemonic.shuffle();
//      this._name.text = randomMnemonic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: globalKey,
        appBar: AppBar(
          title: Text("确认助记词"),
        ),
        body: new Container(
          padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                margin: const EdgeInsets.only(bottom: 30.0),
                child: new Image.asset(
                    'images/new_wallet.png'
                ),
              ),
              new TextField(
                controller: this._name,
                maxLines: 3,
                decoration: InputDecoration(
                    filled: true,
                    hintText: "请依次点击助记词",
                    enabled: false,
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
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: this.randomMnemonic.map((item) => buildItem(item)).toList()
              ),
              new MaterialButton(
                color: Colors.blue,
                textColor: Colors.white,
                minWidth: 150,
                child: new Text('清空重试'),
                onPressed: () {
                  this._name.text = ""; // 设置初始值
                  this.randomMnemonicAgain = [];
                  this.setRandomMnemonic();
                },
              ),
//              RaisedButton(
//                  child: Text('清空重试',
//                      style: new TextStyle(
//                        color: Colors.white
//                  )),
//                  minWidth:150.0,
//                  color: Colors.lightBlue,
//                  onPressed: () {
//                    this._name.text = ""; // 设置初始值
//                    this.randomMnemonicAgain = [];
//                    this.setRandomMnemonic();
//
//                  },
//              ),
            ],
          ),
        )
    );
  }

  Widget buildItem(item){
    return Chip(
      label: InkWell(
        onTap: () {
          this.clickItem(item);
        },
        child: Text(item,style: new TextStyle(fontSize: 18.0))
      )
    );
  }

  // 点击助记词
  void clickItem(item) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String randomMnemonic = prefs.getString("randomMnemonic");
    setState((){
      this.randomMnemonicAgain.add(item);
      this._name.text = this.randomMnemonicAgain.reduce((a,b)=>(a + " " +b));
      this.randomMnemonic.remove(item);
    });

    print(this.randomMnemonic.length);
    if (this.randomMnemonic.length > 0) {
      return ;
    }

    if (this._name.text == randomMnemonic) {
      print("助记词备份输入一致");
      // 助记词和私钥在这里加密
      Navigator.of(context).pushNamed('password').then((data){
        this.saveWallet(data);
      });

    } else {
      Navigator.pop(context);
      if (this.randomMnemonic.length == 0) {
        print("助记词点击完毕，但是不一致");
        print(this._name.text);
        print(randomMnemonic);
      }
    }
  }

  void saveWallet(String passWord) async {
    print('this is password => ${passWord}');

    String privateKey = TokenService.getPrivateKey(this._name.text);
//    EthereumAddress ethereumAddress = await TokenService.getPublicAddress(privateKey);
//    String address = ethereumAddress.toString();
//
//    print('this is privateKey     => ${privateKey}');
//    print('this is randomMnemonic => ${this._name.text}');
//
//    SharedPreferences prefs = await SharedPreferences.getInstance();
//    String name = prefs.getString("new_wallet_name");
//
//    String passwordMd5 = Md5Encrypt(passWord).init();
//    String encryptPrivateKey = await FlutterAesEcbPkcs5.encryptString(privateKey, passwordMd5);
//    String encryptMnemonic   = await FlutterAesEcbPkcs5.encryptString(this._name.text, passwordMd5);
//
//    print('this is encryptPrivateKey => ${encryptPrivateKey}');
//    print('this is encryptMnemonic => ${encryptMnemonic}');

    Map obj = {
      'privateKey': privateKey,
      'mnemonic': this._name.text
    };

    int id = await Provider.of<myWallet.Wallet>(context).add(obj,passWord);
    print('insert into id => ${id}');
    
    Navigator.of(context).pushReplacementNamed("wallet_success");
  }


}
