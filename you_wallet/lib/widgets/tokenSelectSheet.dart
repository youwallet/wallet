import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/token.dart';
import 'package:youwallet/model/wallet.dart' as walletModel;
import 'package:youwallet/widgets/bottomSheetDialog.dart';

// token下拉选择模块
class TokenSelectSheet extends StatefulWidget {
  // 类型，一个应用中有多个地方都要选择token，selectType用来标记用户点击的是哪个地方
  String selectType = '';
  Function onCallBackEvent;

  // 构造函数
  TokenSelectSheet({
    Key key,
    this.selectType = 'default',
    @required this.onCallBackEvent,
  }) : super(key: key);


  Page createState() => new Page();
}

class Page extends State<TokenSelectSheet> {
  String showText = '选择币种';

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
        border: new Border.all(width: 1.0, color: Colors.black12),
        color: Colors.black12,
      ),
      height: 36.0,
      child: GestureDetector(
        onTap: (){
          this.selectToken(context);
        },//写入方法名称就可以了，但是是无参的
        child: Text(
          this.showText,
          style: TextStyle(
              fontSize: 24.0
          ),
        ),
      ),
    );
  }

  /// 弹出底部的选择列表
  selectToken(context) async {
    String wallet = Provider.of<walletModel.Wallet>(context).currentWalletObject['address'];
    List tokens = Provider.of<Token>(context).items.where((e)=>(e['wallet'] == wallet)).toList();
    if (tokens.length == 0) {
      print('没有币种');
      return;
    }
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return BottomSheetDialog(
              content: tokens,
              onSuccessChooseEvent: (res) {
                print('showModalBottomSheet => ${res}');
                setState(() {
                  this.showText = res['name'];
                });
                widget.onCallBackEvent(res);
              });
        }
    );
  }
}