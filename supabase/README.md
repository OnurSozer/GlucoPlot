# GlucoPlot Backend (Supabase)

Accepts strict separation of concerns using Postgres RLS and Edge Functions.

## Folder Structure

- **`functions/`**: Deno-based Supabase Edge Functions.
  - `create-patient-v1`: Securely creates a patient and returns a QR token.
  - `redeem-invite-v1`: Validates QR token + Phone OTP to issue session.
  - `evaluate-risk-v1`: Analyzes measurements for threshold breaches.
  
- **`migrations/`**: SQL files applied to the database.
  - `YYYYMMDD..._name.sql`: Schema changes.
  
- **`tests/`**: Database integration tests (pgTAP).

## Policies
- **Row Level Security (RLS)** is enabled on ALL tables.
- **Doctors**: Can SELECT all patients.
- **Patients**: Can SELECT/INSERT only their own data.
