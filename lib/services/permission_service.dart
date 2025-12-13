import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMusicPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.isGranted) {
        return true;
      }

      final status = await Permission.audio.request();
      return status.isGranted;
    }

    return true;
  }

  Future<bool> hasMusicPermission() async {
    if (Platform.isAndroid) {
      return await Permission.audio.isGranted;
    }
    return true;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
