import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:wallet/conf.dart';
import 'package:wallet/models/currency.dart';
import 'package:wallet/repository/atm.dart';
import 'package:wallet/repository/coins/erc20.dart';
import 'package:wallet/repository/coins/gau.dart';
import 'package:wallet/repository/coins/gauf.dart';
import 'package:wallet/repository/coins/matic.dart';
import 'package:wallet/repository/coins/usd.dart';
import 'package:wallet/repository/rpc.dart';
import 'package:wallet/repository/wallet.dart';
import 'package:wallet/services/bip.dart';
import 'package:wallet/utils/gstream.dart';

final walletProvider = Provider((_) => WalletProvider());

const _safeMnemonic = 'mnemonic';
const _safeBackup = 'backup';
const _safePrivateKey = 'private_key';

class WalletProvider {
  late Box<String> storage;

  GWallet? wallet;
  List<Currency>? currencies;
  AtmMachine? atm;

  late GClient client;

  // Currency? matic;
  // Currency? gau;

  bool initialized = false;

  Future<void> init(GClient client) async {
    this.client = client;

    storage = Hive.box<String>(safeBox);
    if (!storage.containsKey(_safePrivateKey)) {
      return;
    }

    // print(storage.get(_safeMnemonic));
    final privateKey = storage.get(_safePrivateKey)!;

    wallet = GWallet.fromPrivateKey(privateKey);

    _initCurrencies();

    atm = AtmMachine(wallet: wallet!, client: client);

    initialized = true;
  }

  void _initCurrencies() {
    final maticRepository = MaticCoin(wallet: wallet!, client: client);
    final gauRepository = GauCoin(wallet: wallet!, client: client);
    final gaufRepository = GaufCoin(wallet: wallet!, client: client);

    final gau = Currency(
      repo: gauRepository,
      type: CurrencyTicker.gau,
      balance: GStream(gauRepository.getBalance().asBroadcastStream()),
      price: GStream(gauRepository.getPriceInUSD().asBroadcastStream()),
    );

    final matic = Currency(
      repo: maticRepository,
      type: CurrencyTicker.matic,
      balance: GStream(maticRepository.getBalance().asBroadcastStream()),
      price: GStream(maticRepository.getPriceInUSD().asBroadcastStream()),
    );

    final investorModeBox = Hive.box<String>(safeBox).get('investor_mode');
    final investorMode = investorModeBox != null && investorModeBox != 'false';
    currencies = [gau, matic];

    if (investorMode) {
      final gauf = Currency(
        repo: gaufRepository,
        type: CurrencyTicker.gauf,
        balance: GStream(gaufRepository.getBalance().asBroadcastStream()),
        price: GStream(gaufRepository.getPriceInMatic().asBroadcastStream()),
        investOnly: true,
      );
      currencies!.add(gauf);
    }

    // if (displayUsdc) {
    final usdcRepository = UsdCoin(
      wallet: wallet!,
      client: client,
      type: UsdCoinType.usdc,
    );

    final usdc = Currency(
      repo: usdcRepository,
      type: CurrencyTicker.usdc,
      balance: GStream(usdcRepository.getBalance().asBroadcastStream()),
      // price: GStream(usdcRepository.getPriceInUSD().asBroadcastStream()),
      exchangeOnly: true,
    );
    currencies!.add(usdc);
    // }

    // if (displayUsdt) {
    final usdtRepository = UsdCoin(
      wallet: wallet!,
      client: client,
      type: UsdCoinType.usdt,
    );
    final usdt = Currency(
      repo: usdtRepository,
      type: CurrencyTicker.usdt,
      balance: GStream(usdtRepository.getBalance().asBroadcastStream()),
      price: GStream(usdtRepository.getPriceInUSD().asBroadcastStream()),
    );
    currencies!.insert(1, usdt);

    final exchange = Hive.box<String>(safeBox).get('enable_exchange') == 'true';
    if (exchange) {
      // UNISWAP TOKENS NOW
      final wethRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapWeth,
        decimals: mainUniswapWethDecimals,
      );
      currencies!.add(
        Currency(
          repo: wethRepo,
          type: CurrencyTicker.weth,
          balance: GStream(wethRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );

      final wbtcRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapWbtc,
        decimals: mainUniswapWbtcDecimals,
      );
      currencies!.add(
        Currency(
          repo: wbtcRepo,
          type: CurrencyTicker.wbtc,
          balance: GStream(wbtcRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );

      final w$cRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapW$c,
        decimals: mainUniswapWb$cDecimals,
      );
      currencies!.add(
        Currency(
          repo: w$cRepo,
          type: CurrencyTicker.w$c,
          balance: GStream(w$cRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );

      final agEurRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapAgEur,
        decimals: mainUniswapAgEurDecimals,
      );
      currencies!.add(
        Currency(
          repo: agEurRepo,
          type: CurrencyTicker.agEur,
          balance: GStream(agEurRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );

      final daiRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapDai,
        decimals: mainUniswapDaiDecimals,
      );
      currencies!.add(
        Currency(
          repo: daiRepo,
          type: CurrencyTicker.dai,
          balance: GStream(daiRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );
      final linkRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapLink,
        decimals: mainUniswapLinkDecimals,
      );
      currencies!.add(
        Currency(
          repo: linkRepo,
          type: CurrencyTicker.link,
          balance: GStream(linkRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );

      final crvRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapCrv,
        decimals: mainUniswapCrvDecimals,
      );
      currencies!.add(
        Currency(
          repo: crvRepo,
          type: CurrencyTicker.crv,
          balance: GStream(crvRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );
      final bobRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapBob,
        decimals: mainUniswapCrvDecimals,
      );
      currencies!.add(
        Currency(
          repo: bobRepo,
          type: CurrencyTicker.bob,
          balance: GStream(bobRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );
      final aaveRepo = Erc20Coin(
        wallet: wallet!,
        client: client,
        addr: mainUniswapAave,
        decimals: mainUniswapAaveDecimals,
      );
      currencies!.add(
        Currency(
          repo: aaveRepo,
          type: CurrencyTicker.aave,
          balance: GStream(aaveRepo.getBalance().asBroadcastStream()),
          exchangeOnly: true,
        ),
      );
    }
  }

  Future<void> saveBackupWallet(String backupFile) async {
    await storage.put(_safeBackup, backupFile);
  }

  String? getBackupWallet() {
    return storage.get(_safeBackup);
  }

  Future<void> saveMnemonic(String mnemonic) async {
    await storage.put(_safeMnemonic, mnemonic);

    // caching the private key
    final key = await computeMnemonicToPrivateHex(mnemonic);
    await storage.put(_safePrivateKey, key);
  }
}
