import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_text_styles.dart';
import '../services/platform_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final platforms = context.read<PlatformService>().getAvailablePlatforms();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PullRequest'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Transfer history',
            onPressed: () => context.push(AppRoutes.history),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dynamic platform icons driven by PlatformService
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (platforms.isNotEmpty)
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        platforms.first.iconPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      Icon(
                        Icons.arrow_forward,
                        size: 30,
                        color: Colors.grey[800],
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.grey[800],
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  if (platforms.length > 1)
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.asset(
                        platforms[1].iconPath,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Move your music between',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 4),
              const Text(
                'platforms in seconds.',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 80),
              ElevatedButton(
                onPressed: () => context.push(AppRoutes.platformSelection),
                child: const Text('Start Transfer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
