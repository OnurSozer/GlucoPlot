# GlucoPlot Mobile Application

A Flutter application for patients to log daily events and upload device measurements.
Designed using **Clean Architecture**.

## Folder Structure

- **`lib/core/`**: Shared utilities, constants, and widgets.
- **`lib/features/`**: Application modules separated by layer.
  - `auth/`: QR Scanning & OTP Activation.
  - `logging/`: Daily event forms (Food, Sleep).
  - `measurements/`: Hardware integration for GlucoPlot device.
  - `dashboard/`: Patient summary view.

Each feature folder contains:
- `data/`: repositories, data sources (API calls).
- `domain/`: entities, usecases (business logic).
- `presentation/`: logic (BLoC/Provider), pages, widgets.

## Key Technologies
- Flutter
- Supabase Flutter SDK
- QR Code Scanner
- Local Storage (Hive/SharedPreferences) for offline support.
