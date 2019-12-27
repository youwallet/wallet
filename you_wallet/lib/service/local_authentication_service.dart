import 'dart:io' show Platform;
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/**
*
 * link: https://www.jianshu.com/p/06ba43743b1f
 * _auth变量只是实例化LocalAuthentication库，这里没什么特别的。
 * bool _isProtectionEnabled跟踪相应的设置，在真实的应用程序中，它应该存储在共享首选项中，尽管它超出了本文的范围。
 * isAuthenticated变量将跟踪身份验证
 * 最后，authenticate方法使用OS相关对话框启动身份验证流程。
 * stickyAuth属性设置为true，因此如果应用程序被系统置于后台，则插件不会返回失败。例如，如果用户在有机会进行身份验证之前收到了呼叫。将stickyAuth属性设置为false，插件将返回我们的dart代码失败。
**/

class LocalAuthenticationService {
  final _auth = LocalAuthentication();
  bool _isProtectionEnabled = false;

  bool get isProtectionEnabled => _isProtectionEnabled;

  set isProtectionEnabled(bool enabled) => _isProtectionEnabled = enabled;

  bool isAuthenticated = false;

  Future authenticate() async {
    if (_isProtectionEnabled) {
      try {
        List<BiometricType> availableBiometrics =
        await _auth.getAvailableBiometrics();

        if (Platform.isIOS) {
          if (availableBiometrics.contains(BiometricType.face)) {
            // Face ID.
          } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
            print("there is touch id");
            // Touch ID.
          }
        }
        isAuthenticated = await _auth.authenticateWithBiometrics(
          localizedReason: 'authenticate to access',
          useErrorDialogs: true,
          stickyAuth: true,
        );
        print(isAuthenticated);
      } on PlatformException catch (e) {
        print(e);
      }
    } else {
      return false;
    }
  }
}
