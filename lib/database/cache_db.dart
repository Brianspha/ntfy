import 'package:ntfy/models/account.dart';
import 'package:ntfy/models/network.dart';
import 'package:ntfy/models/token.dart';
import 'package:ntfy/models/user.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class CacheDB {
  Database db;
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String TABLE = 'Employee';
  static const String DB_NAME = 'nfty.db';

  CacheDB() {
    initDb();
  }

  Future<Database> get database async {
    if (db != null) {
      return db;
    }
    db = await initDb();
    // print('getting database: ${db}');
    return db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    db = await openDatabase(path, version: 1, onCreate: onCreate);
    await onCreate(db, 1);
    print('initialised DB is opened: ${db.isOpen}');
    return db;
  }

  onCreate(Database db, int version) async {
    await db
        .execute("CREATE TABLE IF NOT EXISTS App(launched INT default(0));");
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Account (account_name CHAR(60) UNIQUE  NOT NULL, private_key CHAR(64) NOT NULL PRIMARY KEY, isDefault INT DEFAULT(0))');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Token (token_address CHAR(42) PRIMARY KEY NOT NULL, token_name VARCHAR(64) NOT NULL, isDefault INT DEFAULT(0));');
    await db.execute(
        'CREATE TABLE IF NOT EXISTS Network (network_name VARCHAR(100)  NOT NULL , network_url VARCHAR(50) NOT NULL PRIMARY KEY , network_block_explorer VARCHAR(50),isDefault INT DEFAULT(0));');

    await db.execute(
        'CREATE TABLE IF NOT EXISTS DefaultSetting (setting_id INTEGER PRIMARY KEY AUTOINCREMENT, account_name CHAR(60) UNIQUE NOT NULL,network_name CHAR(100) NOT NULL UNIQUE,network_url CHAR(100) NOT NULL UNIQUE,token_name VARCHAR(64) NOT NULL UNIQUE,private_key CHAR(64) NOT NULL UNIQUE ,token_address CHAR(42) NOT NULL UNIQUE,FOREIGN KEY(network_name) REFERENCES Network(network_name),FOREIGN KEY(token_address) REFERENCES Token(token_address))');
  }

  Future<bool> getApplicationLaunchedStatus() async {
    db = await database;
    var results = await db.query("App", columns: ["launched"]);
    print('app launched: $results');
    var launched = false;
    if (results.isEmpty) {
      launched = false;
    } else {
      var appStatus = results[0]["launched"];
      print('appStatus: $appStatus');
      launched = appStatus == 1 ? true : false;
    }
    return launched;
  }

  Future<bool> setApplicationLaunchStatus(int status) async {
    var map = new Map<String, Object>();
    map["launched"] = status;
    var currentStatus = await getApplicationLaunchedStatus();
    print("currentStatus: $currentStatus");
    var results = 1;
    if (!currentStatus) {
      results = await db.insert("App", map);
    }
    print("set app luanch status: $results");
    return results == 1 ? true : false;
  }

  //@dev mapping over list not working
  Future<User> getDefaultSettings() async {
    // var db = await database;
    // print("db found db:$db ");
    //  this.db=db;
    var user = User(
        token_name: "NULL",
        setting_id: -1,
        account_name: "NULL",
        token_address: "NULL",
        private_key: "NULL",
        network_name: "NULL",
        network_url: "NULL");
    var accounts = await getAddresses();
    for (var i = 0; i < accounts.length; i++) {
      print('account found: ${accounts[i].toMap()}');
      if (accounts[i].isDefault == 1) {
        user.account_name = accounts[i].account_name;
        user.private_key = accounts[i].private_key;
      }
    }
    var networks = await getNetworks();
    for (var i = 0; i < networks.length; i++) {
      print('network found: ${networks[i].toMap()}');
      if (networks[i].isDefault == 1) {
        user.network_name = networks[i].network_name;
        user.network_url = networks[i].network_url;
      }
    }
    var tokens = await getTokens();
    // print('tokens: ${tokens[0].toMap()}');
    for (var i = 0; i < tokens.length; i++) {
      print('token found: ${tokens[i].toMap()}');
      if (tokens[i].isDefault == 1) {
        user.token_name = tokens[i].token_name;
        user.token_address = tokens[i].token_address;
      }
    }
    print('user default settings: ${user.toMap()}');
    return user;
  }

  Future<bool> updateDefaultSettings(User settings) async {
    db = await database;
    print('settings: ${settings.toMap()}');
    db.update("DefaultSetting", settings.toMap()).then((results) {
      print('results of updating user settings: $results');
      return results == 0 ? false : true;
    }).catchError((onError) {
      print('error updating user settings: ${onError}');
      return false;
    });
  }

  Future<bool> deleteSetting(User settings) async {
    db = await database;

    var results = await db.update("DefaultSetting", settings.toMap());
    return results == 1 ? true : false;
  }

  Future<bool> insertDefaultSettings(User settings) async {
    db = await database;

    var results = await db.update("DefaultSetting", settings.toMap());
    return results == 0 ? false : true;
  }

  Future<Token> saveToken(Token token) async {
    db = await database;

    print('saving token: ${token.toMap()}');
    if (token.isDefault == 1) {
      var settings = await getDefaultSettings();
      if (settings.setting_id >= 0) {
        print("updated user settings in saving token");
        settings.token_address = token.token_address;
        settings.token_name = token.token_name;
        await updateDefaultSettings(settings);
      } else {
        print("set user settings in saving token");
        settings.token_address = token.token_address;
        settings.token_name = token.token_name;
        await insertDefaultSettings(settings);
      }
    }
    await db.insert("Token", token.toMap());
    return token;
  }

  Future<List<Token>> getTokens() async {
    db = await database;

    List<Map> maps = await db
        .query("Token", columns: ["token_address", "token_name", "isDefault"]);
    List<Token> tokens = [];
    print('maps in tokens: ${maps.length}');
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        tokens.add(Token.fromMap(maps[i]));
      }
    }
    print('tokens found: ${tokens.length}');
    return tokens;
  }

  Future<Account> saveAccount(Account account) async {
    db = await database;

    if (account.isDefault == 1) {
      print("setting account as default");
      var settings = await getDefaultSettings();
      if (settings.setting_id >= 0) {
        print("updating user settings in saveAccount");
        settings.private_key = account.private_key;
        await updateDefaultSettings(settings);
      } else {
        print("new user settings in saveAccount");
        settings.private_key = account.private_key;
        settings.account_name = account.account_name;
        await insertDefaultSettings(settings);
      }
    }
    await db.insert("Account", account.toMap());
    return account;
  }

  Future<List<Account>> getAddresses() async {
    db = await database;
    List<Map> maps = await db.query("Account",
        columns: ["account_name", "private_key", "isDefault"]);
    List<Account> accounts = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        accounts.add(Account.fromMap(maps[i]));
      }
    }
    print('accounts found: ${accounts.length}');
    return accounts;
  }

  Future<Network> saveNetwork(Network network) async {
    db = await database;

    if (network.isDefault == 1) {
      print("setting network as default");
      var settings = await getDefaultSettings();
      if (settings.setting_id >= 0) {
        print("updating new user settings");
        settings.network_name = network.network_name;
        settings.network_url = network.network_url;
        await updateDefaultSettings(settings);
      } else {
        print("inserting new user settings");
        settings.network_name = network.network_name;
        settings.network_url = network.network_url;
        await insertDefaultSettings(settings);
      }
    }
    await db.insert("Network", network.toMap());
    return network;
  }

  Future<List<Network>> getNetworks() async {
    db = await database;

    List<Map> maps = await db.query("Network", columns: [
      "network_name",
      "isDefault",
      "network_url",
      "network_block_explorer"
    ]);
    List<Network> networks = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        networks.add(Network.fromMap(maps[i]));
      }
    }
    return networks;
  }

  Future<int> deleteAccount(String private_address) async {
    db = await database;

    if (db == null) {
      initDb();
    }
    return await db.delete("Account",
        where: 'private_key = ?', whereArgs: [private_address]);
  }

  Future<int> deleteToken(String token_address) async {
    db = await database;

    if (db == null) {
      initDb();
    }
    return await db.delete("Token",
        where: 'token_address = ?', whereArgs: [token_address]);
  }

  Future<int> deleteNetwork(String network_name) async {
    db = await database;

    if (db == null) {
      initDb();
    }
    return await db.delete("Network",
        where: 'network_name = ?', whereArgs: [network_name]);
  }
}
