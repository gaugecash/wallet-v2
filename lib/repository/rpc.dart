import 'dart:math';

import 'package:dart_web3/dart_web3.dart';
import 'package:http/http.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';

// todo: some servers can be ok at first but then die
// todo: timeout: some servers can take too long to respond
class GClient {
  final _http = Client();
  final _rand = Random();
  late Web3Client _pickedServer;

  List<Web3Client> _workingServers = [];

  List<String> get _getList => network == Network.main ? mainRPC : testRPC;

  Future<bool> _testServer(Web3Client client) async {
    try {
      final result = await Future.any<int?>([
        Future.delayed(const Duration(seconds: 3)),
        client.getBlockNumber(),
      ]);
      return result != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> init() async {
    final list = _getList;

    final futures = list.map((e) async {
      final client = Web3Client(e, _http);
      if (await _testServer(client)) {
        return client;
      }
    }).toList();

    final servers = await Future.wait(futures);

    _workingServers = servers.whereType<Web3Client>().toList();

    logger.i('Working servers: ${_workingServers.length}');
    if (_workingServers.isEmpty) {
      return true;
    }

    final index = _rand.nextInt(_workingServers.length);
    _pickedServer = _workingServers[index];
    logger.i('Picked server: ${_workingServers.length}');

    return _workingServers.isNotEmpty;
  }

  Web3Client get web3 => _pickedServer;

  // Duration get updateInterval {
  //   final interval = dataUpdateInterval.inMilliseconds;
  //   // 1.5 second offset
  //   final offset = _rand.nextInt(1501);
  //
  //   if (_rand.nextBool()) {
  //     return Duration(milliseconds: interval + offset);
  //   } else {
  //     return Duration(milliseconds: interval - offset);
  //   }
  // }
}
