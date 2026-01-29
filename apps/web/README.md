# GlucoPlot Web Application

A React-based web portal for doctors to manage patients and view risk alerts.
Designed for **Vite** + **React** + **TypeScript**.

## Folder Structure

- **`src/features/`**: Domain-driven feature modules.
  - `auth/`: Login/Logout logic.
  - `dashboard/`: Main overview for doctors.
  - `patients/`: Patient management (Create, List, Details).
  - `alerts/`: Notification system for risky measurements.
  - `qr/`: Components for generating patient activation QR codes.
- **`src/components/`**: Shared UI components (Buttons, Inputs).
- **`src/services/`**: Supabase client and API wrappers.
- **`src/stores/`**: Global state management.

## Key Technologies
- React
- TypeScript
- Supabase Client
- Tailwind CSS (recommended)
