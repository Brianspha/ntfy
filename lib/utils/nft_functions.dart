import 'package:http/http.dart';
import 'package:flutter/services.dart';
import 'package:ntfy/database/cache_db.dart';
import 'package:ntfy/models/account.dart';
import 'package:ntfy/models/network.dart';
import 'package:ntfy/models/token.dart';
import 'package:ntfy/service_locator.dart';
import 'package:web3dart/web3dart.dart';

//@Dev init clients
//@dev init contract functions

class NFTFunctions {
  Future<DeployedContract> loadContract() async {
    String abiCode = await rootBundle.loadString("assets/contracts/nfty.json");
    String contractAddress = locator.get<Token>().token_address;
    var user = await locator.get<CacheDB>().getDefaultSettings();
    print("public Key: ${user.private_key}");
    var credentials =
        await EthPrivateKey.fromHex(user.private_key).extractAddress();
    final contract = DeployedContract(
        ContractAbi.fromJson(abiCode, user.token_name),
        EthereumAddress.fromHex(user.token_address));
    return contract;
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    Client httpClient = new Client();
    var user = await locator.get<CacheDB>().getDefaultSettings();
    print("user: $user");
    Web3Client ethClient = new Web3Client(user.network_url, httpClient);
    print("private_key: ${user.private_key}");
    ;
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    EthPrivateKey credentials = EthPrivateKey.fromHex(user.private_key);
    var result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
    );
    print("results of sending transaction: $result");
    return result;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    Client httpClient = new Client();
    var user = await locator.get<CacheDB>().getDefaultSettings();
    Web3Client ethClient = new Web3Client(user.network_url, httpClient);
    print("before call args: $args");
    final data = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    print("data returned: ${data.toString()} ");
    return data;
  }
}
