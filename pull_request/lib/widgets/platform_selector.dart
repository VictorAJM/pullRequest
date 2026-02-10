import 'package:flutter/material.dart';
import '../models/platform.dart';
import '../core/theme/app_colors.dart';
import 'platform_card.dart';

class PlatformSelector extends StatelessWidget {
  final String title;
  final Platform? selectedPlatform;
  final List<Platform> availablePlatforms;
  final List<String> disabledPlatformIds;
  final Function(Platform) onPlatformSelected;
  final VoidCallback? onClear;

  const PlatformSelector({
    super.key,
    required this.title,
    required this.selectedPlatform,
    required this.availablePlatforms,
    required this.disabledPlatformIds,
    required this.onPlatformSelected,
    this.onClear,
  });

  void _showPlatformPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Platform',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.darkBlue),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...availablePlatforms.map((platform) {
                final isDisabled = disabledPlatformIds.contains(platform.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PlatformCard(
                    platform: platform,
                    isDisabled: isDisabled,
                    onTap: isDisabled
                        ? null
                        : () {
                            onPlatformSelected(platform);
                            Navigator.pop(context);
                          },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          if (selectedPlatform == null)
            GestureDetector(
              onTap: () => _showPlatformPicker(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBlue, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppColors.darkBlue,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Connect Platform',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _showPlatformPicker(context),
              child: PlatformCard(
                platform: selectedPlatform!,
                isSelected: true,
                onClear: onClear,
              ),
            ),
        ],
      ),
    );
  }
}
