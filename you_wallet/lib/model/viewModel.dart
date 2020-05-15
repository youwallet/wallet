import 'package:flutter/material.dart';

/// 定义各个模块的数据对象

class TokenCardViewModel {
  /// 银行
  final String bankName;

  /// 银行Logo
  final String bankLogoUrl;

  /// 卡类型
  final String cardType;

  /// 卡号
  final String cardNumber;

  /// 卡片颜色
  final List<Color> cardColors;

  /// 有效期
  final String balance;

  const TokenCardViewModel({
    this.bankName,
    this.bankLogoUrl,
    this.cardType,
    this.cardNumber,
    this.cardColors,
    this.balance,
  });
}
