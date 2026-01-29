import { corsHeaders } from "./cors.ts";

/**
 * Create a JSON success response
 */
export function jsonResponse<T>(data: T, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/**
 * Create a JSON error response
 */
export function errorResponse(
  message: string,
  status = 400,
  code?: string
): Response {
  return new Response(
    JSON.stringify({
      error: { message, code: code ?? "ERROR" },
    }),
    {
      status,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    }
  );
}

/**
 * Standard error codes
 */
export const ErrorCodes = {
  UNAUTHORIZED: "UNAUTHORIZED",
  FORBIDDEN: "FORBIDDEN",
  NOT_FOUND: "NOT_FOUND",
  VALIDATION_ERROR: "VALIDATION_ERROR",
  INTERNAL_ERROR: "INTERNAL_ERROR",
  INVITE_EXPIRED: "INVITE_EXPIRED",
  INVITE_ALREADY_REDEEMED: "INVITE_ALREADY_REDEEMED",
  INVALID_OTP: "INVALID_OTP",
  OTP_EXPIRED: "OTP_EXPIRED",
} as const;
