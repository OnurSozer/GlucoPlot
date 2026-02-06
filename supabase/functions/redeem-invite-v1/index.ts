/**
 * redeem-invite-v1
 *
 * Two-step patient activation flow:
 *
 * Step 1: Request OTP
 * POST /redeem-invite-v1
 * Body: { action: "request_otp", token: string, phone: string }
 * Response: { message: "OTP sent", expires_in_seconds: number }
 *
 * Step 2: Verify OTP and complete activation
 * POST /redeem-invite-v1
 * Body: { action: "verify_otp", token: string, otp: string }
 * Response: { patient: {...}, session: {...} }
 */

import { handleCors } from "../_shared/cors.ts";
import { createServiceClient } from "../_shared/supabase.ts";
import {
  jsonResponse,
  errorResponse,
  ErrorCodes,
} from "../_shared/response.ts";

interface RequestOtpBody {
  action: "request_otp";
  token: string;
  phone: string;
}

interface VerifyOtpBody {
  action: "verify_otp";
  token: string;
  otp: string;
}

interface RedeemBody {
  action: "redeem";
  token: string;
}

type RequestBody = RequestOtpBody | VerifyOtpBody | RedeemBody;

const OTP_EXPIRY_MINUTES = 10;
const OTP_LENGTH = 6;

/**
 * Generate a random numeric OTP
 */
function generateOtp(): string {
  const digits = "0123456789";
  let otp = "";
  for (let i = 0; i < OTP_LENGTH; i++) {
    otp += digits[Math.floor(Math.random() * digits.length)];
  }
  return otp;
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

    const body: RequestBody = await req.json();
    const supabase = createServiceClient();

    // ============================================================
    // STEP 1 (NEW): Direct Redeem (No OTP)
    // ============================================================
    if (body.action === "redeem") {
      const { token } = body as { token: string };

      if (!token?.trim()) {
        return errorResponse("Token is required", 400, ErrorCodes.VALIDATION_ERROR);
      }

      // Find the invite
      const { data: invite, error: inviteError } = await supabase
        .from("patient_invites")
        .select(`
          id,
          status,
          expires_at,
          patient_id,
          patients (id, full_name, phone, status, auth_user_id)
        `)
        .eq("token", token.trim())
        .single();

      if (inviteError || !invite) {
        return errorResponse("Invalid invite token", 404, ErrorCodes.NOT_FOUND);
      }

      // Allow redeemed if patient is active (Login)
      if (invite.status === "redeemed" && !invite.patients?.auth_user_id) {
        return errorResponse(
          "This invite has already been used",
          400,
          ErrorCodes.INVITE_ALREADY_REDEEMED
        );
      }

      const patient = invite.patients;
      if (!patient) {
        return errorResponse("Patient not found", 404, ErrorCodes.NOT_FOUND);
      }

      let authUserId = patient.auth_user_id;

      // Create auth user if not exists
      if (!authUserId) {
        // Ensure we have a phone number?
        if (!patient.phone) {
          return errorResponse("Patient has no phone number", 400, ErrorCodes.VALIDATION_ERROR);
        }

        const patientEmail = `patient_${patient.id}@glucoplot.local`;
        const tempPassword = crypto.randomUUID();

        const { data: authData, error: authError } = await supabase.auth.admin.createUser({
          email: patientEmail,
          password: tempPassword,
          phone: patient.phone,
          email_confirm: true,
          user_metadata: {
            full_name: patient.full_name,
            role: "patient",
            patient_id: patient.id,
          },
        });

        if (authError) {
          console.error("Error creating auth user:", authError);
          return errorResponse(`Failed to create account: ${authError.message}`, 500, ErrorCodes.INTERNAL_ERROR);
        }

        authUserId = authData.user.id;

        await supabase.from("patients").update({ auth_user_id: authUserId, status: 'active' }).eq('id', patient.id);
      }

      // Mark invite redeemed
      if (invite.status !== 'redeemed') {
        await supabase.from("patient_invites").update({ status: 'redeemed', redeemed_at: new Date().toISOString() }).eq('id', invite.id);
      }

      // Update patient password to a temporary one for this session
      // Also ensure user_metadata has patient_id (for older accounts that may not have it)
      const patientEmail = `patient_${patient.id}@glucoplot.local`; // Re-declare patientEmail for scope
      const tempPassword = crypto.randomUUID();
      const { error: passwordError } = await supabase.auth.admin.updateUserById(
        authUserId,
        {
          password: tempPassword,
          user_metadata: {
            full_name: patient.full_name,
            role: "patient",
            patient_id: patient.id,
          },
        }
      );

      if (passwordError) {
        console.error("Error updating password:", passwordError);
        return errorResponse("Failed to generate login session", 500, ErrorCodes.INTERNAL_ERROR);
      }

      return jsonResponse({
        message: "Login successful",
        patient: {
          id: patient.id,
          full_name: patient.full_name,
          status: "active",
        },
        auth: {
          email: patientEmail,
          temp_password: tempPassword,
          type: 'password'
        },
      });
    }

    // ============================================================
    // STEP 1 (Legacy): Request OTP
    // ============================================================
    if (body.action === "request_otp") {
      const { token, phone } = body as RequestOtpBody;

      // Validate inputs
      if (!token?.trim()) {
        return errorResponse("Token is required", 400, ErrorCodes.VALIDATION_ERROR);
      }

      // Note: Phone is optional in request. If not provided, we use the one from patient record.

      // Find the invite
      const { data: invite, error: inviteError } = await supabase
        .from("patient_invites")
        .select(`
          id,
          status,
          expires_at,
          patient_id,
          patients (id, full_name, phone, status, auth_user_id)
        `)
        .eq("token", token.trim())
        .single();

      if (inviteError || !invite) {
        return errorResponse("Invalid invite token", 404, ErrorCodes.NOT_FOUND);
      }

      // Check invite status
      // If redeemed, we allow it ONLY if the patient is already active (Login Flow)
      if (invite.status === "redeemed") {
        if (!invite.patients?.auth_user_id) {
          return errorResponse(
            "This invite has already been used",
            400,
            ErrorCodes.INVITE_ALREADY_REDEEMED
          );
        }
        // If patient is active, we proceed to generate OTP for login
      } else if (invite.status === "expired" || new Date(invite.expires_at) < new Date()) {
        // Mark as expired if not already
        await supabase
          .from("patient_invites")
          .update({ status: "expired" })
          .eq("id", invite.id);
        return errorResponse("This invite has expired", 400, ErrorCodes.INVITE_EXPIRED);
      }

      // Determine target phone number
      const requestPhone = phone?.trim();
      const patientPhone = invite.patients?.phone;
      const targetPhone = requestPhone || patientPhone;

      if (!targetPhone) {
        return errorResponse(
          "No phone number found for this patient. Please contact your doctor.",
          400,
          ErrorCodes.VALIDATION_ERROR
        );
      }

      // Generate OTP
      const otp = generateOtp();
      const otpExpiresAt = new Date(
        Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000
      ).toISOString();

      // Save OTP to invite
      // We also set status to 'pending' if it was 'redeemed', to avoid triggers clearing the OTP
      // and to allow the verify step to proceed normally.
      const updatePayload: any = {
        otp_code: otp,
        otp_expires_at: otpExpiresAt,
      };

      if (invite.status === 'redeemed') {
        updatePayload.status = 'pending';
        updatePayload.redeemed_at = null;
      }

      const { data: updateData, error: updateError } = await supabase
        .from("patient_invites")
        .update(updatePayload)
        .eq("id", invite.id)
        .select();

      if (updateError) {
        console.error("Error saving OTP:", updateError);
        return errorResponse(
          "Failed to generate OTP",
          500,
          ErrorCodes.INTERNAL_ERROR
        );
      }

      if (!updateData || updateData.length === 0) {
        console.error("OTP update failed: No rows modified. ID:", invite.id);
        return errorResponse("Failed to save OTP. Invite might be locked.", 500, ErrorCodes.INTERNAL_ERROR);
      }

      // Update patient phone if provided in request AND different
      if (requestPhone && invite.patients && invite.patients.phone !== requestPhone) {
        await supabase
          .from("patients")
          .update({ phone: requestPhone })
          .eq("id", invite.patient_id);
      }

      // In production, send SMS here using Twilio/etc.
      // For now, log it (development mode)
      console.log(`[DEV] OTP for ${targetPhone}: ${otp}`);

      return jsonResponse({
        message: "OTP sent to your phone",
        expires_in_seconds: OTP_EXPIRY_MINUTES * 60,
        // DEV ONLY: Include OTP in response for testing
        // Remove this in production!
        _dev_otp: otp,
      });
    }

    // ============================================================
    // STEP 2: Verify OTP and activate patient
    // ============================================================
    if (body.action === "verify_otp") {
      const { token, otp } = body as VerifyOtpBody;

      // Validate inputs
      if (!token?.trim()) {
        return errorResponse("Token is required", 400, ErrorCodes.VALIDATION_ERROR);
      }
      if (!otp?.trim()) {
        return errorResponse("OTP is required", 400, ErrorCodes.VALIDATION_ERROR);
      }

      // Find the invite
      const { data: invite, error: inviteError } = await supabase
        .from("patient_invites")
        .select(`
          id,
          status,
          otp_code,
          otp_expires_at,
          patient_id,
          patients(id, full_name, phone, status, auth_user_id)
        `)
        .eq("token", token.trim())
        .single();

      if (inviteError || !invite) {
        return errorResponse("Invalid invite token", 404, ErrorCodes.NOT_FOUND);
      }

      // Check invite status
      // We allow 'pending' (normal or recently reset) and 'redeemed' (if concurrent?)
      // We only block if redeemed AND patient NOT active (which shouldn't happen if we reset it)
      // Actually, if we reset it to pending, status will be pending.
      // So we just check for expired.

      if (invite.status === "redeemed" && !invite.patients?.auth_user_id) {
        // Only block if redeemed and NOT active (standard exhausted invite)
        return errorResponse(
          "This invite has already been used",
          400,
          ErrorCodes.INVITE_ALREADY_REDEEMED
        );
      }

      // Check OTP
      if (!invite.otp_code) {
        return errorResponse(
          `Please request an OTP first (Debug: Status=${invite.status}, HasOTP=${!!invite.otp_code})`,
          400,
          ErrorCodes.VALIDATION_ERROR
        );
      }

      if (invite.otp_code !== otp.trim()) {
        return errorResponse("Invalid OTP", 400, ErrorCodes.INVALID_OTP);
      }

      if (new Date(invite.otp_expires_at!) < new Date()) {
        return errorResponse("OTP has expired", 400, ErrorCodes.OTP_EXPIRED);
      }

      const patient = invite.patients;
      if (!patient || !patient.phone) {
        return errorResponse("Patient not found", 404, ErrorCodes.NOT_FOUND);
      }

      let authUserId = patient.auth_user_id;

      // Note: We REMOVED the "Patient already activated" error block here.
      // We allow falling through to utilize the existing authUserId for login.


      // If patient is NOT already activated, create new auth user
      if (!authUserId) {
        // Create auth user for patient using phone
        const patientEmail = `patient_${patient.id}@glucoplot.local`;
        const tempPassword = crypto.randomUUID();

        const { data: authData, error: authError } = await supabase.auth.admin.createUser({
          email: patientEmail,
          password: tempPassword,
          phone: patient.phone,
          email_confirm: true,
          user_metadata: {
            full_name: patient.full_name,
            role: "patient",
            patient_id: patient.id,
          },
        });

        if (authError) {
          console.error("Error creating auth user:", authError);
          return errorResponse(
            `Failed to create user account: ${authError.message}`,
            500,
            ErrorCodes.INTERNAL_ERROR
          );
        }

        authUserId = authData.user.id;

        // Link auth user to patient
        const { error: linkError } = await supabase
          .from("patients")
          .update({
            auth_user_id: authUserId,
            status: "active",
          })
          .eq("id", patient.id);

        if (linkError) {
          console.error("Error linking auth user to patient:", linkError);
          // Try to clean up auth user
          await supabase.auth.admin.deleteUser(authUserId);
          return errorResponse(
            "Failed to activate patient",
            500,
            ErrorCodes.INTERNAL_ERROR
          );
        }
      }

      // Mark invite as redeemed (if not already)
      if (invite.status !== 'redeemed') {
        await supabase
          .from("patient_invites")
          .update({
            status: "redeemed",
            redeemed_at: new Date().toISOString(),
            otp_code: null,
            otp_expires_at: null,
          })
          .eq("id", invite.id);
      } else {
        // If already redeemed, just clear the OTP we just used
        await supabase
          .from("patient_invites")
          .update({
            otp_code: null,
            otp_expires_at: null,
          })
          .eq("id", invite.id);
      }

      // Generate a session for the patient
      // In production, you might use magic link or phone OTP via Supabase Auth
      const patientEmail = `patient_${patient.id}@glucoplot.local`; // Reconstruct email
      const { data: sessionData, error: sessionError } = await supabase.auth.admin.generateLink({
        type: "magiclink",
        email: patientEmail,
      });

      if (sessionError) {
        console.error("Error generating session:", sessionError);
      }

      return jsonResponse({
        message: authUserId ? "Login successful" : "Patient activated successfully",
        patient: {
          id: patient.id,
          full_name: patient.full_name,
          phone: patient.phone,
          status: "active",
        },
        // Return magic link for immediate login
        // In production, handle this more securely
        auth: sessionData
          ? {
            magic_link: sessionData.properties?.action_link,
          }
          : null,
      });
    }

    return errorResponse(
      "Invalid action. Use 'request_otp' or 'verify_otp'",
      400,
      ErrorCodes.VALIDATION_ERROR
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return errorResponse("Internal server error", 500, ErrorCodes.INTERNAL_ERROR);
  }
});
