part of 'measurement_bloc.dart';

/// Base class for measurement states
sealed class MeasurementState extends Equatable {
  const MeasurementState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MeasurementInitial extends MeasurementState {
  const MeasurementInitial();
}

/// Loading state
class MeasurementLoading extends MeasurementState {
  const MeasurementLoading();
}

/// Loaded state with data
class MeasurementLoaded extends MeasurementState {
  const MeasurementLoaded({
    required this.measurements,
    this.filterType,
    this.hasMore = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.error,
  });

  final List<Measurement> measurements;
  final MeasurementType? filterType;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? error;

  @override
  List<Object?> get props => [
        measurements,
        filterType,
        hasMore,
        isRefreshing,
        isLoadingMore,
        isSubmitting,
        submitSuccess,
        error,
      ];

  MeasurementLoaded copyWith({
    List<Measurement>? measurements,
    MeasurementType? filterType,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isSubmitting,
    bool? submitSuccess,
    String? error,
  }) {
    return MeasurementLoaded(
      measurements: measurements ?? this.measurements,
      filterType: filterType ?? this.filterType,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? false,
      error: error,
    );
  }
}

/// Error state
class MeasurementError extends MeasurementState {
  const MeasurementError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
