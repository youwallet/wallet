import 'package:flutter/material.dart';
import 'package:youwallet/widgets/bottomSheetDialog.dart';
import 'package:youwallet/global.dart';

// token下拉选择模块
class TokenSelectSheet extends StatefulWidget {
  // 类型，一个应用中有多个地方都要选择token，selectType用来标记用户点击的是哪个地方
  String selectType = '';
  Function onCallBackEvent;
  List selectArr = [];

  // 构造函数
  TokenSelectSheet({
    Key key,
    this.selectType = 'default',
    this.selectArr,
    @required this.onCallBackEvent,
  }) : super(key: key);

  Page createState() => new Page();
}

class Page extends State<TokenSelectSheet> {
  String showText = '选择币种';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.selectArr.length == 0) {
          print('当前选项数量为0，不弹出');
          Global.showSnackBar(context, '请先前往首页添加token');
        } else {
          this.selectToken(context);
        }
      },
      child: new Container(
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.only(bottom: 10.0),
        width: MediaQuery.of(context).size.width / 2,
        alignment: Alignment.centerLeft,
        height: 36.0,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
          border: new Border.all(width: 1.0, color: Colors.black12),
          color: Colors.black12,
        ),
        child: Text(
          this.showText,
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }

  /// 弹出底部的选择列表
  selectToken(context) async {
    // String wallet =
    //     Provider.of<walletModel.Wallet>(context).currentWalletObject['address'];
    // List tokens = Provider.of<Token>(context)
    //     .items
    //     .where((e) => (e['wallet'] == wallet))
    //     .toList();
    // if (tokens.length == 0) {
    //   print('当前钱包没有token');
    //   final snackBar = new SnackBar(content: new Text('还没有添加token'));
    //   Scaffold.of(context).showSnackBar(snackBar);
    //   return;
    // }
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return BottomSheetDialog(
              content: widget.selectArr,
              onSuccessChooseEvent: (res) {
                print('showModalBottomSheet => ${res}');
                setState(() {
                  this.showText = res['name'];
                });
                widget.onCallBackEvent(res);
              });
        });
  }
}
