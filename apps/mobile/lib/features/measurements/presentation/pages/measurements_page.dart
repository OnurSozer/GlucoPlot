import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/measurement.dart';
import '../bloc/measurement_bloc.dart';

/// Measurements list page - shows all health measurements
class MeasurementsPage extends StatefulWidget {
  const MeasurementsPage({super.key});

  @override
  State<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends State<MeasurementsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _measurementTypes = [
    (MeasurementType.glucose, AppStrings.glucose, AppColors.glucose, Icons.bloodtype_rounded),
    (MeasurementType.bloodPressure, AppStrings.bloodPressure, AppColors.bloodPressure, Icons.monitor_heart_rounded),
    (MeasurementType.heartRate, AppStrings.heartRate, AppColors.heartRate, Icons.favorite_rounded),
    (MeasurementType.weight, AppStrings.weight, AppColors.weight, Icons.monitor_weight_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _measurementTypes.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial measurements
    context.read<MeasurementBloc>().add(
      MeasurementLoadRequested(type: _measurementTypes[0].$1),
    );
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final type = _measurementTypes[_tabController.index].$1;
      context.read<MeasurementBloc>().add(MeasurementTypeFilterChanged(type));
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // Gradient header
            SliverToBoxAdapter(
              child: CurvedGradientHeader(
                title: AppStrings.measurements,
                subtitle: 'Track your health metrics',
              ),
            ),

            // Tab bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textTertiary,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelStyle: AppTypography.labelMedium,
                  tabs: _measurementTypes
                      .map((type) => Tab(
                            child: Row(
                              children: [
                                Icon(type.$4, size: 18),
                                const SizedBox(width: 8),
                                Text(type.$2),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
          ];
        },
        body: BlocBuilder<MeasurementBloc, MeasurementState>(
          builder: (context, state) {
            if (state is MeasurementLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state is MeasurementError) {
              return _buildErrorView(state.message);
            }

            if (state is MeasurementLoaded) {
              final currentType = _measurementTypes[_tabController.index];
              return _buildMeasurementList(
                state.measurements,
                currentType.$2,
                currentType.$3,
                currentType.$4,
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/measurements/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add'),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Retry',
              variant: AppButtonVariant.outlined,
              onPressed: () {
                final type = _measurementTypes[_tabController.index].$1;
                context.read<MeasurementBloc>().add(MeasurementLoadRequested(type: type));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementList(
    List<Measurement> measurements,
    String typeName,
    Color color,
    IconData icon,
  ) {
    if (measurements.isEmpty) {
      return _buildEmptyView(typeName, color);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<MeasurementBloc>().add(const MeasurementRefreshRequested());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: measurements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final measurement = measurements[index];
          return _MeasurementListItem(
            measurement: measurement,
            color: color,
            icon: icon,
            onDelete: () {
              context.read<MeasurementBloc>().add(
                MeasurementDeleteRequested(measurement.id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyView(String typeName, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.add_chart, size: 40, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              'No $typeName measurements',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first measurement to start tracking',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Add Measurement',
              onPressed: () => context.push('/measurements/add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementListItem extends StatelessWidget {
  const _MeasurementListItem({
    required this.measurement,
    required this.color,
    required this.icon,
    this.onDelete,
  });

  final Measurement measurement;
  final Color color;
  final IconData icon;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d');
    final timeFormatter = DateFormat('h:mm a');

    return Dismissible(
      key: Key(measurement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete?.call(),
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppSpacing.borderRadiusLg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        measurement.formattedValue,
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        measurement.displayUnit,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormatter.format(measurement.measuredAt)}, ${timeFormatter.format(measurement.measuredAt)}',
                    style: AppTypography.labelSmall,
                  ),
                  if (measurement.notes != null && measurement.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      measurement.notes!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
