import 'package:flutter/material.dart';
import 'package:youwallet/widgets/tokenList.dart';
import 'package:flutter/services.dart';
import 'package:youwallet/bus.dart';

import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/model/network.dart';
import 'package:youwallet/model/wallet.dart' as walletModel;
import 'package:youwallet/db/sql_util.dart';
import 'package:youwallet/db/provider.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youwallet/global.dart';
import 'package:youwallet/widgets/loadingDialog.dart';

class TabWallet extends StatefulWidget {


  @override
  State<StatefulWidget> createState() => new Page();
}

class Page extends State<TabWallet> {

  List<Map> tokenArr = [];
  List<Map> wallets = []; // 用户添加的钱包数组
  int current_wallet = 0;
  String current_wallet_address = "";
  String _balance = '0Eth';


//  @override
//  void didUpdateWidget(ContainerPage oldWidget) {
//    super.didUpdateWidget(oldWidget);
//  }

  @override // override是重写父类中的函数
  void initState()  {
    super.initState();
    // _getWallets();
    // 监听钱包切换事件
//    eventBus.on<WalletChangeEvent>().listen((event) {
//      print(event.address);
//      this.wallets.forEach((f){
//        if (f['address'] == event.address) {
//          setState(() {
//            this.current_wallet = f['id'] - 1;
//          });
//        }
//      });
//    });
  }

  @override // 页面回退时候触发
  void deactivate() async {
//    var bool = ModalRoute.of(context).isCurrent;
//    if (bool) {
//      await _getWallets();
//      String balance = await TokenService.getBalance(Provider.of<walletModel.Wallet>(context).currentWallet);
//      setState(() {
//        _balance = balance + 'Eth';
//      });
//    }
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  // 构建页面
  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: new ListView(
          children: <Widget>[
            topCard(context),
            listTopBar(context),
            new Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0), // 四周填充边距32像素
              child: Consumer<Token>(
                builder: (context, Token, child) {
                  return tokenList(arr: Token.items,network: Provider.of<Network>(context).network, currentWalletObject: Provider.of<walletModel.Wallet>(context).currentWalletObject);
                },
              ),
            )
          ],
        ),
      ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text(
                    'sibbay',
                    style: TextStyle( fontWeight: FontWeight.bold, ),
                  ),
                  accountEmail: Text('sibbay@example.com'),
                  //currentAccountPicture: CircleAvatar( backgroundImage: NetworkImage('https://upyun-assets.ethfans.org/assets/ethereum-logo-fe43a240b78711a6d427e9638f03163f3dc88ca8c112510644ce7b5f6be07dbe.png')),
                  currentAccountPicture : Icon(IconData(0xe648, fontFamily: 'iconfont'),size: 60.0),
                  decoration: BoxDecoration(
                      color: Colors.black12,
//                      image: DecorationImage(
//                        image: NetworkImage( 'url'),
//                        fit: BoxFit.cover,
//                        colorFilter: ColorFilter.mode( Colors.yellow.withOpacity(0.3), BlendMode.lighten, ),
//                      )
                  ),
                ),

                ListTile(
                  title: Text('切换网络'),
                  leading: Icon(Icons.network_check),
                  onTap: () {
                    Navigator.pushNamed(context, "set_network");
                  },
                ),
                ListTile(
                  title: Text('检查更新'),
                  leading: Icon(Icons.update),
                  onTap: () {
                    Navigator.of(context).pop();
//                    showDialog<Null>(
//                        context: context, //BuildContext对象
//                        barrierDismissible: false,
//                        builder: (BuildContext context) {
//                          return new LoadingDialog( //调用对话框
//                            text: '检查中...',
//                          );
//                        });
//                    Navigator.of(context).pop();
                    final snackBar = new SnackBar(content: new Text('没有检测到新版本'));
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                ),
                ListTile(
                  title: Text('进入调试'),
                  leading: Icon(Icons.adb),
                  onTap: () {
                    Navigator.pushNamed(context, "debug_page");
                  },
                ),
                ListTile(
                  title: Text('清空缓存'),
                  leading: Icon(Icons.cached),
                  onTap: () async {
                    final provider = new ProviderSql();
                    await provider.clearCache();
                    final snackBar = new SnackBar(content: new Text('数据清除成功，关闭程序重新进入'));
                    Scaffold.of(context).showSnackBar(snackBar);
                  },
                ),
                ListTile(
                  title: Text('意见反馈'),
                  leading: Icon(Icons.feedback),
                  onTap: () async {
                    const url='https://github.com/youwallet/wallet/issues';
                    await launch(url);
                  },
                ),
            ],
          ),
        )
    );
  }

  // 构建AppBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('youwallet'),
        actions: this.appBarActions(),
    );
  }


  // 定义bar右侧的icon按钮
  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: new Icon(IconData(0xe61d, fontFamily: 'iconfont')),
          onPressed: () {
            Global.scan(context);
          },
        ),
      )
    ];
  }

  // 构建顶部卡片
  Widget topCard(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.all(16.0), // 四周填充边距32像素
        margin: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        decoration: new BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  "images/homebk.png",
              ),
              fit: BoxFit.fill
            ),
        ),
        child: Consumer<walletModel.Wallet>(
          builder: (context, Wallet, child) {
            return  new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          new Text(
                              Wallet.currentWalletObject['name'].length==0?'Account${Wallet.currentWalletObject['id']}':Wallet.currentWalletObject['name'],
                              // Wallet.currentWalletObject['name']??'--',
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0
                              )
                          ),
                          new IconButton(
                            icon: Icon(IconData(0xe600, fontFamily: 'iconfont'),color: Colors.white,),
                            onPressed: () {
                              eventBus.fire(TabChangeEvent(2));
//                              print(item);
//                              Navigator.pushNamed(context, "token_info",arguments:{
//                                'address': item['address'],
//                              });
                            },
                          ),
                        ],
                      ),
                      new IconButton(
                        icon: new Icon(
                            Icons.settings,
                            color: Colors.white
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "manage_wallet",arguments:{});
                        },
                      ),
                    ],
                  ),
                  new Text(
                      Global.maskAddress(Wallet.currentWallet),
                      style: new TextStyle(
                          color: Colors.white
                      )
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(''),
                      new Text(
                          Wallet.currentWalletObject['balance'] + 'ETH',
                          style: new TextStyle(
                              fontSize: 32.0, color: Colors.white
                          )
                      ),
                    ],
                  ),
                ]
            );
          },
        ),
    );
  }

  // 构建列表的表头菜单
  Widget listTopBar(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(left: 16.0, right:16.0, top: 0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text('Token'),
          new IconButton(
              icon: new Icon(Icons.add_circle_outline ),
              onPressed: () {
                  Navigator.pushNamed(context, "add_wallet");
              },
          ),
        ],
      ),
    );
  }

  // 首页下拉刷新
  // 刷新钱包的ETH余额
  // 刷新每个token的余额
  Future<void> _refresh() async {
    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog( //调用对话框
            text: '刷新中...',
          );
        });
    String address = Provider.of<walletModel.Wallet>(context).currentWalletObject['address'];
    // 更新钱包的ETH余额
    await Provider.of<walletModel.Wallet>(context).updateWallet(address);
    // 更新钱包里面多个token的余额
    await Provider.of<Token>(context).updateBalance(address);
    final snackBar = new SnackBar(content: new Text('刷新结束'));
    Scaffold.of(context).showSnackBar(snackBar);
    Navigator.pop(context);
  }
}


