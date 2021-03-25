class Account {
  // ignore: non_constant_identifier_names
  String account_name;
  // ignore: non_constant_identifier_names
  String private_key;
  int isDefault;

  Account({this.account_name, this.private_key, this.isDefault});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'account_name': account_name,
      'private_key': private_key,
      'isDefault': isDefault
    };
    return map;
  }

  Account.fromMap(Map<String, dynamic> map) {
    account_name = map['account_name'];
    private_key = map['private_key'];
    isDefault = map['isDefault'];
  }
}
