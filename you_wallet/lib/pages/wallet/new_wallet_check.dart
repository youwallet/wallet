
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:web3dart/credentials.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart' as myWallet;
import 'package:youwallet/pages/tabs.dart';

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

  @override // override是重写父类中的函数 每次初始化的时候执行一次，类似于小程序中的onLoad
  void initState() {
    super.initState();
    setRandomMnemonic();
  }

  void setRandomMnemonic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String randomMnemonic = prefs.getString("randomMnemonic");
    print("助记词=》${randomMnemonic}");
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

              RaisedButton(
                  child: Text('清空重试',
                      style: new TextStyle(
                        color: Colors.white
                  )),
                  color: Colors.lightBlue,
                  onPressed: () {
                    this._name.text = ""; // 设置初始值
                    this.randomMnemonicAgain = [];
                    this.setRandomMnemonic();

                  },
              ),
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
        child: Text(item)
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
      print("助记词确认ok，生成钱包，回到首页");
      this.showSnackbar('钱包添加成功');

      String privateKey = TokenService.getPrivateKey(this._name.text);

      EthereumAddress ethereumAddress = await TokenService.getPublicAddress(privateKey);
      String address = ethereumAddress.toString();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String name = await prefs.getString("new_wallet_name");

      Map obj = {
        'privateKey': privateKey,
        'address': address,
        'name': name,
        'mnemonic': randomMnemonic,
        'balance': ''
      };

      int id = await Provider.of<myWallet.Wallet>(context).add(obj);
      print('insert into id => ${id}');

      await prefs.setString("currentWallet", address);
      Navigator.pushNamed(context, "/");
    } else {
      Navigator.pop(context);
      if (this.randomMnemonic.length == 0) {
        print("助记词点击完毕，但是不一致");
        print(this._name.text);
        print(randomMnemonic);
      }
    }
  }

  void afterCreateWallet(String address) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("current_wallet_address", address);
//    Navigator.pushNamed(context, "tabs");
    Navigator.of(context).pushReplacementNamed("wallet_success");
  }
}
