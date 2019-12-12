import 'package:youwallet/pages/splash/splash.dart'; // 启动页面
import 'package:youwallet/debug_page.dart'; // 全局调试
import 'package:youwallet/pages/login/login.dart'; // 解锁登录
import 'package:youwallet/wallet_guide.dart'; // 钱包引导页

// 钱包操作
import 'package:youwallet/pages/wallet/new_wallet_first.dart';
import 'package:youwallet/pages/wallet/new_wallet_second.dart';
import 'package:youwallet/pages/wallet/new_wallet_third.dart';
import 'package:youwallet/pages/manage_wallet/manage_wallet.dart'; // 新建钱包名字
import 'package:youwallet/pages/manage_wallet/set_wallet.dart'; // 新建钱包名字


// token
import 'package:youwallet/pages/token/token_history.dart'; // token交易历史
import 'package:youwallet/pages/token/token_add.dart'; // 添加一种token

// 设置
import 'package:youwallet/pages/set/set_network.dart'; // 网络设置


// 定义全局的路由对象
final routers = {
  '/': ( context) => new SplashWidget(tabIndex: 1),
  "debug_page": (context) => new DebugPage(),
  "wallet_guide": (context) => new WalletGuide(),
  "set_wallet_name": (context) => new NewWalletName(),
  "manage_wallet": (context) => new ManageWallet(),
  "set_wallet": (context) => new SetWallet(),
  "add_wallet": (context) => new AddWallet(),
  "token_history":(context) => new TokenHistory(),
  "login": (context) => new Login(),
  "backup_wallet": (context) => new BackupWallet(),
  "load_wallet": (context) => new LoadWallet(),
  "set_network": (context) => new NetworkPage()
};

