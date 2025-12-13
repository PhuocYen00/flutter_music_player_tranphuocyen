import 'package:flutter/material.dart';
import '../utils/color_extractor.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  Color _dominant = AppColors.background;

  Color get dominant => _dominant;

  LinearGradient get backgroundGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _dominant.withAlpha((0.35 * 255).toInt()),
          AppColors.background,
        ],
      );

  Future<void> updateFromAlbumArt(String? albumArtPath) async {
    final c = await ColorExtractor.dominantColorFromPath(albumArtPath);
    _dominant = c;
    notifyListeners();
  }

  void reset() {
    _dominant = AppColors.background;
    notifyListeners();
  }
}
