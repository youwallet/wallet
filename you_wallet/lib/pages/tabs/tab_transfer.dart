import 'package:flutter/material.dart';
import 'package:youwallet/service/token_service.dart';
import 'package:youwallet/widgets/customStepper.dart';
import 'package:youwallet/widgets/modalDialog.dart';
import 'package:provider/provider.dart';
import 'package:youwallet/model/wallet.dart';
import 'package:youwallet/service/trade.dart';
import 'package:youwallet/bus.dart';
import 'package:youwallet/db/sql_util.dart';
import 'package:youwallet/widgets/customButton.dart';
import 'package:youwallet/widgets/tokenSelectSheet.dart';
import 'package:youwallet/widgets/loadingDialog.dart';

class TabTransfer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<TabTransfer> {

  double balance = 0.0;
  final globalKey = GlobalKey<ScaffoldState>();
  var value;
  // 定义TextEditingController()接收编辑框的输入值
  final controllerPrice = TextEditingController();
  final controllerAddress = TextEditingController();
  Map token = {}; // 选择的token

  //数据初始化
  @override
  void initState() {
    super.initState();

    // 监听页面切换，刷新交易的状态
    eventBus.on<TabChangeEvent>().listen((event) {
      print("event listen =》${event.index}");
      if (event.index == 3) {
        print('刷新订单状态');
        this._getBalance();
      } else {
        print('do nothing');
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  double slider = 1.0;
  Widget layout(BuildContext context) {
    return new Scaffold(
      key: globalKey,
      appBar: buildAppBar(context),
      body: new Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 60.0, right: 60.0, top: 20.0),
        child: new Column(
          children: <Widget>[
            new Container(
              padding: const EdgeInsets.all(20.0),
              child: new Text(
                  '余额：${token['balance']??"~"}${token['name']??"~"}',
                  style: new TextStyle(
                      fontSize: 26.0,
                      color: Colors.lightBlue
                  )
              )
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  margin: const EdgeInsets.only(right: 40.0),
                  width: 100.0,
                  child: new TokenSelectSheet(
                      onCallBackEvent: (res){
                        print(res);
                       setState(() {
                         this.token = res;
                       });
                      }
                  ),
                ),
                new  Expanded(
                    child: new Container(
                      height: 36.0,
                      child: new TextField(
                        controller: controllerPrice,
                        decoration: InputDecoration(
                          hintText: '请输入金额',
                          filled: true,
                          fillColor: Colors.black12,
                          contentPadding: new EdgeInsets.only(left: 6.0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              borderSide: BorderSide.none
                          ),
                        ),
                        onChanged: (text) {//内容改变的回调
                          print('change $text');
                        },
                      ),
                    )
                  ),
              ],
            ),
            new Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                      '收款地址',
                      style: new TextStyle(
                        fontSize: 14.0,
                      )
                  ),
                  new Text(
                      '联系人',
                      style: new TextStyle(
                          fontSize: 14.0,
                          color: Colors.lightBlue
                      )
                  ),
                ],
              ),
            ),
            new Container(
              height: 36.0,
              child: new TextField(
                controller: controllerAddress,
                decoration: InputDecoration(
                  hintText: '请输入收款地址',
                  filled: true,
                  fillColor: Colors.black12,
                  contentPadding: new EdgeInsets.only(left: 6.0),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      borderSide: BorderSide.none
                  ),
                ),
              ),
            ),
//            new TextField(
//              controller: controllerAddress,
//              decoration: InputDecoration(
//                enabledBorder: OutlineInputBorder(
//                  borderRadius: BorderRadius.circular(6.0),
//                  borderSide: BorderSide(
//                    color: Colors.black12, //边线颜色为黄色
//                    width: 1, //边线宽度为2
//                  ),
//                ),
//                suffixIcon: new IconButton(
//                  icon: new Icon(IconData(0xe61d, fontFamily: 'iconfont'),size:16.0),
//                  onPressed: () {
//                    _scan();
//                  },
//                ),
//                hintText: "输入以太坊地址",
//                contentPadding: new EdgeInsets.only(left: 10.0), // 内部边距，默认不是0
//              ),
//              onChanged: (text) {//内容改变的回调
//                print('change $text');
//              },
//            ),
//            new Container(
//                padding: const EdgeInsets.all(20.0),
//                child: new Text(
//                    '矿工费用：0.6%',
//                    style: new TextStyle(
//                        fontSize: 16.0,
//                        color: Colors.lightBlue,
//                        height: 2
//                    )
//                )
//            ),

//            new Row(
//              children: <Widget>[
//                new Text(
//                    '转账模式',
//                    style: new TextStyle(
//                        fontSize: 16.0,
//                        height: 2
//                    )
//                ),
//              ],
//            ),
//            new Row(
//              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//              children: <Widget>[
//                new Text('慢速'),
//                new Text('中速'),
//                new Text('快速')
//              ],
//            ),
//            new Slider(
//              value: slider,
//              max: 100.0,
//              min: 0.0,
//              activeColor: Colors.blue,
//              onChanged: (double val) {
//                this.setState(() {
//                  slider = val;
//                });
//              },
//            ),
//            new Text(
//                '付钱需要手续费，手续费越高，转账越快',
//                textAlign: TextAlign.center,
//                style: new TextStyle(
//                    fontSize: 12.0,
//                    height: 3,
//                )
//            ),
            SizedBox(
              height: 40.0,
            ),
            new CustomButton(
                content: '确认转账',
                onSuccessChooseEvent:(res) async{
                   this.checkInput();
                }
            )
          ],
        ),
      ),
    );
  }

  void checkInput() {
    print(this.token);
    if (this.token.isEmpty) {
      this.showSnackbar('请选择token');
      return;
    }

    if (this.controllerPrice.text == '') {
      this.showSnackbar('请输入转账金额');
      return;
    }

    if (this.controllerAddress.text == '') {
      this.showSnackbar('请输入收款地址');
      return;
    }

    if (this.controllerAddress.text.length != 42) {
      this.showSnackbar('收款地址长度不符合42位长度要求');
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GenderChooseDialog(
              title: '确认付款?',
              content: '',
              onCancelChooseEvent: () {
                Navigator.pop(context);
                // 关闭键盘
                FocusScope.of(context).requestFocus(FocusNode());
                this.showSnackbar('取消转账');
              },
              onSuccessChooseEvent: () {
                Navigator.pop(context);
                // 关闭键盘
                FocusScope.of(context).requestFocus(FocusNode());
                this.startTransfer();
              });
        });
  }


  // 定义bar上的内容
  Widget buildAppBar(BuildContext context) {
    return new AppBar(
        title: const Text('转账'),
        actions: this.appBarActions(),
        automaticallyImplyLeading: false //设置没有返回按钮
    );
  }

  appBarActions() {
    return <Widget>[
      new Container(
        width: 50.0,
        child: new IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Navigator.pushNamed(context, "token_history");
          },
        ),
      )
    ];
  }

  // 构建进度条
  _buildCustomStepper2(){
    return CustomStepper2(
      currentStep: 1,
      type: CustomStepperType2.horizontal,
      steps: ['慢速', '常规', '快速']
          .map(
            (s) => CustomStep2(title: Text(s), content: Container(), isActive: true),
      )
          .toList(),
      controlsBuilder: (BuildContext context,
          {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
        return Container();
      },
    );
  }

  Future<void> _getBalance() async {
    print(Provider.of<Wallet>(context).currentWallet);
    String balance = await TokenService.getBalance(Provider.of<Wallet>(context).currentWallet);
    setState(() {
      this.balance =  double.parse(balance);
    });
  }

  // 显示提示
  void showSnackbar(String text) {
    final snackBar = SnackBar(content: Text(text));
    globalKey.currentState.showSnackBar(snackBar);
  }

  // 开始转账
  Future<void> startTransfer() async{
    showDialog<Null>(
        context: context, //BuildContext对象
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new LoadingDialog( //调用对话框
            text: '转账中...',
          );
        });
    print(controllerPrice.text);
    String from = Provider.of<Wallet>(context).currentWallet;
    String to = controllerAddress.text;
    String num = controllerPrice.text;
    Navigator.pushNamed(context, "getPassword").then((pwd) async{
      try {
        String txnHash = await Trade.sendToken(from, to, num, this.token, pwd);
        this.saveTransfer(from, to, num, txnHash, this.token);

        // 拿到hash值，根据hash值查询以太坊打包是否成功
        this.checkOrderStatus(txnHash, 0);
      } catch (e) {
        this.showSnackbar(e.toString());
        Navigator.pop(context);
      }
    });

  }

  void checkOrderStatus(String hash, int index) async {
    Map response = await Trade.getTransactionByHash(hash);
    print("第${index}次查询");
    print(response);
    if(response['blockHash'] != null) {
      print('打包成功，以太坊返回了交易的blockHash');
      Navigator.pop(context);
      this.showSnackbar('转账成功');
      this.updateTransferStatus(hash);
    } else {
      if (index > 30) {
        print('已经轮询了30次，打包失败');
        Navigator.pop(context);
        this.showSnackbar('交易超时');
      } else {
        Future.delayed(Duration(seconds: 2), (){
          this.checkOrderStatus(hash, index+1);
        });
      }
    }
  }

  void saveTransfer(String fromAddress, String toAddress, String num, String txnHash, Map token) async{
    var sql = SqlUtil.setTable("transfer");
    String sql_insert ='INSERT INTO transfer(fromAddress, toAddress, tokenName, tokenAddress, num, txnHash, createTime) VALUES(?, ?, ?, ?, ?, ?, ?)';
    List list = [fromAddress, toAddress,  token['name'], token['address'], num, txnHash, DateTime.now().millisecondsSinceEpoch];
    int id = await sql.rawInsert(sql_insert, list);
    print("转账记录插入成功=》${id}");

  }

  Future<void> updateTransferStatus(String txnHash) async {
    print('开始更新数据表 =》 ${txnHash}');
    var sql = SqlUtil.setTable("transfer");
    int i = await sql.update({'status':' 转账成功'}, 'txnHash', txnHash);
    print('更新完毕=》${i}');
  }

}
