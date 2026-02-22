import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Displays a history of completed playlist transfers.
///
/// ## Implementation roadmap
///
/// 1. Add a `TransferRecord` model:
///    ```dart
///    class TransferRecord {
///      final String id;
///      final DateTime timestamp;
///      final String sourcePlatformId;
///      final String destinationPlatformId;
///      final int totalSongs;
///      final int transferredSongs;
///      final TransferStatus status;
///      final List<String> playlistNames;
///    }
///    ```
///
/// 2. Add a `HistoryRepository` abstract interface with a local persistence
///    implementation (e.g. sqflite or Hive).
///
/// 3. Create a `HistoryProvider` and inject it in `main.dart`.
///
/// 4. Replace the empty state below with a `ListView` of `TransferRecordCard`
///    widgets and connect to `HistoryProvider`.
class TransferHistoryScreen extends StatelessWidget {
  const TransferHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.history,
                  size: 48,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text('No transfers yet', style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                'Your completed transfers will appear here.',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
