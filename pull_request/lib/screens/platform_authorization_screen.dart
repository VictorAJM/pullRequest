import 'package:flutter/material.dart';
import '../models/platform.dart';
import '../models/authorization_result.dart';
import '../core/theme/app_colors.dart';

class PlatformAuthorizationScreen extends StatefulWidget {
  final Platform platform;
  final bool isSource;

  const PlatformAuthorizationScreen({
    super.key,
    required this.platform,
    required this.isSource,
  });

  @override
  State<PlatformAuthorizationScreen> createState() =>
      _PlatformAuthorizationScreenState();
}

class _PlatformAuthorizationScreenState
    extends State<PlatformAuthorizationScreen> {
  bool _isAuthorizing = false;

  Future<void> _handleAuthorize() async {
    setState(() {
      _isAuthorizing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      final result = AuthorizationResult.success(widget.platform);
      Navigator.pop(context, result);
    }
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.darkBlue),
          onPressed: _handleCancel,
        ),
        centerTitle: true,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    widget.platform.iconPath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Connect to ${widget.platform.name}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                'To transfer your music, PullRequest needs permission to view your public playlists. We will never post on your behalf or share your data.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAuthorizing ? null : _handleAuthorize,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.lightBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isAuthorizing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Authorize with ${widget.platform.name}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isAuthorizing ? null : _handleCancel,
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
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
