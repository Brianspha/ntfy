class User {
  String token_address;
  String token_name;
  String network_name;
  String network_url;
  String account_name;
  String private_key;
  // ignore: non_constant_identifier_names
  int setting_id;

  // ignore: non_constant_identifier_names
  User(
      {this.token_address,
      this.account_name,
      this.network_url,
      this.setting_id,
      this.token_name,
      this.private_key, this.network_name});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'account_name': account_name,
      'network_name': network_name,
      "token_name": token_name,
      "private_key": private_key,
      "token_address":token_address,
      "network_url" : network_url

    };
    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    token_address = map['token_address'];
    network_url = map['network_url'];
    network_name = map['network_name'];
    setting_id = map["setting_id"];
    account_name = map["account_name"];
    token_name = map["token_name"];
    private_key = map["private_key"];
  }
}
