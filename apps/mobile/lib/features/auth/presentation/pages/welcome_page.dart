import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Welcome/onboarding page - first screen users see
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                const Spacer(),

                // App icon and health icons grid
                _buildIconsSection(),

                const SizedBox(height: 48),

                // Welcome text
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to ${AppStrings.appName}',
                        style: AppTypography.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Track your health measurements, log daily activities, and stay connected with your healthcare provider.',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: 'Get Started',
                        onPressed: () => context.push('/auth/scan'),
                        icon: Icons.qr_code_scanner_rounded,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Footer
                Text(
                  'Scan the QR code from your doctor to activate',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnPrimary.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconsSection() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Surrounding icons
          ..._buildSurroundingIcons(),

          // Center app icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: AppColors.glucose,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSurroundingIcons() {
    final icons = [
      (Icons.bloodtype_rounded, AppColors.glucose, -80.0, -60.0),
      (Icons.monitor_heart_rounded, AppColors.heartRate, 80.0, -60.0),
      (Icons.bedtime_rounded, AppColors.sleep, -100.0, 20.0),
      (Icons.restaurant_rounded, AppColors.food, 100.0, 20.0),
      (Icons.fitness_center_rounded, AppColors.exercise, -60.0, 80.0),
      (Icons.medication_rounded, AppColors.medication, 60.0, 80.0),
    ];

    return icons.map((data) {
      final (icon, color, dx, dy) = data;
      return Positioned(
        left: 100 + dx,
        top: 100 + dy,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      );
    }).toList();
  }
}
