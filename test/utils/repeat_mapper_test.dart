import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:offline_music_player/utils/repeat_mapper.dart';

void main() {
  test('intToLoopMode', () {
    expect(intToLoopMode(0), LoopMode.off);
    expect(intToLoopMode(1), LoopMode.all);
    expect(intToLoopMode(2), LoopMode.one);
    expect(intToLoopMode(999), LoopMode.off);
  });

  test('loopModeToInt', () {
    expect(loopModeToInt(LoopMode.off), 0);
    expect(loopModeToInt(LoopMode.all), 1);
    expect(loopModeToInt(LoopMode.one), 2);
  });
}
