import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youwallet/db/provider.dart';

// 类的名字需要大写字母开头
class UserMenu extends StatelessWidget {

  UserMenu({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(
              'youWallet',
              style: TextStyle( fontWeight: FontWeight.bold, color: Colors.white),
            ),
            accountEmail: Text(
                'sibbay@example.com',
                style: TextStyle( fontWeight: FontWeight.bold, color: Colors.white)
            ),
            //currentAccountPicture: CircleAvatar( backgroundImage: NetworkImage('https://upyun-assets.ethfans.org/assets/ethereum-logo-fe43a240b78711a6d427e9638f03163f3dc88ca8c112510644ce7b5f6be07dbe.png')),
//            currentAccountPicture: Icon(
//                IconData(0xe648, fontFamily: 'iconfont'),
//                size: 60.0
//            ),
            currentAccountPicture: Image(
                image: AssetImage("images/logo.png"),
                width: 100.0
            ),
            decoration: BoxDecoration(
              color: Colors.lightBlue,
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
          ListTile(
            title: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('版本号'),
                Text('v0.0.4')
              ],
            ),
            leading: Icon(Icons.exit_to_app),
            onTap: () {
//              final snackBar = new SnackBar(content: new Text('没有检测到新版本'));
//              Scaffold.of(context).showSnackBar(snackBar);
            },
          ),
        ],
      ),
    );
  }
}

