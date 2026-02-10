import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class PullRequestHome extends StatelessWidget {
  const PullRequestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.lightBlue,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'PullRequest',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/icons/spotify_icon.png',
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
                      Icon(Icons.arrow_back, size: 30, color: Colors.grey[800]),
                    ],
                  ),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Image.asset(
                      'assets/icons/youtube_music_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              const Text(
                'Move your music between',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'platforms in seconds.',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 80),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.background,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Start Transfer',
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
