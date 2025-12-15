import 'package:dart_web3/credentials.dart';
import 'package:dart_web3/dart_web3.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/services/bip.dart';

class GWallet {
  GWallet(this._credentials, this.privateKey);

  factory GWallet.fromPrivateKey(String privateKey) {
    final credentials = EthPrivateKey.fromHex(privateKey);
    return GWallet(credentials, privateKey);
  }

  final Credentials _credentials;
  final String privateKey;

  @Deprecated('Cache the private key instead')
  static Future<GWallet> fromMnemonic(String mnemonic) async {
    if (!computeIsMnemonicValid(mnemonic)) {
      throw ArgumentError('Invalid mnemonic');
    }

    final privateKey = await computeMnemonicToPrivateHex(mnemonic);

    final credentials = EthPrivateKey.fromHex(privateKey);
    return GWallet(credentials, privateKey);
  }

  @Deprecated('use compute bip function')
  static Future<GWallet> random() async {
    final mnemonic = await computeRandomMnemonic();

    return GWallet.fromMnemonic(mnemonic);
  }

  Future<EthereumAddress> getAddress() {
    return _credentials.extractAddress();
  }

  int get chainId => network == Network.main ? mainChainId : testChainId;

  // todo: fetch gas dynamically (from the gas station)
  /// returns the tx
  Future<String> transact(Future<String> Function(Credentials) f) async {
    return f(_credentials);
  }
}
