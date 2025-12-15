import 'package:bip32/bip32.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:wallet/logger.dart';

Future<String> computeMnemonicToPrivateHex(String mnemonic) =>
    compute(_mnemonicToPrivate, mnemonic);

// todo research whether this should be put into compute()
Future<String> computeRandomMnemonic() => compute(_randomMnemonic, null);

// todo research whether this should be put into compute()
bool computeIsMnemonicValid(String mnemonic) {
  return bip39.validateMnemonic(mnemonic);
}

// todo use native JS library instead
// todo use compute() only where appropriate [crypto functions are already native & use bip32 js library]
Future<String> _mnemonicToPrivate(String mnemonic) async {
  var time = DateTime.now().millisecondsSinceEpoch;
  final seed = bip39.mnemonicToSeed(mnemonic);

  logger.d(
    'got seed hex from mnemonic: ${DateTime.now().millisecondsSinceEpoch - time}',
  );
  time = DateTime.now().millisecondsSinceEpoch;

  final node = BIP32.fromSeed(seed);

  logger.d(
    'derived path from seed hex: ${DateTime.now().millisecondsSinceEpoch - time}',
  );
  time = DateTime.now().millisecondsSinceEpoch;

  final child = node.derivePath("m/44'/60'/0'/0/0");

  final key = hex.encode(child.privateKey!.toList());

  logger.d('got private key hex: ${DateTime.now().millisecondsSinceEpoch - time}');

  return key;
}

Future<String> _randomMnemonic(void _) async {
  return bip39.generateMnemonic();
}
