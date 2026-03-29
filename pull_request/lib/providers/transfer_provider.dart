import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../models/transfer_progress.dart';
import '../repositories/transfer_repository.dart';

/// Manages the active playlist transfer and exposes progress state.
///
/// Screens call [startTransfer] once and observe state via [progress],
/// [isCompleted], and [error]. Call [reset] before starting a new transfer.
class TransferProvider extends ChangeNotifier {
  final TransferRepository _repository;
  StreamSubscription<TransferProgress>? _subscription;

  TransferProgress? _progress;
  bool _isCompleted = false;
  String? _error;

  TransferProvider({required TransferRepository repository})
      : _repository = repository;

  TransferProgress? get progress => _progress;
  bool get isCompleted => _isCompleted;
  bool get hasError => _error != null;
  String? get error => _error;
  List<Song> get failedSongs => _progress?.failedItems ?? const [];

  bool get isTransferring =>
      _progress != null && !_isCompleted && _error == null;

  double get overallProgress => _progress?.progress ?? 0.0;

  /// Starts transferring [playlistId] from [sourcePlatformId] to the
  /// opposite platform (determined by the backend).
  void startTransfer(String playlistId, String sourcePlatformId) {
    _reset();
    notifyListeners();

    _subscription = _repository
        .transferPlaylist(playlistId, sourcePlatformId)
        .listen(
      (progress) {
        _progress = progress;
        if (progress.status == 'completed' || progress.status == 'error') {
          _isCompleted = true;
          if (progress.status == 'error') {
            _error = 'Transfer failed';
          }
        }
        notifyListeners();
      },
      onError: (Object e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void reset() {
    _reset();
    notifyListeners();
  }

  void _reset() {
    _subscription?.cancel();
    _subscription = null;
    _progress = null;
    _isCompleted = false;
    _error = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
