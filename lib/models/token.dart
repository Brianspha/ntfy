class Token {
  String token_address;
  String token_name;
  int isDefault;
  Token({this.token_address, this.isDefault, this.token_name});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'token_address': token_address,
      'token_name': token_name,
      'isDefault': isDefault
    };
    return map;
  }

  Token.fromMap(Map<String, dynamic> map) {
    token_address = map['token_address'];
    token_name = map['token_name'];
    isDefault = map['isDefault'];
  }
}
