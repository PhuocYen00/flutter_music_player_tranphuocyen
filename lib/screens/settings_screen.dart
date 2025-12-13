import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/audio_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF191414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191414),
        title: const Text('Cài đặt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Âm lượng',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Slider(
              value: provider.volume,
              min: 0.0,
              max: 1.0,
              onChanged: provider.setVolume,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tốc độ phát',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Slider(
              value: provider.speed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              label: 'x${provider.speed.toStringAsFixed(1)}',
              onChanged: provider.setSpeed,
            ),
            const SizedBox(height: 10),
            const Text(
              '0.5x – chậm | 1.0x – bình thường | 2.0x – nhanh',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
