import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'sql_table_data.dart';

class ProviderSql {
  static Database db;

  // 获取数据库中所有的表
  Future<List> getTables() async {
    if (db == null) {
      return Future.value([]);
    }
    List tables = await db
        .rawQuery('SELECT name FROM sqlite_master WHERE type = "table"');
    List<String> targetList = [];
    tables.forEach((item) {
      targetList.add(item['name']);
    });
    return targetList;
  }

  // 检查数据库中, 表是否完整, 在部份android中, 会出现表丢失的情况
  Future checkTableIsRight() async {
    List<String> expectTables = ['tokens','wallet','trade','transfer']; //将项目中使用的表的表名添加集合中

    List<String> tables = await getTables();

    for (int i = 0; i < expectTables.length; i++) {
      if (!tables.contains(expectTables[i])) {
        return false;
      }
    }
    return true;
  }

  //初始化数据库
  Future init() async {
    //Get a location using getDatabasesPath
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'wallet.db');
    print(path);
    try {
      db = await openDatabase(path);
    } catch (e) {
      print("Error $e");
    }

    bool tableIsRight = await this.checkTableIsRight();

    if (!tableIsRight) {
      // 关闭上面打开的db，否则无法执行open
      print('db lost table，new db');
      db.close();
      //表不完整
      // Delete the database
      await deleteDatabase(path);

      db = await openDatabase(path, version: 1,
          onCreate: (Database db, int version) async {
        // When creating the db, create the table
        await db.execute(SqlTable.sql_createTable_token);
        await db.execute(SqlTable.sql_createTable_wallet);
        await db.execute(SqlTable.sql_createTable_trade);
        await db.execute(SqlTable.sql_createTable_transfer);
        print('db created version is $version');
      }, onOpen: (Database db) async {
        print('new db opened');
      });
    } else {
      print("Opening existing database");
    }
  }

  // 删除数据库
  Future clearCache() async {
    //Get a location using getDatabasesPath
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'wallet.db');
    print(path);
    try {
      db = await openDatabase(path);
    } catch (e) {
      print("Error $e");
    }

    await deleteDatabase(path);
  }

  // 删除交易数据表，然后新建交易数据表
  Future clearTrade() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'wallet.db');
    print(path);
    await db.delete('trade');
    await db.execute(SqlTable.sql_createTable_trade);
  }
}
