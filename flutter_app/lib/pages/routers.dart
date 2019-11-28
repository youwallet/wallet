import 'package:youwallet/pages/splash/splash.dart'; // 启动页面
import 'package:youwallet/debug_page.dart'; // 全局调试
import 'package:youwallet/pages/login/login.dart'; // 解锁登录
import 'package:youwallet/wallet_guide.dart'; // 钱包引导页

// 新建钱包
import 'package:youwallet/pages/create_wallet/set_wallet_name.dart';
import 'package:youwallet/pages/create_wallet/backup_wallet.dart';
import 'package:youwallet/pages/create_wallet/load_wallet.dart';

// 钱包管理和设置
import 'package:youwallet/pages/manage_wallet/manage_wallet.dart'; // 新建钱包名字
import 'package:youwallet/pages/manage_wallet/set_wallet.dart'; // 新建钱包名字
import 'package:youwallet/pages/manage_wallet/add_wallet.dart'; // 添加币种

// token
import 'package:youwallet/pages/token/token_history.dart'; // 添加币种

// 设置
import 'package:youwallet/pages/set/set_network.dart'; // 网络设置

// 定义全局的路由对象
final routers = {
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

