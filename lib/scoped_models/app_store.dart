import 'dart:io';
import 'dart:typed_data';

import 'package:ntfy/models/account.dart';
import 'package:ntfy/models/network.dart';
import 'package:ntfy/models/token.dart';
import 'package:ntfy/models/user.dart';
import 'package:scoped_model/scoped_model.dart';

class AppStore extends Model {
  var defaultSettings = {
    "defaultAccount": "",
    "defaultTokenAddress": "",
    "defaultWallet": ""
  };

  Uint8List selectedImage;
  Uint8List nftSignatureData;
  var user = User(
      token_name: "NULL",
      setting_id: -1,
      account_name: "NULL",
      token_address: "NULL",
      private_key: "NULL",
      network_name: "NULL",
      network_url: "NULL");
  var tabIndex = 0;
  var hideToolBar = false;
  int get selectedTabIndex => tabIndex;
  bool get toolBarHidden => hideToolBar;
  Uint8List get selectedNFT => selectedImage;
  Uint8List get selectedNFTSignatureData => nftSignatureData;
  User get getCurrentUser => user;
  String selectedImagePath = "";

  String get getImagePath => selectedImagePath;

  void setSelectedImagePath(String path) {
    this.selectedImagePath = path;
    notifyListeners();
  }

  getDefaultSettings() {
    return defaultSettings;
  }

  void setDefaultAccount(Account account) {
    user.account_name = account.account_name;
    user.private_key = account.private_key;

    notifyListeners();
  }

  void setDefaultNetworkURL(Network network) {
    user.network_url = network.network_url;
    user.network_name = network.network_name;
    notifyListeners();
  }

  void setDefaultTokenAddress(Token token) {
    user.token_name = token.token_name;
    user.token_address = token.token_address;
    notifyListeners();
  }

  void setCurrentUser(data) {
    this.user = data;
    notifyListeners();
  }

  void setSelectedImage(image, signatureData) {
    selectedImage = image;
    nftSignatureData = signatureData;
    notifyListeners();
  }

  void setHideToolBar(value) {
    this.hideToolBar = value;
  }

  void setSelectedTab(index) {
    this.tabIndex = index;
    notifyListeners();
  }

  Uint8List getSelectedImage() {
    return selectedImage;
  }
}
