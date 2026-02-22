import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/playlist.dart';
import '../models/transfer_progress.dart';
import '../repositories/transfer_repository.dart';

/// Manages the active playlist transfer stream and exposes progress state.
///
/// Screens should call [startTransfer] once and observe state via
/// [currentProgress], [overallProgress], [isCompleted], and [isCancelled].
/// Call [reset] before starting a new transfer.
class TransferProvider extends ChangeNotifier {
  final TransferRepository _repository;
  StreamSubscription<TransferProgress>? _subscription;

  TransferProgress? _currentProgress;
  int _completedPlaylists = 0;
  int _totalPlaylists = 0;
  bool _isCancelled = false;
  bool _isCompleted = false;
  String? _errorMessage;

  TransferProvider({required TransferRepository repository})
      : _repository = repository;

  // ── State accessors ───────────────────────────────────────────────────────

  TransferProgress? get currentProgress => _currentProgress;
  int get completedPlaylists => _completedPlaylists;
  int get totalPlaylists => _totalPlaylists;
  bool get isCancelled => _isCancelled;
  bool get isCompleted => _isCompleted;
  String? get errorMessage => _errorMessage;

  bool get isIdle =>
      _currentProgress == null && !_isCompleted && !_isCancelled;

  /// Overall progress as a value from 0.0 to 1.0.
  double get overallProgress {
    if (_totalPlaylists == 0) return 0.0;
    double progress = _completedPlaylists.toDouble();
    if (_currentProgress?.status == TransferStatus.inProgress) {
      progress += _currentProgress!.progress;
    }
    return progress / _totalPlaylists;
  }

  // ── Transfer control ──────────────────────────────────────────────────────

  /// Starts transferring [playlists] from [sourcePlatformId] to
  /// [destinationPlatformId]. Resets any previous transfer state first.
  void startTransfer(
    List<Playlist> playlists,
    String sourcePlatformId,
    String destinationPlatformId,
  ) {
    _reset();
    _totalPlaylists = playlists.length;
    notifyListeners();

    final stream = _repository.transferPlaylists(
      playlists,
      sourcePlatformId,
      destinationPlatformId,
    );

    _subscription = stream.listen(
      _onProgress,
      onError: _onError,
      onDone: _onDone,
    );
  }

  /// Cancels the in-flight transfer.
  Future<void> cancel() async {
    if (_isCompleted || _isCancelled) return;
    _isCancelled = true;
    await _subscription?.cancel();
    _subscription = null;
    await _repository.cancelTransfer();
    notifyListeners();
  }

  /// Resets all transfer state, ready for a new transfer.
  void reset() {
    _reset();
    notifyListeners();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _onProgress(TransferProgress progress) {
    if (_isCancelled) return;
    _currentProgress = progress;
    if (progress.status == TransferStatus.completed) {
      _completedPlaylists++;
      if (_completedPlaylists == _totalPlaylists) {
        _isCompleted = true;
      }
    }
    notifyListeners();
  }

  void _onError(Object error) {
    _errorMessage = error.toString();
    notifyListeners();
  }

  void _onDone() {
    if (!_isCompleted && !_isCancelled) {
      _isCompleted = true;
      notifyListeners();
    }
  }

  void _reset() {
    _subscription?.cancel();
    _subscription = null;
    _currentProgress = null;
    _completedPlaylists = 0;
    _totalPlaylists = 0;
    _isCancelled = false;
    _isCompleted = false;
    _errorMessage = null;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
