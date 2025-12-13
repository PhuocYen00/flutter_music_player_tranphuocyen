import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractor {
  static Future<Color> dominantColorFromPath(String? imagePath) async {
    try {
      if (imagePath == null || imagePath.isEmpty)
        return const Color(0xFF191414);
      final file = File(imagePath);
      if (!await file.exists()) return const Color(0xFF191414);

      final palette = await PaletteGenerator.fromImageProvider(
        FileImage(file),
        size: const Size(128, 128),
        maximumColorCount: 12,
      );

      return palette.dominantColor?.color ?? const Color(0xFF191414);
    } catch (_) {
      return const Color(0xFF191414);
    }
  }
}
