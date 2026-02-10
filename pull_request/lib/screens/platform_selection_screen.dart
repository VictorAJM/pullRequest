import 'package:flutter/material.dart';
import '../models/platform.dart';
import '../models/authorization_result.dart';
import '../services/platform_service.dart';
import '../widgets/platform_selector.dart';
import '../core/theme/app_colors.dart';
import 'platform_authorization_screen.dart';

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

  Future<void> _handleSelectPlaylists() async {
    final sourceResult = await Navigator.push<AuthorizationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformAuthorizationScreen(
          platform: _sourcePlatform!,
          isSource: true,
        ),
      ),
    );

    if (sourceResult == null || !sourceResult.isAuthorized) {
      if (mounted) {
        _showAuthorizationError(
          sourceResult?.platform.name ?? _sourcePlatform!.name,
          sourceResult?.errorMessage ?? 'Authorization was cancelled',
        );
      }
      return;
    }

    if (!mounted) return;

    final destinationResult = await Navigator.push<AuthorizationResult>(
      context,
      MaterialPageRoute(
        builder: (context) => PlatformAuthorizationScreen(
          platform: _destinationPlatform!,
          isSource: false,
        ),
      ),
    );

    if (destinationResult == null || !destinationResult.isAuthorized) {
      if (mounted) {
        _showAuthorizationError(
          destinationResult?.platform.name ?? _destinationPlatform!.name,
          destinationResult?.errorMessage ?? 'Authorization was cancelled',
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Both platforms authorized! Ready to select playlists.',
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
    }
  }

  void _showAuthorizationError(String platformName, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Authorization Failed',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Could not authorize $platformName: $message',
          style: TextStyle(color: AppColors.darkBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
