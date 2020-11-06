import 'package:flutter/material.dart';
import 'package:youwallet/widgets/customButton.dart';
import 'package:youwallet/widgets/loadingDialog.dart';
import 'package:youwallet/global.dart';
import 'package:youwallet/service/app_server.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:youwallet/util/wallet_crypt.dart';
import 'package:web3dart/web3dart.dart';
import 'package:youwallet/service/token_service.dart';

// 在该页面让用户输入密码
// 通过密码解密出私钥
// 本页面还可以选择gas费用或者直接自定义gas费用
class GetPasswordPage extends StatefulWidget {
  final arguments;
  GetPasswordPage({Key key, this.arguments}) : super();

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<GetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  bool showExtraSet = false;
  Map data = {
    'gasPrice': '',   // 从第三方接口动态获取
    'gasLimit': '',   // 从配置合约中动态读取
    'pwd': ''
  };

  List gasList = []; // gas列表，第三方接口提供

  var _futureBuilderFuture;

  @override // override是重写父类中的函数
  void initState() {
    super.initState();

    ///用_futureBuilderFuture来保存_gerData()的结果，以避免不必要的ui重绘
    _futureBuilderFuture = getGasList();
    this.getGasLimit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: buildAppBar(context),
        body: FutureBuilder(
          future: _futureBuilderFuture,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData) {

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
                      buildConfirmButton(context),
                      Center(
                        heightFactor: 4.0,
                        child: Text(
                          "选择gas price",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      buildGasChoose()
                    ],
                  ));
            } else {
              return LoadingDialog();
            }
          },
        ));
  }

  // 构建AppBar
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
      title: const Text('输入密码'),
      elevation: .0,
    );
  }

  // 获取用户密码
  Widget buildConfirmButton(BuildContext context) {
    return new CustomButton(onSuccessChooseEvent: (res) async {
      _formKey.currentState.save();

      if (this.data['pwd'].isEmpty) {
        final snackBar = new SnackBar(content: new Text('密码不能为空'));
        Scaffold.of(context).showSnackBar(snackBar);
        return;
      }
      if (this.data['gasLimit'].isEmpty) {
        final snackBar = new SnackBar(content: new Text('gasLimit不能为空'));
        Scaffold.of(context).showSnackBar(snackBar);
        return;
      }

      // 默认使用当前页面选中的gas
      if (this.data['gasPrice'].isEmpty) {
        var gas = gasList.firstWhere((v) => v['checked'] == true);
        this.data['gasPrice'] = gas['value'].toString();
        // final snackBar = new SnackBar(content: new Text('gasPrice不能为空'));
        // Scaffold.of(context).showSnackBar(snackBar);
        // return;
      }

      try {
        this.data['privateKey'] = await this.getPrivateKey(this.data['pwd']);

        // debug：使用自定义的gas，不使用选择的gas
        var gas = this.gasList.firstWhere((v) => v['checked'] == true);
        this.data['gasPrice'] =
            EtherAmount.inWei(BigInt.parse(gas['value'].toString()));

        this.data['gasLimit'] = int.parse(this.data['gasLimit']);
        Navigator.of(context).pop(this.data);
      } catch (e) {
        print(e);
        // 真机上测试，发现密码输入错误，页面也会返回，真机和IDE的编译模式不一样，错误的判断不一致
        // 预期情况下，这里不应该返回
        final snackBar = new SnackBar(content: new Text('解密失败，请确认密码是否正确'));
        Scaffold.of(context).showSnackBar(snackBar);
      }

      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  // 获取用户密码
  Widget buildGasChoose() {
    return Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 8.0, // gap between adjacent chips
        runSpacing: 10.0, // gap between lines
        children: this.gasList.map((item) => buildGasItem(item)).toList());
  }

  // 定义gas列表项
  Widget buildGasItem(Map item) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    var _screenWidth = mediaQuery.size.width;
    return GestureDetector(
        onTap: () {
          this.clickItem(item);
        },
        child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(8.0), // 四周填充边距32像素
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
              color: item['checked'] ? Colors.lightBlue : Colors.grey,
            ),
            width: _screenWidth / 3,
            height: 100,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(item['name'],
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
                Text(item['value'].toString(),
                    style: new TextStyle(fontSize: 12.0, color: Colors.white)),
              ],
            )));
  }

  // 点击gas项目
  void clickItem(item) async {
    var gasList = this.gasList;
    var gasPrice = '';
    gasList.forEach((element) {
      if (element['name'] == item['name']) {
        element['checked'] = true;
        gasPrice = element['value'].toString();
      } else {
        element['checked'] = false;
      }
    });
    setState(() {
      data['gasPrice'] = gasPrice;
      gasList = gasList;
    });
  }

  TextFormField buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: '请输入密码',
        filled: true,
        fillColor: Colors.black12,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.0),
            borderSide: BorderSide.none),
      ),
      onSaved: (String value) => this.data['pwd'] = value,
    );
  }

  // 高级设置
  // 如果用户是在导出私钥或者助记忆词，则不显示高级设计
  Widget buildExtraTip() {
    if (widget.arguments == null) {
      var gas = gasList.firstWhere((v) => v['checked'] == true);
      return GestureDetector(
          onTap: () {
            setState(() {
              this.showExtraSet = !this.showExtraSet;
              data['gasPrice'] = gas['value'].toString();
            });
          },
          child: Padding(
            padding: EdgeInsets.only(left: 0.0, top: 4.0),
            child: Text('高级设置', style: TextStyle(color: Colors.lightBlue)),
          ));
    } else {
      return Text('');
    }
  }

  // 构建高级设置模块
  Widget buildExtraSet(bool showSet) {
    if (this.showExtraSet) {
      return new Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 20.0, top: 4.0),
              child: TextFormField(
                  controller:
                      TextEditingController(text: this.data['gasLimit']),
                  decoration: InputDecoration(
                    hintText: '请输入gasLimit',
                    helperText: "自定义gasLimit", //输入框底部辅助性说明文字
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6.0),
                        borderSide: BorderSide.none),
                  ),
                  onSaved: (String value) => data['gasLimit'] = value)),
          TextFormField(
            controller: TextEditingController(text: data['gasPrice']),
            decoration: InputDecoration(
              hintText: '请输入gasPrice',
              helperText: "自定义gasPrice",
              suffixText: 'Gwei',
              filled: true,
              fillColor: Colors.black12,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: BorderSide.none),
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
  Future<String> getPrivateKey(String pwd) async {
    String address = Global.getPrefs("currentWallet");

    var sql = SqlUtil.setTable("wallet");
    var map = {'address': address};
    List json = await sql.query(conditions: map);
    var res = await WalletCrypt(pwd, json[0]['privateKey']).decrypt();
    print('================');
    print('WalletCrypt done => ${res}');
    print('================');
    if (res == null ||
        res == "Failed to get string encoded: 'Decrypt failure.'.") {
      throw FormatException('钱包密码错误');
    } else {
      return res;
    }
  }

  // 调用第三方获取gas
  Future<List> getGasList() async {
    var data = await APPService.getGasList();
//    var gas = data.firstWhere((v) => v['checked'] == true);
//    print('getGasList');
//    print(gas);
//    setState(() {
//      data['gasPrice'] = 123;
//    });
    this.gasList = data;
    return data;
  }

  // 获取配置信息中的gas limit
  Future<void> getGasLimit() async {
    List arr = await TokenService.configurations('gaslimit');
    print('获取到配置合约中的gas limit:');
    print(arr);
    this.setState((){
      data['gasLimit']= arr[0];
    });
  }
}
