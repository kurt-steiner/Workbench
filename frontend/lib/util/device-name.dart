import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

DeviceInfoPlugin? _deviceInfo;

Future<String> get deviceName async {
  _deviceInfo ??= DeviceInfoPlugin();

  if (kIsWeb) {
    WebBrowserInfo webBrowserInfo = await _deviceInfo!.webBrowserInfo;
    return webBrowserInfo.browserName.name;
  }

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidDeviceInfo = await _deviceInfo!.androidInfo;
    return androidDeviceInfo.model;
  }

  if (Platform.isLinux) {
    LinuxDeviceInfo linuxDeviceInfo = await _deviceInfo!.linuxInfo;
    return linuxDeviceInfo.name;
  }

  if (Platform.isWindows) {
    WindowsDeviceInfo windowsDeviceInfo = await _deviceInfo!.windowsInfo;
    return windowsDeviceInfo.computerName;
  }

  return "hello world";
}