
import 'dart:typed_data';

class NFTMetaData{
  String signature_url;
  String description;
  String nft_name;
  int time_stamp;
  bool owned;
  NFTMetaData(
      {this.signature_url, this.description, this.nft_name, this.time_stamp,this.owned});
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'signature_url': signature_url,
      'description': description,
      'nft_name': nft_name,
      "time_stamp": time_stamp,
      "owned": owned
    };
    return map;
  }

  NFTMetaData.fromMap(Map<String, dynamic> map) {
    signature_url = map['signature_url'];
    description = map['description'];
    nft_name = map['nft_name'];
    time_stamp = map["time_stamp"];
    owned = map["owned"];
  }
}