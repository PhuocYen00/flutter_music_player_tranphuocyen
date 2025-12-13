import 'package:just_audio/just_audio.dart';

LoopMode intToLoopMode(int value) {
  if (value == 1) return LoopMode.all;
  if (value == 2) return LoopMode.one;
  return LoopMode.off;
}

int loopModeToInt(LoopMode mode) {
  if (mode == LoopMode.all) return 1;
  if (mode == LoopMode.one) return 2;
  return 0;
}
