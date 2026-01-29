# GlucoPlot Monorepo Architecture Design

## 1. Mono-Repo Folder Structure

The project will follow a standard monorepo structure with a clear separation of concerns.

```text
GlucoPlot/
├── .vscode/               # Editor workspace settings
├── apps/                  # Application source code
│   ├── mobile/            # Flutter patient application
│   └── web/               # React doctor portal
├── docs/                  # Centralized project documentation
│   ├── architecture/      # System design concepts
│   ├── backend/           # API and Database specs
│   └── guides/            # Onboarding and workflows
├── supabase/              # Backend configuration
│   ├── functions/         # Edge Functions (TypeScript/Deno)
│   ├── migrations/        # SQL Migrations
│   ├── seeds/             # Seed data
│   └── tests/             # Database tests
├── scripts/               # CI/CD and utility scripts
├── README.md              # Entry point for developers
└── .gitignore             # Global gitignore
```

## 2. Web Application Structure (React)

Located in `apps/web/`.
Designed for scalable React development (Vite/Next.js).

```text
apps/web/
├── public/                # Static assets (favicons, etc.)
├── src/
│   ├── assets/            # Images, fonts
│   ├── components/        # Shared UI components
│   │   ├── common/        # Buttons, Inputs, Cards
│   │   ├── layout/        # Sidebar, Header, Layout wrappers
│   │   └── ui/            # Radix/Shadcn primitives
│   ├── config/            # App-wide configuration (env vars)
│   ├── features/          # Feature-based modules (Domain Driven)
│   │   ├── auth/          # Login screens, Auth logic
│   │   ├── dashboard/     # Main doctor dashboard
│   │   ├── patients/      # Patient list, details, creation
│   │   ├── alerts/        # Notification center logic
│   │   └── qr/            # QR generation components
│   ├── hooks/             # Custom global hooks
│   ├── lib/               # Third-party styling/utils (supabase client setup)
│   ├── routes/            # Routing configuration
│   ├── services/          # API/Supabase service wrappers
│   ├── stores/            # Global state management (Zustand/Context)
│   ├── styles/            # Global styles / Theme definitions
│   ├── types/             # TypeScript interfaces
│   ├── utils/             # Helper functions (date formatting, validators)
│   ├── App.tsx            # Root component
│   └── main.tsx           # Entry point
├── .env.example           # Environment variables template
├── package.json
└── vite.config.ts         # Build configuration
```

## 3. Mobile Application Structure (Flutter)

Located in `apps/mobile/`.
Designed using Clean Architecture to separate UI, Domain, and Data.

```text
apps/mobile/
├── assets/                # Images, fonts, translation files
│   ├── images/
│   ├── icons/
│   └── lang/
├── lib/
│   ├── core/              # Shared kernel
│   │   ├── config/        # Environment config
│   │   ├── constants/     # App strings, keys, numeric constants
│   │   ├── error/         # Failure and Exception classes
│   │   ├── theme/         # AppTheme, Colors, TextStyles
│   │   ├── utils/         # Helpers (Validators, DateFormatters)
│   │   └── widgets/       # Global reusable widgets (Buttons, Inputs)
│   ├── features/          # Feature modules (Clean Arch Layers)
│   │   ├── auth/          # QR Scanning, OTP handling
│   │   │   ├── data/      # Repositories, Data Sources
│   │   │   ├── domain/    # Entities, UseCases
│   │   │   └── presentation/ # BLoCs/Providers, Pages, Widgets
│   │   ├── dashboard/     # Main patient summary
│   │   ├── logging/       # Daily event logging (Food, Sleep)
│   │   ├── measurements/  # GlucoPlot device integration
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   └── settings/      # User preferences
│   ├── main.dart          # Entry point used for dev
│   └── main_prod.dart     # Entry point for production
├── test/                  # Unit and Widget tests
├── pubspec.yaml
└── analysis_options.yaml
```

## 4. Supabase / Backend Structure

Located in `supabase/`.
Focuses on Infrastructure-as-Code.

```text
supabase/
├── functions/             # Deno-based Edge Functions
│   ├── _shared/           # Shared code (CORS, DB clients)
│   ├── create-patient-v1/ # Function to create patient & generate QR
│   ├── redeem-invite-v1/  # Function to handle QR + OTP logic
│   └── evaluate-risk-v1/  # Function for measurement analysis
├── migrations/            # SQL files (timestamped)
│   ├── 20240101000000_initial_schema.sql
│   ├── 20240101000001_auth_policies.sql
│   └── 20240105000000_add_measurements.sql
├── seeds/                 # Data for local dev
│   └── seed.sql
├── config.toml            # Supabase local config
└── tests/                 # db-tests (pgTAP or simple scripts)
```

## 5. Documentation Strategy

To be placed in `docs/` and referenced in the root `README.md`.

*   **`docs/README.md`**: Index of all documentation.
*   **`docs/architecture/`**:
    *   `system-overview.md`: High-level diagram (Web, Mobile, PostgREST, Edge Functions).
    *   `auth-model.md`: Detailed explanation of the Doctor (Email/Pass) vs Patient (QR/OTP) flows.
*   **`docs/backend/`**:
    *   `schema.md`: Database ERD diagrams and table descriptions.
    *   `edge-functions.md`: API Contracts (Input/Output JSON), Versioning strategy.
    *   `security.md`: RLS Policy breakdown and Risk Alert logic.
*   **`docs/guides/`**:
    *   `getting-started.md`: Setup guide (Install Docker, Flutter, Node, Supabase CLI).
    *   `deployment.md`: How to deploy Web and Edge functions.

## 6. Naming and Versioning Rules

### Folder & File Naming
*   **General**: `kebab-case` for directories and files (e.g., `user-profile/`, `data-fetching.ts`).
*   **React Components**: `PascalCase` (e.g., `PatientCard.tsx`).
*   **Flutter Classes/Files**: `snake_case` for files (e.g., `patient_repository.dart`), `PascalCase` for classes.
*   **SQL Migrations**: `YYYYMMDDHHMMSS_description.sql`.

### Edge Function Versioning
*   Functions are versioned by directory naming: `my-function-v1`.
*   **Breaking Changes**: Must be deployed as a new function `my-function-v2`.
*   **Non-Breaking**: Can update `v1` in place (e.g., bug fixes, optimizations).

### Database
*   **Tables**: `snake_case`, plural (e.g., `patients`, `daily_logs`).
*   **Columns**: `snake_case` (e.g., `created_at`, `blood_pressure_systolic`).
*   **RLS Policies**: Descriptive sentence casing (e.g., "Doctors can view all patients").
