import 'package:flutter/material.dart';
import '../../../../core/theme/theme.dart';

/// Log type enum for UI display
enum LogType {
  food(
    label: 'Food',
    icon: Icons.restaurant_rounded,
    color: AppColors.food,
  ),
  sleep(
    label: 'Sleep',
    icon: Icons.bedtime_rounded,
    color: AppColors.sleep,
  ),
  exercise(
    label: 'Exercise',
    icon: Icons.fitness_center_rounded,
    color: AppColors.exercise,
  ),
  medication(
    label: 'Medication',
    icon: Icons.medication_rounded,
    color: AppColors.medication,
  ),
  symptom(
    label: 'Symptom',
    icon: Icons.healing_rounded,
    color: AppColors.symptom,
  );

  const LogType({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
