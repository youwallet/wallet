
import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import "package:hex/hex.dart";
import 'package:web3dart/credentials.dart';
//import 'package:shared_preferences/shared_preferences.dart';

//abstract class TokenService {
//  String generateMnemonic();
//  String maskAddress(String address);
//  String getPrivateKey(String mnemonic);
//  Future<EthereumAddress> getPublicAddress(String privateKey);
//  Future<bool> setupFromMnemonic(String mnemonic);
//  Future<bool> setupFromPrivateKey(String privateKey);
//  String entropyToMnemonic(String entropyMnemonic);
//}

class TokenService {
//  IConfigurationService _configService;
//  AddressService(this._configService);



  // 获取助记词
  static String generateMnemonic() {
    String randomMnemonic = bip39.generateMnemonic();
    return randomMnemonic;
  }


//  static String getPrivateKey(String randomMnemonic) {
//
//    String hexSeed = bip39.mnemonicToSeedHex(randomMnemonic);
//
//    KeyData master = ED25519_HD_KEY.getMasterKeyFromSeed(hexSeed);
//    return HEX.encode(master.key);
//  }

  static  maskAddress(String address) {
    print(address);
    return "${address.substring(0, 6)}...${address.substring(address.length - 6, address.length)}";
  }

  String entropyToMnemonic(String entropyMnemonic) {
    return bip39.entropyToMnemonic(entropyMnemonic);
  }


   // 助记词转密钥
  static String getPrivateKey(String mnemonic) {
    String seed = bip39.mnemonicToSeedHex(mnemonic);
    KeyData master = ED25519_HD_KEY.getMasterKeyFromSeed(seed);
    return HEX.encode(master.key);
  }

  static Future<EthereumAddress> getPublicAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();
    return address;
  }

  @override
  Future<bool> setupFromMnemonic(String mnemonic) async {
    final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
//    await _configService.setPrivateKey(null);
//    await _configService.setMnemonic(cryptMnemonic);
//    await _configService.setupDone(true);
    return true;
  }

  @override
  Future<bool> setupFromPrivateKey(String privateKey) async {
//    await _configService.setMnemonic(null);
//    await _configService.setPrivateKey(privateKey);
//    await _configService.setupDone(true);
    return true;
  }
}
