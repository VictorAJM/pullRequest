import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_colors.dart';
import '../models/playlist.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final bool isSelected;
  final VoidCallback? onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Theme.of(context).dividerColor,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Playlist thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: playlist.imageUrl != null
                  ? Image.network(
                      playlist.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, trace) => _defaultIcon(),
                    )
                  : _defaultIcon(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.music_note,
                          size: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                      const SizedBox(width: 4),
                      Text(
                        '${playlist.itemCount} tracks',
                        style: TextStyle(
                            fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Details button
            IconButton(
              icon: const Icon(Icons.info_outline,
                  color: AppColors.primaryBlue),
              tooltip: 'View songs',
              onPressed: () => context.push(
                AppRoutes.playlistDetails,
                extra: playlist,
              ),
            ),
            // Selection indicator
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primaryBlue : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.music_note, color: AppColors.primaryBlue),
    );
  }
}
