
import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';

import 'package:youwallet/global.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:youwallet/util/wallet_crypt.dart';

//在该页面让用户输入密码
//通过密码解密出私钥
class GetPasswordPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<GetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
//  String _email, _password;
//  String
//  String gasPrice =
  bool showExtraSet = false;
  Map data = {
    'gasPrice': Global.gasPrice.toString(),
    'gasLimit': Global.gasLimit.toString(),
    'pwd': ''
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: new Builder(builder: (BuildContext context) {
          return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 22.0),
                children: <Widget>[
                  buildTitle(),
                  buildTitleLine(),
                  SizedBox(height: 70.0),
                  buildEmailTextField(),
                  buildExtraTip(),
                  buildExtraSet(this.showExtraSet),
                  SizedBox(height: 60.0),
                  buildLoginButton(context),
                ],
              )
          );
        })
    );
  }

  // 构建AppBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('输入密码'),
      elevation:.0,
    );
  }

  // 获取用户密码
  Widget buildLoginButton(BuildContext context) {
    return new CustomButton(
        onSuccessChooseEvent:(res) async {
          _formKey.currentState.save();
          if (!this.data['pwd'].isEmpty) {
            // 用户输入的密码不为空，在这里开始解密用户的私钥
            // 解密到用户的私钥，拿到用户的私钥回到交易页面
            print(this.data);
            return;
            try {
              String privateKey = await this.getPrivateKey(this.data['pwd']);
              Navigator.of(context).pop(privateKey);
            } catch (e) {
              print(e);
              final snackBar = new SnackBar(content: new Text('解密失败，请确认密码是否正确'));
              Scaffold.of(context).showSnackBar(snackBar);
            }

            FocusScope.of(context).requestFocus(FocusNode());

          } else {
            final snackBar = new SnackBar(content: new Text('密码不能为空'));
            Scaffold.of(context).showSnackBar(snackBar);
          }
        }
    );
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: '请输入密码',
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide.none
        ),
      ),
      onSaved: (String value) => this.data['pwd'] = value,
    );
  }

  // 高级设置
  Widget buildExtraTip() {
    return GestureDetector(
      onTap: (){
        setState(() {
          this.showExtraSet = !this.showExtraSet;
        });
      },
      child: Padding(
        padding: EdgeInsets.only(left: 0.0, top: 4.0),
        child: Text(
            '高级设置',
            style: TextStyle(color: Colors.lightBlue)
        ),
      )
    );
  }

  Widget buildExtraSet(bool showSet) {
    if(this.showExtraSet) {
      return new Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 20.0, top: 4.0),
              child: TextFormField(
                  controller: TextEditingController(text: this.data['gasLimit']),
                  decoration: InputDecoration(
                    hintText: '请输入gasLimit',
                    helperText: "自定义gasLimit", //输入框底部辅助性说明文字
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide.none
                    ),
                  ),
                  onSaved: (String value) => this.data['gasLimit'] = value)
          ),
          TextFormField(
            controller: TextEditingController(text: this.data['gasPrice']),
            decoration: InputDecoration(
              hintText: '请输入gasPrice',
              helperText: "自定义gasPrice",
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: BorderSide.none
              ),
            ),
            onSaved: (String value) => this.data['gasPrice'] = value,
          ),
        ],
      );
    } else {
      return SizedBox(
        height: 0,
      );
    }
  }

  Padding buildTitleLine() {
    return Padding(
      padding: EdgeInsets.only(left: 12.0, top: 4.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Container(
          color: Colors.white,
          width: 40.0,
          height: 2.0,
        ),
      ),
    );
  }

  Padding buildTitle() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        '',
        style: TextStyle(fontSize: 42.0),
      ),
    );
  }

  // static 方法获取用户私钥
  // 这里的操作优化到model中去
  Future<String> getPrivateKey(String pwd) async{
    String address =  Global.getPrefs("currentWallet");

    var sql = SqlUtil.setTable("wallet");
    var map = {'address': address};
    List json = await sql.query(conditions: map);
    var res = await WalletCrypt(pwd, json[0]['privateKey']).decrypt();
    print('================');
    print('WalletCrypt done => ${res}');
    print('================');
    if (res == null) {
      throw FormatException('钱包密码错误');
    } else {
      return res;
    }
  }
}
