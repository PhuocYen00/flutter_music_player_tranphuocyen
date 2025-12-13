import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:offline_music_player/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService', () {
    late StorageService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      service = StorageService();
    });

    test('save/get last played', () async {
      await service.saveLastPlayed('song_1');
      final id = await service.getLastPlayed();
      expect(id, 'song_1');
    });

    test('save/get volume', () async {
      await service.saveVolume(0.7);
      final v = await service.getVolume();
      expect(v, 0.7);
    });

    test('save/get shuffle', () async {
      await service.saveShuffleState(true);
      final v = await service.getShuffleState();
      expect(v, true);
    });

    test('save/get repeat mode', () async {
      await service.saveRepeatMode(2);
      final v = await service.getRepeatMode();
      expect(v, 2);
    });

    test('save/get last position ms', () async {
      await service.saveLastPositionMs(12345);
      final v = await service.getLastPositionMs();
      expect(v, 12345);
    });
  });
}
