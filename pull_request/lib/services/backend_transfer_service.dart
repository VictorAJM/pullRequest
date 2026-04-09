import 'dart:convert';
import '../core/errors/app_exception.dart';
import '../models/transfer_progress.dart';
import '../repositories/transfer_repository.dart';
import 'api_client.dart';

/// Implements [TransferRepository] by calling the backend transfer API
/// and listening to SSE progress updates.
class BackendTransferService implements TransferRepository {
  final ApiClient _api;

  BackendTransferService(this._api);

  @override
  Stream<TransferProgress> transferPlaylist(
    String playlistId,
    String sourcePlatformId,
  ) async* {
    // Start the transfer on the backend.
    final startResponse = await _api.post('/transfer/start', body: {
      'platform_from': sourcePlatformId,
      'playlist_id': playlistId,
    });

    if (startResponse.statusCode == 409) {
      throw TransferException('A transfer is already in progress');
    }
    if (startResponse.statusCode != 200) {
      throw TransferException(
        'Failed to start transfer (${startResponse.statusCode})',
      );
    }

    // Connect to the SSE stream for progress updates.
    final sseResponse = await _api.getStream('/transfer/updates');

    if (sseResponse.statusCode != 200) {
      throw TransferException(
        'Failed to connect to transfer updates (${sseResponse.statusCode})',
      );
    }

    await for (final line in sseResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data: ')) continue;

      final jsonStr = trimmed.substring(6).trim();
      if (jsonStr.isEmpty) continue;

      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final progress = TransferProgress.fromJson(data);
        yield progress;

        if (progress.status == 'completed' || progress.status == 'error') {
          return;
        }
      } catch (e) {
        throw TransferException('Failed to parse update (length: ${jsonStr.length}): $e');
      }
    }
  }

  @override
  Stream<TransferProgress> resumeTransfer() async* {
    final sseResponse = await _api.getStream('/transfer/updates');

    if (sseResponse.statusCode != 200) {
      throw TransferException('No active transfer');
    }

    await for (final line in sseResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      final trimmed = line.trim();
      if (!trimmed.startsWith('data: ')) continue;

      final jsonStr = trimmed.substring(6).trim();
      if (jsonStr.isEmpty) continue;

      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final progress = TransferProgress.fromJson(data);
        yield progress;

        if (progress.status == 'completed' || progress.status == 'error') {
          return;
        }
      } catch (e) {
        throw TransferException('Failed to parse update (length: ${jsonStr.length}): $e');
      }
    }
  }
}
