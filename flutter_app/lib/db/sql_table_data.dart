// 定义项目要用到的表
class SqlTable{

  static final String sql_createTable_token = """
    CREATE TABLE tokens (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    address TEXT NOT NULL UNIQUE, 
    name TEXT NOT NULL, 
    balance TEXT,
    rmb TEXT,
    network TEXT);
    """;
  static final String sql_createTable_wallet = """
    CREATE TABLE wallet (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    name TEXT, 
    mnemonic TEXT,
    privateKey TEXT NOT NULL UNIQUE, 
    address TEXT NOT NULL UNIQUE,
    balance TEXT);
    """;

  // 交易记录
  static final String sql_createTable_trade = """
    CREATE TABLE trade (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    orderType TEXT, 
    price TEXT,
    amount TEXT, 
    token TEXT,
    tokenName TEXT,
    baseToken TEXT,
    baseTokenName TEXT,
    txnHash TEXT NOT NULL UNIQUE,
    createTime TEXT,
    status TEXT);
    """;
}