// 定义项目要用到的表
class SqlTable{

  static final String sql_createTable_token = """
    CREATE TABLE tokens (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    address TEXT NOT NULL UNIQUE, 
    name TEXT NOT NULL, 
    balance TEXT,
    rmb TEXT);
    """;
  static final String sql_createTable_wallet = """
    CREATE TABLE wallet (address
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    name TEXT, 
    mnemonic TEXT,
    privateKey TEXT NOT NULL UNIQUE, 
    address TEXT NOT NULL UNIQUE);
    """;
}