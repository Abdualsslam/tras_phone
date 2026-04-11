library;

import 'dart:developer' as developer;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AuthDeviceInfoService {
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      String platform;
      String? deviceId;
      String? deviceName;
      String? deviceModel;
      String? osVersion;

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        platform = 'android';
        deviceId = androidInfo.id;
        deviceName = androidInfo.model;
        deviceModel = androidInfo.device;
        osVersion = androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        platform = 'ios';
        deviceId = iosInfo.identifierForVendor;
        deviceName = iosInfo.name;
        deviceModel = iosInfo.model;
        osVersion = iosInfo.systemVersion;
      } else {
        platform = 'web';
      }

      return {
        'platform': platform,
        'version': packageInfo.version,
        if (deviceId != null) 'deviceId': deviceId,
        if (deviceName != null) 'deviceName': deviceName,
        if (deviceModel != null) 'deviceModel': deviceModel,
        if (osVersion != null) 'osVersion': osVersion,
      };
    } catch (e) {
      developer.log('Error getting device info: $e', name: 'AuthDeviceInfoService');
      return {
        'platform': Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'web'),
      };
    }
  }
}
