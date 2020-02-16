import 'package:flutter/material.dart';
import 'package:youwallet/model/wallet.dart';
import 'package:provider/provider.dart';


class ManageWallet extends StatefulWidget {
  final arguments;

  ManageWallet({Key key ,this.arguments}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState

    return new Page();
  }
}

class Page extends State<ManageWallet> {

  List wallets = [];
  String currentAddress = "";

  @override // override是重写父类中的函数
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<Wallet>(
          builder: (context, Wallet, child) {
            return new ListView(
              children: Wallet.items.map((item) => walletCard(item)).toList()
            );
          },
        ),
//        child: new ListView(
//          children: this.wallets.map((item) => walletCard(item)).toList()
//        ),
      ),
    );
  }

  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('钱包管理'),
      actions: this.appBarActions(),
      //leading: new Icon(Icons.account_balance_wallet),
    );
  }

  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(Icons.add_circle_outline ),
          onPressed: () {
            Navigator.pushNamed(context, "wallet_guide");
          },
        ),
      )
    ];
  }


  Widget walletCard(item) {
    print(item);
    String name = item['name'].length > 0 ? item['name']:'Account${item['id']}';
    return new Card(
        color: Colors.white, //背景色
        child: new Container(
              padding: const EdgeInsets.all(28.0),
              child: new Row(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(right: 16.0),
                    child: Consumer<Wallet>(
                      builder: (context, wallet, child) {
                        return new Radio(
                          groupValue: wallet.currentWallet,
                          activeColor: Colors.blue,
                          value: item['address'],
                          onChanged: (v) {
                            print(v);
                            Provider.of<Wallet>(context).changeWallet(v);
                          },
                        );
                      },
                    ),
                  ),
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        new Text(
                          name,
                          style: new TextStyle(fontSize: 32.0, color: Colors.black),
                        ),
                        new Text(item['address']),
                      ],
                    ),
                  ),
                  new Container(
                    child: new IconButton(
                      icon: new Icon(Icons.settings),
                      onPressed: () {
                        print(item);
                        Navigator.pushNamed(context, "wallet_export",arguments:{
                          'address': item['address'],
                        });
                      },
                    ),

                )
                ],
              )
        )
    );


  }
}
