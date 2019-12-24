import 'package:flutter/material.dart';

import 'package:youwallet/pages/tabs/tab_wallet.dart'; // 钱包引导页TabExchange
import 'package:youwallet/pages/tabs/tab_exchange.dart'; // 钱包引导页
import 'package:youwallet/pages/tabs/tab_receive.dart'; // 钱包引导页
import 'package:youwallet/pages/tabs/tab_transfer.dart'; // 钱包引导页
import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart';
import 'package:youwallet/pages/manage_wallet/wallet_guide.dart'; // 钱包引导页
import 'package:youwallet/db/sql_util.dart';

class _Item {
  String name, activeIcon, normalIcon;
  _Item(this.name, this.activeIcon, this.normalIcon);
}


///这个页面是作为四个tab页的容容器，以Tab为基础控制每个item的显示与隐藏
class ContainerPage extends StatefulWidget {

  // 实例化
  ContainerPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ContainerPageState();
  }
}


class _ContainerPageState extends State<ContainerPage> {

  List<Widget> pages; // 存放tab页面的数组

  int myIndex;

  int _selectIndex = 0; // 当前tab的索引

  final defaultItemColor = Color.fromARGB(255, 125, 125, 125);

  final itemNames = [
    _Item('首页', 'images/tab_wallet_active.png','images/tab_wallet.png'),
    _Item('Token兑换', 'images/tab_exchange_active.png','images/tab_exchange.png'),
    _Item('收款', 'images/tab_receive_active.png','images/tab_receive.png'),
    _Item('转账', 'images/tab_transfer_active.png','images/tab_transfer.png'),
  ];

  List<BottomNavigationBarItem> itemList;
  Future _future;

  List wallets = [];

  // 构造函数
//  _ContainerPageState({Key key, @required this.myIndex,}) : super(key: key);

  @override
  void initState() {
    super.initState();
    _future = getWallet();
    // 将四个tab页面初始化为一个数组pages
    if(pages == null){
      pages = [
        new TabWallet(),
        new TabExchange(),
        new TabReceive(),
        new TabTransfer()
      ];
    }
    if(itemList == null){
      itemList = itemNames
          .map((item) => BottomNavigationBarItem(
          icon: Image.asset(
            item.normalIcon,
            width: 30.0,
            height: 30.0,
          ),
          title: Text(
            item.name,
            style: TextStyle(fontSize: 10.0),
          ),
          activeIcon:
          Image.asset(item.activeIcon, width: 30.0, height: 30.0)))
          .toList();
    }

  }

  Future getWallet() async {
    var sql = SqlUtil.setTable("wallet");
    List res = await sql.get();
    this.wallets = res;
  }


//Stack（层叠布局）+ Offstage组合,解决状态被重置的问题
  Widget _getPagesWidget(int index) {
    // print(index);
    return Offstage(
      offstage: _selectIndex != index,
      child: TickerMode(
        enabled: _selectIndex == index,
        child: pages[index],
      ),
    );
  }


  @override
  void didUpdateWidget(ContainerPage oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
//    List wallets = Provider.of<Wallet>(context).items;
//    if (wallets.length == 0) {
//      Navigator.pushNamed(context, "wallet_guide");
//    }
      return Scaffold(
        body: new Stack(
          children: [
            _getPagesWidget(0),
            _getPagesWidget(1),
            _getPagesWidget(2),
            _getPagesWidget(3),
          ],
        ),
        backgroundColor: Color.fromARGB(255, 248, 248, 248),
        bottomNavigationBar: BottomNavigationBar(
          items: itemList,
          onTap: (int index) {
            print('当前tab索引=> ${index}');
            setState(() {
              _selectIndex = index;
            });
          },
          iconSize: 24,
          //图标大小
          currentIndex: _selectIndex,
          //选中后，底部BottomNavigationBar内容的颜色(选中时，默认为主题色)（仅当type: BottomNavigationBarType.fixed,时生效）
          fixedColor: Color.fromARGB(255, 0, 188, 96),
          type: BottomNavigationBarType.fixed,
        ),
      );
    }
}