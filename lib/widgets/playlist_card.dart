import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PlaylistCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;

  const PlaylistCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: leading ??
            const Icon(Icons.queue_music, color: Colors.white70, size: 28),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        subtitle: Text(subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: trailing,
      ),
    );
  }
}
