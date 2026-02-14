import 'package:flutter/material.dart';
import '../models/playlist.dart';
import '../core/theme/app_colors.dart';
import '../screens/playlist_details_screen.dart';

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

  void _showPlaylistDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailsScreen(playlist: playlist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightBlue,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            // Playlist info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playlist.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.music_note, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${playlist.trackCount} tracks',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (playlist.description != null &&
                      playlist.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      playlist.description!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Info button
            IconButton(
              icon: Icon(Icons.info_outline, color: AppColors.primaryBlue),
              onPressed: () => _showPlaylistDetails(context),
              tooltip: 'View songs',
            ),
          ],
        ),
      ),
    );
  }
}
