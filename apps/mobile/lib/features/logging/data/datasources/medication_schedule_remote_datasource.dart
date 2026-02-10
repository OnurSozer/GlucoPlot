import 'package:supabase_flutter/supabase_flutter.dart';

/// A pre-configured medication preset from the doctor's onboarding entry.
class MedicationPreset {
  const MedicationPreset({
    required this.name,
    required this.isInsulin,
  });

  final String name;
  final bool isInsulin;
}

/// Remote data source for fetching pre-configured medication names
/// from the patient_medication_schedules table (set by doctors during onboarding).
class MedicationScheduleRemoteDataSource {
  MedicationScheduleRemoteDataSource({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Returns distinct medication presets configured for a patient's
  /// active schedules (both oral and insulin).
  Future<List<MedicationPreset>> getMedicationPresets(String patientId) async {
    final response = await _client
        .from('patient_medication_schedules')
        .select('medication_class, insulin_type, medication_name')
        .eq('patient_id', patientId)
        .eq('is_active', true);

    final seen = <String>{};
    final presets = <MedicationPreset>[];

    for (final row in (response as List)) {
      final medClass = row['medication_class'] as String?;
      final isInsulin = medClass == 'insulin';
      final medicationName = row['medication_name'] as String?;
      final insulinType = row['insulin_type'] as String?;

      // For oral: use medication_name if set
      // For insulin: use medication_name if set, otherwise use insulin_type
      String? name;
      if (medicationName != null && medicationName.isNotEmpty) {
        name = medicationName;
      } else if (isInsulin && insulinType != null && insulinType != 'none') {
        // Capitalize insulin type for display (e.g. "nph" -> "NPH", "lente" -> "Lente")
        name = insulinType.length <= 3
            ? insulinType.toUpperCase()
            : insulinType[0].toUpperCase() + insulinType.substring(1);
      }

      if (name != null && seen.add(name)) {
        presets.add(MedicationPreset(name: name, isInsulin: isInsulin));
      }
    }

    return presets;
  }
}
