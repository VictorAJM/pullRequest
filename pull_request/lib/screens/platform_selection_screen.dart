import 'package:flutter/material.dart';
import '../models/platform.dart';
import '../services/platform_service.dart';
import '../widgets/platform_selector.dart';
import '../core/theme/app_colors.dart';

class PlatformSelectionScreen extends StatefulWidget {
  const PlatformSelectionScreen({super.key});

  @override
  State<PlatformSelectionScreen> createState() =>
      _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  final PlatformService _platformService = PlatformService();
  Platform? _sourcePlatform;
  Platform? _destinationPlatform;

  bool get _canProceed =>
      _sourcePlatform != null && _destinationPlatform != null;

  List<String> get _disabledSourcePlatforms =>
      _destinationPlatform != null ? [_destinationPlatform!.id] : [];

  List<String> get _disabledDestinationPlatforms =>
      _sourcePlatform != null ? [_sourcePlatform!.id] : [];

  void _handleSourceSelection(Platform platform) {
    setState(() {
      _sourcePlatform = platform;
      if (_destinationPlatform?.id == platform.id) {
        _destinationPlatform = null;
      }
    });
  }

  void _handleDestinationSelection(Platform platform) {
    setState(() {
      _destinationPlatform = platform;
      if (_sourcePlatform?.id == platform.id) {
        _sourcePlatform = null;
      }
    });
  }

  void _handleClearSource() {
    setState(() {
      _sourcePlatform = null;
    });
  }

  void _handleClearDestination() {
    setState(() {
      _destinationPlatform = null;
    });
  }

  void _handleSelectPlaylists() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transferring from ${_sourcePlatform!.name} to ${_destinationPlatform!.name}',
        ),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platforms = _platformService.getAvailablePlatforms();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'PullRequest',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              PlatformSelector(
                title: 'FROM (Source)',
                selectedPlatform: _sourcePlatform,
                availablePlatforms: platforms,
                disabledPlatformIds: _disabledSourcePlatforms,
                onPlatformSelected: _handleSourceSelection,
                onClear: _handleClearSource,
              ),
              const SizedBox(height: 24),
              Icon(Icons.arrow_downward, size: 32, color: AppColors.darkBlue),
              const SizedBox(height: 24),
              PlatformSelector(
                title: 'TO (Destination)',
                selectedPlatform: _destinationPlatform,
                availablePlatforms: platforms,
                disabledPlatformIds: _disabledDestinationPlatforms,
                onPlatformSelected: _handleDestinationSelection,
                onClear: _handleClearDestination,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _canProceed ? _handleSelectPlaylists : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.background,
                    disabledBackgroundColor: AppColors.lightBlue,
                    disabledForegroundColor: Colors.grey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Select Playlists',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
