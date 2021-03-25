import 'dart:convert';
import 'dart:typed_data';
import 'package:ntfy/models/skynetUpload.dart';
import 'package:skynet/skynet.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class SkynetFunctions {
  User user = User('username', 'password');
  var dio = Dio();

  Future<String> uploadFile(
      String filePath, String nftName, String description) async {
    var name = filePath
        .split("image_picker_")[filePath.split("image_picker_").length - 1];
    var formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: name),
    });
    var response =
        await dio.post("https://siasky.net/skynet/skyfile", data: formData);
    print("response1: ${response.data["skylink"]}");
    formData = FormData.fromMap({
      "file": MultipartFile.fromString(
          json.encode(new SkynetUpload(
                  time_stamp: DateTime.now().millisecondsSinceEpoch,
                  description: description,
                  nft_name: nftName,
                  signature_url:
                      "https://siasky.net/" + response.data["skylink"])
              .toMap()),
          filename: name),
    });
    response =
        await dio.post("https://siasky.net/skynet/skyfile", data: formData);
    print("response from skyNet: ${response.data}");

    return response.statusCode == 200 ? response.data["skylink"] : "";
  }
}
