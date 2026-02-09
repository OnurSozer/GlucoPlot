import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';

/// Welcome/onboarding page - first screen users see
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _opacityController;

  @override
  void initState() {
    super.initState();
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _opacityController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                        '${l10n.welcome}',
                        style: AppTypography.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.welcomeDescription,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: l10n.getStarted,
                        onPressed: () => context.push('/auth/scan'),
                        icon: Icons.qr_code_scanner_rounded,
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Footer
                Text(
                  l10n.scanQrDescription,
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
    if (_opacityController == null) {
      return const SizedBox(height: 200);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        const centerY = 100.0;

        return SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            children: [
              // Surrounding icons
              ..._buildSurroundingIcons(centerX, centerY),

              // Center app icon
              Positioned(
                left: centerX - 40,
                top: centerY - 40,
                child: Container(
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
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSurroundingIcons(double centerX, double centerY) {
    final icons = [
      (Icons.bloodtype_rounded, AppColors.glucose, -70.0, -55.0, 0.0),
      (Icons.monitor_heart_rounded, AppColors.heartRate, 70.0, -55.0, 0.15),
      (Icons.bedtime_rounded, AppColors.sleep, -90.0, 15.0, 0.3),
      (Icons.restaurant_rounded, AppColors.food, 90.0, 15.0, 0.45),
      (Icons.fitness_center_rounded, AppColors.exercise, -55.0, 70.0, 0.6),
      (Icons.medication_rounded, AppColors.medication, 55.0, 70.0, 0.75),
    ];

    return icons.map((data) {
      final (icon, color, dx, dy, phaseOffset) = data;
      return Positioned(
        left: centerX + dx - 22,
        top: centerY + dy - 22,
        child: AnimatedBuilder(
          animation: _opacityController!,
          builder: (context, child) {
            final animValue = (_opacityController!.value + phaseOffset) % 1.0;
            final opacity = 0.1 + 0.6 * _smoothWave(animValue);

            return Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            );
          },
          child: Icon(icon, color: color, size: 24),
        ),
      );
    }).toList();
  }

  double _smoothWave(double t) {
    return (t < 0.5) ? (2 * t) : (2 * (1 - t));
  }
}
