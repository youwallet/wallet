import 'dart:io' show Platform;
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';


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
