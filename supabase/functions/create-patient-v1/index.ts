/**
 * create-patient-v1
 *
 * Creates a new patient record and generates a QR invite token.
 * Only authenticated doctors can call this endpoint.
 *
 * POST /create-patient-v1
 * Body: {
 *   full_name: string;
 *   date_of_birth?: string;  // ISO date
 *   gender?: string;
 *   phone?: string;
 *   medical_notes?: string;
 * }
 *
 * Response: {
 *   patient: { id, full_name, ... };
 *   invite: { id, token, expires_at };
 *   qr_data: string;  // Token to encode in QR code
 * }
 */

import { handleCors } from "../_shared/cors.ts";
import {
  createServiceClient,
  getUserIdFromAuth,
} from "../_shared/supabase.ts";
import {
  jsonResponse,
  errorResponse,
  ErrorCodes,
} from "../_shared/response.ts";

interface CreatePatientRequest {
  full_name: string;
  date_of_birth?: string;
  gender?: string;
  phone?: string;
  medical_notes?: string;
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

    // Authenticate doctor
    const authHeader = req.headers.get("Authorization");
    const doctorId = await getUserIdFromAuth(authHeader);

    if (!doctorId) {
      return errorResponse("Unauthorized", 401, ErrorCodes.UNAUTHORIZED);
    }

    // Parse request body
    const body: CreatePatientRequest = await req.json();

    // Validate required fields
    if (!body.full_name?.trim()) {
      return errorResponse(
        "full_name is required",
        400,
        ErrorCodes.VALIDATION_ERROR
      );
    }

    const supabase = createServiceClient();

    // Verify user is a doctor
    const { data: doctor, error: doctorError } = await supabase
      .from("doctors")
      .select("id")
      .eq("id", doctorId)
      .single();

    if (doctorError || !doctor) {
      return errorResponse("User is not a registered doctor", 403, ErrorCodes.FORBIDDEN);
    }

    // Create patient record
    const { data: patient, error: patientError } = await supabase
      .from("patients")
      .insert({
        doctor_id: doctorId,
        full_name: body.full_name.trim(),
        date_of_birth: body.date_of_birth || null,
        gender: body.gender || null,
        phone: body.phone || null,
        medical_notes: body.medical_notes || null,
        status: "pending",
      })
      .select()
      .single();

    if (patientError) {
      console.error("Error creating patient:", patientError);
      return errorResponse(
        "Failed to create patient",
        500,
        ErrorCodes.INTERNAL_ERROR
      );
    }

    // Create invite token
    const { data: invite, error: inviteError } = await supabase
      .from("patient_invites")
      .insert({
        patient_id: patient.id,
        doctor_id: doctorId,
        status: "pending",
      })
      .select("id, token, expires_at")
      .single();

    if (inviteError) {
      console.error("Error creating invite:", inviteError);
      // Rollback patient creation
      await supabase.from("patients").delete().eq("id", patient.id);
      return errorResponse(
        "Failed to create invite",
        500,
        ErrorCodes.INTERNAL_ERROR
      );
    }

    // Return patient and invite details
    return jsonResponse({
      patient: {
        id: patient.id,
        full_name: patient.full_name,
        date_of_birth: patient.date_of_birth,
        gender: patient.gender,
        phone: patient.phone,
        status: patient.status,
        created_at: patient.created_at,
      },
      invite: {
        id: invite.id,
        token: invite.token,
        expires_at: invite.expires_at,
      },
      // The QR code should encode this token
      qr_data: invite.token,
    });
  } catch (error) {
    console.error("Unexpected error:", error);
    return errorResponse("Internal server error", 500, ErrorCodes.INTERNAL_ERROR);
  }
});
