import 'package:web3dart/web3dart.dart';

class NumberFormat {
  NumberFormat(this.amount);

  var amount;
  String format() {
    String str = amount.toString();
    List arr = str.split('.');
//    print(arr);
    if (arr.length == 2) {
      String dem = this.delZero(arr[1]);
//      print('return ${dem}');
//      return dem;
      if (dem == null) {
        return arr[0];
      } else {
        return arr[0] +'.'+dem;
      }
    } else {
      return str;
    }
  }

  // 去掉右侧的0
  String delZero(String str) {
//    print(str);
//    print(str.length);
    if (str.length == 0) {
      return '';
    }
    if (str.substring(str.length -1) == '0') {
      this.delZero(str.substring(0, str.length -1));
    } else {
      return str;
    }
  }
}
