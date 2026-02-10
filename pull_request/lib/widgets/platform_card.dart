import 'package:flutter/material.dart';
import '../models/platform.dart';
import '../core/theme/app_colors.dart';

class PlatformCard extends StatelessWidget {
  final Platform platform;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const PlatformCard({
    super.key,
    required this.platform,
    this.isSelected = false,
    this.isDisabled = false,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightBlue,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Opacity(
              opacity: isDisabled ? 0.4 : 1.0,
              child: Image.asset(
                platform.iconPath,
                width: 32,
                height: 32,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              platform.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDisabled ? Colors.grey : AppColors.darkBlue),
              ),
            ),
            const Spacer(),
            if (isSelected && onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
