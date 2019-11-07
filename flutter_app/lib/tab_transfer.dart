import 'package:flutter/material.dart';

class TabTransfer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new Page();
  }
}

class Page extends State<TabTransfer> {
  @override
  Widget build(BuildContext context) {
    return layout(context);
  }
  var value;

  Widget layout(BuildContext context) {
    return new Scaffold(
      appBar: buildAppBar(context),
      body: new Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(left: 60.0, right: 60.0, top: 20.0),
        child: new Column(
          children: <Widget>[
            new Text(
              '余额：2999.00 ETH',
                style: new TextStyle(
                    fontSize: 26.0,
                    color: Colors.lightBlue
                )
            ),
            new Row(
              children: <Widget>[

                new Container(
                  constraints: BoxConstraints(
                    minHeight: 10,
                  ),

                  decoration: new BoxDecoration(
                    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
                    border: new Border.all(width: 1.0, color: Colors.black12),
                  ),
                  child: new DropdownButton(
                    items: getListData(),
                    hint:new Text('选择币种'),//当没有默认值的时候可以设置的提示
                    value: value,//下拉菜单选择完之后显示给用户的值
                    onChanged: (T){//下拉菜单item点击之后的回调
                      setState(() {
                        value=T;
                      });
                    },
                    elevation: 24,//设置阴影的高度
                    style: new TextStyle(//设置文本框里面文字的样式
                        color: Colors.red
                    ),
                    // isDense: false,//减少按钮的高度。默认情况下，此按钮的高度与其菜单项的高度相同。如果isDense为true，则按钮的高度减少约一半。 这个当按钮嵌入添加的容器中时，非常有用
                    // iconSize: 50.0,//设置三角标icon的大小
                  ),
                ),
                new  Expanded(
                    child: new TextField(
                      decoration: InputDecoration(
                          hintText: "转账金额",
                          fillColor: Colors.black12,
                          contentPadding: new EdgeInsets.only(left: 4.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                          )
                      ),
                      onChanged: (text) {//内容改变的回调
                        print('change $text');
                      },
                    ),
                )
              ],
            ),
            new Row(
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
            new TextField(
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6.0),
                  borderSide: BorderSide(
                    color: Colors.black12, //边线颜色为黄色
                    width: 1, //边线宽度为2
                  ),
                ),
                suffixIcon: Icon(Icons.camera_alt),
                hintText: "转账金额",
                fillColor: Colors.black12,
                contentPadding: new EdgeInsets.all(0.0), // 内部边距，默认不是0
              ),
              onChanged: (text) {//内容改变的回调
                print('change $text');
              },
            ),
            new Text(
                '手续费：99.00 ETH',
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Colors.lightBlue,
                    height: 2
                )
            ),
            new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                new Text('慢速'),
                new Text('常规'),
                new Text('快速'),
              ],
            ),
            new LinearProgressIndicator(
              backgroundColor: Colors.blue,
               value: 0,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            new Text(
                '付钱需要手续费，手续费越高，转账越快',
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 12.0,
                    height: 3,
                )
            ),
            new MaterialButton(
              color: Colors.blue,
              textColor: Colors.white,
              minWidth: 300,
              child: new Text('确认转账'),
              onPressed: () {
                // ...
              },
            ),

          ],
        ),
      ),
    );
  }



  // 定义bar上的内容
  Widget buildAppBar(BuildContext context) {
    return new AppBar(title: const Text('转账'));
  }

  List<DropdownMenuItem> getListData(){
    List<DropdownMenuItem> items=new List();
    DropdownMenuItem dropdownMenuItem1=new DropdownMenuItem(
      child:new Text('1'),
      value: '1',
    );
    items.add(dropdownMenuItem1);
    DropdownMenuItem dropdownMenuItem2=new DropdownMenuItem(
      child:new Text('2'),
      value: '2',
    );
    items.add(dropdownMenuItem2);
    DropdownMenuItem dropdownMenuItem3=new DropdownMenuItem(
      child:new Text('3'),
      value: '3',
    );
    items.add(dropdownMenuItem3);
    DropdownMenuItem dropdownMenuItem4=new DropdownMenuItem(
      child:new Text('4'),
      value: '4',
    );
    items.add(dropdownMenuItem4);
    DropdownMenuItem dropdownMenuItem5=new DropdownMenuItem(
      child:new Text('5'),
      value: '5',
    );
    items.add(dropdownMenuItem5);
    DropdownMenuItem dropdownMenuItem6=new DropdownMenuItem(
      child:new Text('6'),
      value: '6',
    );
    items.add(dropdownMenuItem6);
    DropdownMenuItem dropdownMenuItem7=new DropdownMenuItem(
      child:new Text('7'),
      value: '7',
    );
    items.add(dropdownMenuItem7);
    DropdownMenuItem dropdownMenuItem8=new DropdownMenuItem(
      child:new Text('8'),
      value: '8',
    );
    items.add(dropdownMenuItem8);
    DropdownMenuItem dropdownMenuItem9=new DropdownMenuItem(
      child:new Text('9'),
      value: '9',
    );
    items.add(dropdownMenuItem9);
    DropdownMenuItem dropdownMenuItem10=new DropdownMenuItem(
      child:new Text('10'),
      value: '10',
    );
    items.add(dropdownMenuItem10);
    return items;
  }

}
