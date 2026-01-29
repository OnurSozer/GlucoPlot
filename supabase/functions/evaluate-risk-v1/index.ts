/**
 * evaluate-risk-v1
 *
 * Evaluates a measurement against the doctor's thresholds
 * and creates risk alerts if thresholds are breached.
 *
 * Can be called:
 * 1. By patients when submitting measurements (via database trigger or client)
 * 2. As a webhook after measurement insertion
 *
 * POST /evaluate-risk-v1
 * Body: { measurement_id: string }
 *
 * Response: {
 *   measurement: {...},
 *   evaluation: { status: "normal" | "warning" | "critical", ... },
 *   alert?: { id, severity, title }
 * }
 */

import { handleCors } from "../_shared/cors.ts";
import { createServiceClient } from "../_shared/supabase.ts";
import {
  jsonResponse,
  errorResponse,
  ErrorCodes,
} from "../_shared/response.ts";

interface EvaluateRiskRequest {
  measurement_id: string;
}

type Severity = "low" | "medium" | "high" | "critical";
type EvaluationStatus = "normal" | "warning" | "critical";

interface Threshold {
  min_critical: number | null;
  min_warning: number | null;
  max_warning: number | null;
  max_critical: number | null;
}

interface EvaluationResult {
  status: EvaluationStatus;
  severity?: Severity;
  message?: string;
}

/**
 * Evaluate a value against thresholds
 */
function evaluateValue(value: number, threshold: Threshold): EvaluationResult {
  // Critical low
  if (threshold.min_critical !== null && value < threshold.min_critical) {
    return {
      status: "critical",
      severity: "critical",
      message: `Value ${value} is critically low (below ${threshold.min_critical})`,
    };
  }

  // Critical high
  if (threshold.max_critical !== null && value > threshold.max_critical) {
    return {
      status: "critical",
      severity: "critical",
      message: `Value ${value} is critically high (above ${threshold.max_critical})`,
    };
  }

  // Warning low
  if (threshold.min_warning !== null && value < threshold.min_warning) {
    return {
      status: "warning",
      severity: "medium",
      message: `Value ${value} is below normal range (below ${threshold.min_warning})`,
    };
  }

  // Warning high
  if (threshold.max_warning !== null && value > threshold.max_warning) {
    return {
      status: "warning",
      severity: "medium",
      message: `Value ${value} is above normal range (above ${threshold.max_warning})`,
    };
  }

  return { status: "normal" };
}

/**
 * Generate alert title based on measurement type and status
 */
function generateAlertTitle(
  measurementType: string,
  status: EvaluationStatus,
  isHigh: boolean
): string {
  const typeLabels: Record<string, string> = {
    glucose: "Blood Glucose",
    blood_pressure: "Blood Pressure",
    heart_rate: "Heart Rate",
    weight: "Weight",
    temperature: "Temperature",
    spo2: "Oxygen Saturation",
  };

  const typeName = typeLabels[measurementType] || measurementType;
  const direction = isHigh ? "High" : "Low";
  const severity = status === "critical" ? "Critical" : "Elevated";

  return `${severity} ${typeName} - ${direction}`;
}

Deno.serve(async (req) => {
  // Handle CORS
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    // Only accept POST
    if (req.method !== "POST") {
      return errorResponse("Method not allowed", 405);
    }

    const body: EvaluateRiskRequest = await req.json();

    // Validate inputs
    if (!body.measurement_id?.trim()) {
      return errorResponse(
        "measurement_id is required",
        400,
        ErrorCodes.VALIDATION_ERROR
      );
    }

    const supabase = createServiceClient();

    // Fetch measurement with patient and doctor info
    const { data: measurement, error: measurementError } = await supabase
      .from("measurements")
      .select(`
        id,
        patient_id,
        type,
        value_primary,
        value_secondary,
        unit,
        measured_at,
        source,
        notes,
        patients (
          id,
          doctor_id,
          full_name
        )
      `)
      .eq("id", body.measurement_id.trim())
      .single();

    if (measurementError || !measurement) {
      return errorResponse("Measurement not found", 404, ErrorCodes.NOT_FOUND);
    }

    const patient = measurement.patients;
    if (!patient) {
      return errorResponse("Patient not found", 404, ErrorCodes.NOT_FOUND);
    }

    // Fetch doctor's thresholds for this measurement type
    const { data: threshold, error: thresholdError } = await supabase
      .from("measurement_thresholds")
      .select("min_critical, min_warning, max_warning, max_critical")
      .eq("doctor_id", patient.doctor_id)
      .eq("measurement_type", measurement.type)
      .single();

    // If no threshold defined, skip evaluation
    if (thresholdError || !threshold) {
      return jsonResponse({
        measurement: {
          id: measurement.id,
          type: measurement.type,
          value_primary: measurement.value_primary,
          value_secondary: measurement.value_secondary,
          unit: measurement.unit,
        },
        evaluation: {
          status: "normal",
          message: "No thresholds configured for this measurement type",
        },
        alert: null,
      });
    }

    // Evaluate primary value
    const evaluation = evaluateValue(measurement.value_primary, threshold);

    // If not normal, create an alert
    let alert = null;
    if (evaluation.status !== "normal") {
      const isHigh =
        measurement.value_primary > (threshold.max_warning ?? 0) ||
        measurement.value_primary > (threshold.max_critical ?? 0);

      const alertTitle = generateAlertTitle(
        measurement.type,
        evaluation.status,
        isHigh
      );

      const alertDescription = `${patient.full_name}'s ${measurement.type} reading of ${measurement.value_primary} ${measurement.unit} ${evaluation.message}. Recorded at ${new Date(measurement.measured_at).toLocaleString()}.`;

      // Insert alert
      const { data: newAlert, error: alertError } = await supabase
        .from("risk_alerts")
        .insert({
          patient_id: measurement.patient_id,
          doctor_id: patient.doctor_id,
          measurement_id: measurement.id,
          severity: evaluation.severity,
          title: alertTitle,
          description: alertDescription,
          status: "new",
        })
        .select("id, severity, title, status, created_at")
        .single();

      if (alertError) {
        console.error("Error creating alert:", alertError);
        // Don't fail the request, just log the error
      } else {
        alert = newAlert;
      }
    }

    // For blood pressure, also evaluate secondary value (diastolic)
    let secondaryEvaluation = null;
    if (
      measurement.type === "blood_pressure" &&
      measurement.value_secondary !== null
    ) {
      // Diastolic thresholds are typically different
      // Using approximate ratios from systolic thresholds
      const diastolicThreshold: Threshold = {
        min_critical: threshold.min_critical ? threshold.min_critical * 0.6 : null,
        min_warning: threshold.min_warning ? threshold.min_warning * 0.67 : null,
        max_warning: threshold.max_warning ? threshold.max_warning * 0.64 : null, // ~90 for 140 systolic
        max_critical: threshold.max_critical ? threshold.max_critical * 0.67 : null, // ~120 for 180 systolic
      };

      secondaryEvaluation = evaluateValue(
        measurement.value_secondary,
        diastolicThreshold
      );

      // Create additional alert for diastolic if needed
      if (secondaryEvaluation.status !== "normal" && !alert) {
        const isHigh = measurement.value_secondary > (diastolicThreshold.max_warning ?? 0);
        const alertTitle = `${secondaryEvaluation.status === "critical" ? "Critical" : "Elevated"} Diastolic Blood Pressure`;

        const { data: diastolicAlert, error: diastolicAlertError } = await supabase
          .from("risk_alerts")
          .insert({
            patient_id: measurement.patient_id,
            doctor_id: patient.doctor_id,
            measurement_id: measurement.id,
            severity: secondaryEvaluation.severity,
            title: alertTitle,
            description: `${patient.full_name}'s diastolic blood pressure of ${measurement.value_secondary} mmHg ${secondaryEvaluation.message}.`,
            status: "new",
          })
          .select("id, severity, title, status, created_at")
          .single();

        if (!diastolicAlertError) {
          alert = diastolicAlert;
        }
      }
    }

    return jsonResponse({
      measurement: {
        id: measurement.id,
        type: measurement.type,
        value_primary: measurement.value_primary,
        value_secondary: measurement.value_secondary,
        unit: measurement.unit,
        measured_at: measurement.measured_at,
      },
      evaluation: {
        status: evaluation.status,
        severity: evaluation.severity,
        message: evaluation.message,
        secondary_status: secondaryEvaluation?.status,
      },
      alert,
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return errorResponse("Internal server error", 500, ErrorCodes.INTERNAL_ERROR);
  }
});
