import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class SecurityService {
  static final _auth = LocalAuthentication();

  static Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access your expenses',
        persistAcrossBackgrounding: true,
      );
    } on PlatformException {
      return false;
    }
  }
}
