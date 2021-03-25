import 'package:get_it/get_it.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/account.dart';
import 'package:ntfy/models/network.dart';
import 'package:ntfy/scoped_models/home_view_model.dart';
import 'package:flutter/services.dart';
import 'package:ntfy/utils/nft_functions.dart';
import 'package:ntfy/utils/skynet_functions.dart';
import 'package:web3dart/web3dart.dart';
import 'models/token.dart';

GetIt locator = new GetIt();
var db = CacheDB();

void setupLocator() {
  // Register services
  // Register ScopedModels
  db.initDb();
  locator = new GetIt();
  locator.registerFactory<HomeViewModel>(() => HomeViewModel());
  locator.registerFactory<CacheDB>(() => db);
  locator.registerFactory<Account>(() => new Account());
  locator.registerFactory<Network>(() => new Network());
  locator.registerFactory<Token>(() => new Token());
  locator.registerFactory<SkynetFunctions>(() => new SkynetFunctions());
  locator.registerFactory<NFTFunctions>(() => new NFTFunctions());
}
