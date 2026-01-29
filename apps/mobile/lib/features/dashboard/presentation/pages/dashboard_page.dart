import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../core/widgets/measurement_card.dart' as card;
import '../../../measurements/domain/entities/measurement.dart';
import '../../domain/entities/risk_alert.dart';
import '../../domain/repositories/dashboard_repository.dart' as repo;
import '../bloc/dashboard_bloc.dart';

/// Patient dashboard - main home screen
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardLoadRequested());
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(const DashboardRefreshRequested());
            },
            child: CustomScrollView(
              slivers: [
                // Gradient header
                SliverToBoxAdapter(
                  child: CurvedGradientHeader(
                    title: _getGreeting(),
                    subtitle: 'Here\'s your health summary',
                    trailing: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.surface.withOpacity(0.3),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Loading state
                      if (state is DashboardLoading)
                        const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: AppLoadingIndicator()),
                        ),

                      // Error state
                      if (state is DashboardError)
                        _buildErrorCard(state.message),

                      // Loaded state
                      if (state is DashboardLoaded) ...[
                        // Active alerts
                        if (state.activeAlerts.isNotEmpty) ...[
                          _buildAlertsSection(state.activeAlerts),
                          const SizedBox(height: 24),
                        ],

                        // Today's Summary section
                        _buildSectionHeader(
                          AppStrings.todaySummary,
                          onSeeAll: () {},
                        ),
                        const SizedBox(height: 12),
                        _buildTodaySummaryGrid(context, state),

                        const SizedBox(height: 24),

                        // Recent Measurements section
                        _buildSectionHeader(
                          AppStrings.recentMeasurements,
                          onSeeAll: () => context.go('/measurements'),
                        ),
                        const SizedBox(height: 12),
                        _buildRecentMeasurements(context, state),

                        const SizedBox(height: 24),

                        // Quick Actions section
                        _buildSectionHeader(AppStrings.quickActions),
                        const SizedBox(height: 12),
                        _buildQuickActions(context),
                      ],

                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<DashboardBloc>().add(const DashboardLoadRequested());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(List<RiskAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Active Alerts'),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(RiskAlert alert) {
    final color = switch (alert.severity) {
      AlertSeverity.critical => AppColors.error,
      AlertSeverity.high => Colors.orange,
      AlertSeverity.medium => Colors.amber,
      AlertSeverity.low => Colors.blue,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber_rounded, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.message,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (alert.value != null)
                  Text(
                    'Value: ${alert.value!.toStringAsFixed(1)} ${alert.measurementType.unit}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<DashboardBloc>().add(DashboardAlertAcknowledged(alert.id));
            },
            icon: const Icon(Icons.check_circle_outline),
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.headlineSmall),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              AppStrings.viewAll,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTodaySummaryGrid(BuildContext context, DashboardLoaded state) {
    final glucoseMeasurement = state.latestMeasurements[MeasurementType.glucose];
    final bpMeasurement = state.latestMeasurements[MeasurementType.bloodPressure];

    return Row(
      children: [
        Expanded(
          child: CompactMeasurementCard(
            title: AppStrings.glucose,
            value: glucoseMeasurement?.formattedValue ?? '--',
            unit: 'mg/dL',
            color: AppColors.glucose,
            icon: Icons.bloodtype_rounded,
            onTap: () => context.go('/measurements'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CompactMeasurementCard(
            title: AppStrings.bloodPressure,
            value: bpMeasurement?.formattedValue ?? '--/--',
            unit: 'mmHg',
            color: AppColors.bloodPressure,
            icon: Icons.monitor_heart_rounded,
            onTap: () => context.go('/measurements'),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentMeasurements(BuildContext context, DashboardLoaded state) {
    final lastGlucose = state.lastGlucose;
    final trend = state.glucoseTrend;

    if (lastGlucose == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(Icons.add_chart, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text(
              'No measurements yet',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Add First Measurement',
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.small,
              onPressed: () => context.push('/measurements/add'),
            ),
          ],
        ),
      );
    }

    final formatter = DateFormat('MMM d, h:mm a');
    final measurementTrend = switch (trend) {
      repo.MeasurementTrend.increasing => card.MeasurementTrend.up,
      repo.MeasurementTrend.decreasing => card.MeasurementTrend.down,
      repo.MeasurementTrend.stable || null => card.MeasurementTrend.stable,
    };

    return MeasurementCard(
      title: AppStrings.glucose,
      value: lastGlucose.formattedValue,
      unit: 'mg/dL',
      color: AppColors.glucose,
      icon: Icons.bloodtype_rounded,
      subtitle: formatter.format(lastGlucose.measuredAt),
      trend: measurementTrend,
      onTap: () => context.go('/measurements'),
      miniChart: state.chartData.isNotEmpty
          ? _buildMiniChart(state.chartData)
          : _buildPlaceholderChart(),
    );
  }

  Widget _buildMiniChart(List<Measurement> data) {
    if (data.isEmpty) return _buildPlaceholderChart();

    final maxValue = data.map((m) => m.value).reduce((a, b) => a > b ? a : b);
    final minValue = data.map((m) => m.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.take(6).map((measurement) {
        final normalizedHeight = range > 0
            ? (measurement.value - minValue) / range
            : 0.5;
        final heightFactor = 0.2 + (normalizedHeight * 0.6);
        final opacity = 0.3 + (normalizedHeight * 0.7);

        return Container(
          width: 8,
          height: 40 * heightFactor,
          decoration: BoxDecoration(
            color: AppColors.glucose.withOpacity(opacity),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceholderChart() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildBar(0.3, AppColors.glucose.withOpacity(0.3)),
        _buildBar(0.5, AppColors.glucose.withOpacity(0.4)),
        _buildBar(0.4, AppColors.glucose.withOpacity(0.5)),
        _buildBar(0.7, AppColors.glucose.withOpacity(0.6)),
        _buildBar(0.6, AppColors.glucose.withOpacity(0.7)),
        _buildBar(0.8, AppColors.glucose),
      ],
    );
  }

  Widget _buildBar(double heightFactor, Color color) {
    return Container(
      width: 8,
      height: 40 * heightFactor,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_circle_outline_rounded,
            label: 'Add Measurement',
            color: AppColors.primary,
            onTap: () => context.push('/measurements/add'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.edit_note_rounded,
            label: 'Log Activity',
            color: AppColors.secondary,
            onTap: () => context.push('/log/add'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
