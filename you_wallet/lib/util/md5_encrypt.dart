import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

class Md5Encrypt {

  final String pwd;
  Md5Encrypt(this.pwd);

  String init() {
    var content = new Utf8Encoder().convert(pwd);
    var digest = md5.convert(content);
    return hex.encode(digest.bytes);
  }
}