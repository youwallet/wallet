<p align="center">
  <a href="#" target="_blank" rel="noopener noreferrer">
    <img width="100" src="https://cn.etherscan.com/images/svg/brands/ethereum-1.svg?v=1.3" alt="wallet logo">
  </a>
</p>


## youwallet
[![License](https://img.shields.io/badge/license-Apache%202-4EB1BA.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/youwallet/wallet)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/youwallet/wallet)
![GitHub Workflow Status](https://img.shields.io/github/workflow/status/youwallet/wallet/Flutter%20CI)

## youwallet众和社区
为什么在区块链去中心化的世界里，交易所都是中心化的？

我们用数字货币解决了信任问题，为什么又要跳到中心化交易所的信任危机中？

难道就没有不需要预先存储数字货币的交易所吗？

youWallet，一款去中心化的数字货币交易工具，没有中心化上币费，不用充值交易，任何人都可自由兑换有价值的数字货币。

项目完全采用和众社区的贡献模式由所有贡献者推动。

## 文档
https://github.com/youwallet/wallet/wiki

## 功能说明
youWallet除提供ETH钱包的基础功能外，核心的功能是去中心化的币币交易。

### 钱包功能
* 创建管理新ETH钱包
* 导入/导出已有ETH钱包
* 添加任意ETH的TOKEN资产
* 转帐收款

### 去中心化币币交易
* 挂买/卖单
* 去中化撮合交易

### 钱包功能
`包含了ETH钱包的基础功能`
* 创建管理新ETH钱包

<img src="https://github.com/youwallet/wallet/blob/master/screenshots/%E5%88%9B%E5%BB%BA%E9%92%B1%E5%8C%85.gif" width = "294" height = "486" div align=middle />

* 导入/导出已有ETH钱包

<img src="https://github.com/youwallet/wallet/blob/master/screenshots/%E5%AF%BC%E5%85%A5%E9%92%B1%E5%8C%85.gif" width = "294" height = "486" div align=middle />

* 添加任意ETH的TOKEN资产

<img src="https://github.com/youwallet/wallet/blob/master/screenshots/%E6%B7%BB%E5%8A%A0TOKEN.gif" width = "294" height = "486" div align=middle />


### 去中心化币币交易
`通过去中心化的撮合交易，实现ETH任意代币间的币币兑换，不再需要通过中心化交易所`
* 挂买/卖单
* 去中化撮合交易

<img src="https://github.com/youwallet/wallet/blob/master/screenshots/%E5%B8%81%E5%B8%81%E5%85%91%E6%8D%A2.gif" width = "294" height = "486" div align=middle />

## 开发必备软件
- Xcode
- Andriod studio
- flutter 

## mac环境配置
```yaml
vim ~/.bash_profile。在~/.bash_profile文件中，添加配置

Flutter 镜像配置:

export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

Flutter 环境配置:

export PATH=/Users/gn/Desktop/FlutterSDK/flutter/bin:$PATH
```

## 载入配置
source .bash_profile

## 环境检查
```yaml
flutter doctor

# 如果环境准备OK，则输出如下：
Doctor summary (to see all details, run flutter doctor -v):
[✓] Flutter (Channel stable, v1.17.5, on macOS 13.0 22A380, locale zh-Hans-CN)

[✓] Android toolchain - develop for Android devices (Android SDK version 29.0.2)
[✓] Xcode - develop for iOS and macOS (Xcode 14.1)
[✓] Android Studio (version 3.5)
[✓] Connected device (1 available)
```

## 快速开发
本地clone仓库，进入项目中的you_wallet目录，执行命令：
```yaml
flutter pub get
```


## License

[MIT](https://mit-license.org/)

## 常见问题
```yaml
# 执行flutter pub get，报如下错误
Git error. Command: `git fetch`
stdout:
stderr: fatal: unable to connect to github.com:
github.com[0: 20.205.243.166]: errno=Operation timed out

exit code: 128
```




