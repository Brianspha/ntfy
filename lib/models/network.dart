class Network {
  String network_name;
  String network_url;
  String network_block_explorer;
  int isDefault;
  Network(
      {this.network_name,
      this.network_url,
      this.network_block_explorer,
      this.isDefault});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'network_name': network_name,
      'network_url': network_url,
      'network_block_explorer': network_block_explorer,
      'isDefault': isDefault
    };
    return map;
  }

  Network.fromMap(Map<String, dynamic> map) {
    network_name = map['network_name'];
    isDefault = map['isDefault'];
    network_url = map["network_url"];
    network_block_explorer = map["network_block_explorer"];
  }
}
