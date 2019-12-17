/**
 * Created by yangqc on 2019-04-10
 * sqflite工具类
 */
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'provider.dart';

class BaseModel {
  Database db;
  final String table = '';
  var querys;

  BaseModel(this.db) {
    querys = db.query;
  }
}

class SqlUtil extends BaseModel {
  final String tableName;

  SqlUtil.setTable(String name)
      : tableName = name,
        super(Provider.db);

  //查询该表中的所有数据
  Future<List> get() async {
    return await this.querys(tableName);
  }

  //插入数据 传入Sql语句和参数 返回插入数据的id
  Future<int> rawInsert(String sql, List arguments) async {
    return await this.db.rawInsert(sql, arguments);
  }

  //插入一条新的数据 返回插入数据的id
  Future<int> insert(Map<String, dynamic> params) async {
    return await this.db.insert(tableName, params);
  }

  //删除数据 传入Sql语句和参数
  Future<int> rawDelete(String sql, List arguments) async {
    return await this.db.rawDelete(sql, arguments);
  }

  //删除一条或多条数据 单个条件
  Future<int> delete(String key, dynamic value) async {
    return await this.db.delete(tableName, where:'$key = ?', whereArgs:[value]);
  }

  //删除一条或多条数据 多个条件
  Future<int> deletes(Map<String, dynamic> conditions, String ao) async {
    String stringConditions = '';

    int index = 0;
    if (ao == '') ao = 'and';
    conditions.forEach((key, value) {
      if (value == null) {
        return ;
      }
      if (value.runtimeType == String) {
        stringConditions = '$stringConditions $key = "$value"';
      }
      if (value.runtimeType == int) {
        stringConditions = '$stringConditions $key = $value';
      }

      if (index >= 0 && index < conditions.length -1) {
        stringConditions = '$stringConditions $ao';
      }
      index++;
    });
    return await this.db.delete(tableName, where:stringConditions);
  }

  //修改数据 传入Sql语句和参数
  Future<int> rawUpdate(String sql, List arguments) async {
    return await this.db.rawUpdate(sql, arguments);
  }

  //修改一条或多条数据 单个条件
  Future<int> update(Map<String, dynamic> params, String key, dynamic value) async {
    return await this.db.update(tableName, params, where:'$key = ?', whereArgs:[value]);
  }

  //修改一条或多条数据 多个条件
  Future<int> updates(Map<String, dynamic> params, Map<String, dynamic> conditions, String ao) async {
    String stringConditions = '';

    int index = 0;
    if (ao == '') ao = 'and';
    conditions.forEach((key, value) {
      if (value == null) {
        return ;
      }
      if (value.runtimeType == String) {
        stringConditions = '$stringConditions $key = "$value"';
      }
      if (value.runtimeType == int) {
        stringConditions = '$stringConditions $key = $value';
      }

      if (index >= 0 && index < conditions.length -1) {
        stringConditions = '$stringConditions $ao';
      }
      index++;
    });
    return await this.db.update(tableName, params, where:stringConditions);
  }

  //查询数据 传入Sql语句和参数
  Future<List> rawQuery(String sql, List arguments) async {
    return await this.db.rawQuery(sql, arguments);
  }

  //通过条件查询，可以将表名作为参数传进来，作为公共方法，返回的是一个集合
  Future<List> query({Map<dynamic, dynamic> conditions}) async {
    // 如果传入条件为空，就查询该表全部数据
    if (conditions == null || conditions.isEmpty) {
      return this.get();
    }
    String stringConditions = '';

    int index = 0;
    conditions.forEach((key, value) {
      if (value == null) {
        return ;
      }
      if (value.runtimeType == String) {
        stringConditions = '$stringConditions $key = "$value"';
      }
      if (value.runtimeType == int) {
        stringConditions = '$stringConditions $key = $value';
      }

      if (index >= 0 && index < conditions.length -1) {
        stringConditions = '$stringConditions and';
      }
      index++;
    });
    // print("this is string condition for sql > $stringConditions");
    return await this.querys(tableName, where: stringConditions);
  }
}


