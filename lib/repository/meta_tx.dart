import 'dart:convert';

import 'package:dart_web3/dart_web3.dart';
import 'package:eth_sig_util/eth_sig_util.dart';
import 'package:eth_sig_util/util/utils.dart';
import 'package:http/http.dart' as http;
import 'package:wallet/conf.dart';
import 'package:wallet/logger.dart';
import 'package:wallet/repository/abi/gau.g.dart';
import 'package:wallet/repository/abi/usdt.g.dart';
import 'package:wallet/repository/rpc.dart';

const maxUint256 =
    '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

class MetaTx {
  static Future<String> getNonceGau(
    GClient client,
    EthereumAddress walletAddr,
  ) async {
    logger.i('Getting nonce gau');

    final gauCoin = Gau(
      client: client.web3,
      address: EthereumAddress.fromHex(mainGauAddress),
    );
    final nonces = await client.web3.call(
      contract: gauCoin.self,
      sender: walletAddr,
      function: gauCoin.self.function('nonces'),
      params: [walletAddr],
    );

    logger.i('Nonce received gau: $nonces');
    final nonceValue = nonces[0].toString();

    return nonceValue;
  }

  static Future<String> getNonceUsdt(
    GClient client,
    EthereumAddress walletAddr,
  ) async {
    logger.i('Getting nonce gau');

    final usdtCoin = Usdt(
      client: client.web3,
      address: EthereumAddress.fromHex(mainUsdtAddress),
    );

    final nonces = await client.web3.call(
      contract: usdtCoin.self,
      sender: walletAddr,
      function: usdtCoin.self.function('getNonce'),
      params: [walletAddr],
    );

    logger.i('Nonce received usdt: $nonces');
    final nonceValue = nonces[0].toString();

    return nonceValue;
  }

  static Future<String> getSignedGauPayload({
    required GClient client,
    required EthereumAddress walletAddr,
    required String privateKey,
    required String nonceValue,
    required BigInt amount,
    EthereumAddress? to,
  }) async {
    final gauCoin = Gau(
      client: client.web3,
      address: EthereumAddress.fromHex(mainGauAddress),
    );
    final name = await gauCoin.name();

    final spenderAddr = EthereumAddress.fromHex(mainMetaTxSpender);

    final payload = {
      'types': {
        'EIP712Domain': [
          {'type': 'string', 'name': 'name'},
          {'type': 'string', 'name': 'version'},
          {'type': 'uint256', 'name': 'chainId'},
          {'type': 'address', 'name': 'verifyingContract'},
        ],
        'Permit': [
          {
            'name': 'owner',
            'type': 'address',
          },
          {
            'name': 'spender',
            'type': 'address',
          },
          {
            'name': 'value',
            'type': 'uint256',
          },
          {
            'name': 'nonce',
            'type': 'uint256',
          },
          {
            'name': 'deadline',
            'type': 'uint256',
          },
        ],
      },
      'primaryType': 'Permit',
      'domain': {
        'name': name,
        'version': '1',
        'chainId': mainChainId.toString(),
        'verifyingContract': mainGauAddress,
      },
      'message': {
        'owner': walletAddr.hexEip55,
        'nonce': nonceValue,
        'spender': spenderAddr.hexEip55,
        'value': amount.toString(),
        'deadline': maxUint256,
      },
    };

    logger.d('Payload:');
    logger.d(jsonEncode(payload));

    final signature = EthSigUtil.signTypedData(
      privateKey: privateKey,
      jsonData: jsonEncode(payload),
      version: TypedDataVersion.V4,
    );

    final split = SignatureUtil.fromRpcSig(signature);

    final obj = {
      'owner': walletAddr.hexEip55,
      'nonce': nonceValue,
      'spender': spenderAddr.hexEip55,
      'value': '0x${amount.toRadixString(16)}',
      'deadline': maxUint256,
      'v': split.v,
      'r': '0x${split.r.toRadixString(16).padLeft(64, '0')}',
      's': '0x${split.s.toRadixString(16).padLeft(64, '0')}',
    };

    if (to != null) {
      obj['to'] = to.hexEip55;
    }

    return jsonEncode(obj);
  }

  static Future<String> getSignedUsdtPayload({
    required GClient client,
    required EthereumAddress walletAddr,
    required String privateKey,
    required String nonceValue,
    required BigInt amount,
    EthereumAddress? to,
  }) async {
    final usdtCoin = Usdt(
      client: client.web3,
      address: EthereumAddress.fromHex(mainUsdtAddress),
    );
    final name = await usdtCoin.name();

    final salt = '0x${mainChainId.toRadixString(16).padLeft(64, '0')}';

    // For transfers: use transfer(relayer, amount) - Relayer receives, deducts fee, forwards to recipient
    // For swaps: use approve(relayer, amount)
    final functionSignature = to != null
        ? usdtCoin.self.function('transfer').encodeCall([
            EthereumAddress.fromHex(mainMetaTxSpender),  // Transfer to relayer (RelayerV4)
            amount
          ])
        : usdtCoin.self.function('approve').encodeCall([
            EthereumAddress.fromHex(mainMetaTxSpender),
            amount
          ]);

    final payload = {
      'types': {
        'EIP712Domain': [
          {
            'name': 'name',
            'type': 'string',
          },
          {
            'name': 'version',
            'type': 'string',
          },
          {
            'name': 'verifyingContract',
            'type': 'address',
          },
          {
            'name': 'salt',
            'type': 'bytes32',
          },
        ],
        'MetaTransaction': [
          {
            'name': 'nonce',
            'type': 'uint256',
          },
          {
            'name': 'from',
            'type': 'address',
          },
          {
            'name': 'functionSignature',
            'type': 'bytes',
          },
        ],
      },
      'primaryType': 'MetaTransaction',
      'domain': {
        'name': name,
        'version': '1',
        'salt': salt,
        'verifyingContract': mainUsdtAddress,
      },
      'message': {
        'from': walletAddr.hexEip55,
        'nonce': nonceValue,
        'functionSignature': functionSignature,
      },
    };

    logger.d('Payload:');
    logger.d(jsonEncode(payload));

    final signature = EthSigUtil.signTypedData(
      privateKey: privateKey,
      jsonData: jsonEncode(payload),
      version: TypedDataVersion.V4,
    );

    final split = SignatureUtil.fromRpcSig(signature);

    final obj = {
      'owner': walletAddr.hexEip55,
      'receiver': to?.hexEip55 ?? EthereumAddress.fromHex(mainMetaTxSpender).hexEip55,
      'functionSignature': bytesToHex(functionSignature, include0x: true),
      'v': split.v,
      'r': '0x${split.r.toRadixString(16).padLeft(64, '0')}',
      's': '0x${split.s.toRadixString(16).padLeft(64, '0')}',
      'value': '0x${amount.toRadixString(16)}',
    };

    return jsonEncode(obj);
  }

  static Future<bool> sendMetaTx(String payload) async {
    final req = await http.post(
      Uri.parse('$mainMetaTxServer/api/transferGau'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: payload,
    );
    logger.i('Meta tx response: ${req.body}');
    return req.statusCode == 200;
  }

  static Future<bool> swapGauToUsdtMeta(String payload) async {
    final req = await http.post(
      Uri.parse('$mainMetaTxServer/api/GAU_USDT_METATX'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: payload,
    );
    logger.i('Meta tx response: ${req.body}');
    return req.statusCode == 200;
  }

  static Future<bool> sendUsdtTransfer(String payload) async {
    final req = await http.post(
      Uri.parse('$mainMetaTxServer/api/USDT_GAU_METATX'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: payload,
    );
    logger.i('Meta tx response: ${req.body}');
    return req.statusCode == 200;
  }

  static Future<bool> swapUsdtToGauMeta(String payload) async {
    final req = await http.post(
      Uri.parse('$mainMetaTxServer/api/SWAP_USDT_GAU_METATX'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: payload,
    );
    logger.i('Meta tx response: ${req.body}');
    return req.statusCode == 200;
  }
}
