import 'package:wallet/models/currency.dart';

const Network network = Network.main;

const Duration importantDataUpdateInterval = Duration(seconds: 6);
const Duration erc20DataUpdateInterval = Duration(seconds: 8);
const Duration secondaryDataUpdateInterval = Duration(seconds: 16);

const List<String> mainRPC = [
  'https://polygon-mainnet.infura.io/v3/7248d1d106eb4597836b43b5378af021',
];

const List<String> testRPC = [
  'https://rpc-mumbai.matic.today',
  'https://matic-mumbai.chainstacklabs.com',
  'https://rpc-mumbai.maticvigil.com',
  'https://matic-testnet-archive-rpc.bwarelabs.com',
  'https://polygon-mumbai.g.alchemy.com/v2/oJ34f41hliSkLlsUnUoV8s6LyQ7usEq5',
];

const String mainMetaTxSpender = '0xA7E2f9aF0023CF4558Baac747Dd01179297dDE8D';  // RelayerV4
const String mainMetaTxServer = 'https://metatx.vercel.app';

// UNISWAP

const String mainUniswap3Quote02 = '0x61fFE014bA17989E743c5F6cB21bF9697530B21e';

const String mainUniswap3Router02 =
    '0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45';
const String mainWmaticAddress = '0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270';

const String mainUniswapWeth = '0x7ceb23fd6bc0add59e62ac25578270cff1b9f619';
const int mainUniswapWethDecimals = 18;

const String mainUniswapWbtc = '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6';
const int mainUniswapWbtcDecimals = 8;

const String mainUniswapW$c = '0x77A6f2e9A9E44fd5D5C3F9bE9E52831fC1C3C0A0';
const int mainUniswapWb$cDecimals = 18;

const String mainUniswapAgEur = '0xE0B52e49357Fd4DAf2c15e02058DCE6BC0057db4';
const int mainUniswapAgEurDecimals = 18;

const String mainUniswapDai = '0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063';
const int mainUniswapDaiDecimals = 18;

const String mainUniswapLink = '0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39';
const int mainUniswapLinkDecimals = 18;

const String mainUniswapCrv = '0x172370d5Cd63279eFa6d502DAB29171933a610AF';
const int mainUniswapCrvDecimals = 18;

const String mainUniswapBob = '0xB0B195aEFA3650A6908f15CdaC7D92F8a5791B0B';
const int mainUniswapBobDecimals = 18;

const String mainUniswapAave = '0xD6DF932A45C0f255f85145f286eA0b292B21C90B';
const int mainUniswapAaveDecimals = 18;

// todo: when changing also set corrent decimal places below
const String mainUsdcAddress = '0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174';
const String testUsdcAddress = '0x0FA8781a83E46826621b3BC094Ea2A0212e71B23';

// todo: when changing also set corrent decimal places below
const String mainUsdtAddress = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';
const String testUsdtAddress = '0xeaBc4b91d9375796AA4F69cC764A4aB509080A58';

const String mainUsdcLinkAddress = '0xfE4A8cc5b5B2366C1B58Bea3858e81843581b2F7';
const String testUsdcLinkAddress = '0x572dDec9087154dC5dfBB1546Bb62713147e0Ab0';

const String mainUsdtLinkAddress = '0x0A6513e40db6EB1b165753AD52E80663aeA50545';
const String testUsdtLinkAddress = '0x92C09849638959196E976289418e5973CC96d645';

const gauSwapCoin = CurrencyTicker.usdt;
// const displayUsdc = false;
const displayUsdt = true;

const String mainGasStation = 'https://gasstation.polygon.technology/v2';
const String testGasStation = 'https://gasstation-mumbai.matic.today/v2';

const String mainGauAddress = '0xcBccdf5c97aac84f7536B255B5D35ED57AD363A3';
const String testGauAddress = '0x535901718A990a0Dc932522B8f8C0E1DC21FbdB8';

const String mainGauiAddress = '0xa8857637e01410738D29bE30b13C992bBDF37e92';
const String testGaufAddress = '0xef9985c6fBC87B336e412C11830428C5E7ba78CA';

// gaui
const String mainGauiRateAddress = '0x6e9c422b36B32F57474AC8c9763C0A5870197691';
const String testGaufRateAddress = '0x6EA8C6e70f472A7F0C5Cc76B7A600EaFE6Ce7060';

const String mainPolygonScan = 'https://polygonscan.com';
const String testPolygonScan = 'https://mumbai.polygonscan.com';

const int mainChainId = 137;
const int testChainId = 80001;

// https://docs.chain.link/docs/matic-addresses
const String mainMaticLinkAddress =
    '0xAB594600376Ec9fD91F8e885dADF0CE036862dE0';
const String testMaticLinkAddress =
    '0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada';

const String mainGauLinkAddress = '0xFb0951bA1929336D2F621Cc0f0928D89A91D508f';
const String testGauLinkAddress = '0xbc97e050465aD8Df812007e1A485bBfa826d952f';

const String mainAtmAddress = '0x30df9c917063d03f9a7cEFC1f27f8AAdE2cF8419';
const String testAtmAddress = '0xfB3bdf5ABeB81a8E1a2CFE697CB4CfC924407b2E';
const String mainAtmSpendingAddress =
    '0x22e13c0161544973886287786FCCCc018F8F3F23';
const String testAtmSpendingAddress =
    '0x67EEd10aA3E7997106E7E344E2EDed3a0D9493B0';

const int gauDecimals = 8;
const int usdtDecimals = 6;
const int usdcDecimals = 6;
const int gaufDecimals = 18;
const int maticLinkDecimals = 8;
const int gauLinkDecimals = 6;
const int usdLinkDecimals = 8;
const int maticDecimals = 18;

enum Network {
  test,
  main,
}

const safeBox = 'safe';

const int breakPointWidth = 700;

const double polVisibilityThreshold = 0.000001;
const double gaslessBalanceThreshold = 0.05;
const double polMaxSendReserve = 0.01;
