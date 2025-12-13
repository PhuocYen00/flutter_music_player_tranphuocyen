import 'dart:io';
import 'package:flutter/material.dart';

class AlbumArt extends StatelessWidget {
  final String? path;
  final double size;
  final double radius;

  const AlbumArt({
    super.key,
    required this.path,
    this.size = 56,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    Widget img;

    final p = path;
    if (p != null && p.isNotEmpty && File(p).existsSync()) {
      img = Image.file(
        File(p),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      img = _fallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(width: size, height: size, child: img),
    );
  }

  Widget _fallback() {
    return Image.asset(
      'assets/images/default_album_art.png',
      fit: BoxFit.cover,
    );
  }
}
