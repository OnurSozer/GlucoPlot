# CLAUDE.md - GlucoPlot Developer Guide

## Core Commands

### Web (`apps/web`)
- **Dev Server**: `npm run dev`
- **Build**: `npm run build`
- **Lint**: `npm run lint`
- **Test**: `npm run test`

### Mobile (`apps/mobile`)
- **Run (Dev)**: `flutter run`
- **Run (Prod)**: `flutter run -t lib/main_prod.dart`
- **Test**: `flutter test`
- **Clean**: `flutter clean`
- **Gen Data**: `dart run build_runner build --delete-conflicting-outputs`

### Supabase (`supabase`)
- **Start Local**: `supabase start`
- **Stop Local**: `supabase stop`
- **Gen Types**: `supabase gen types typescript --local > ../apps/web/src/types/supabase.ts`
- **Deploy Function**: `supabase functions deploy <function_name>`

## Project Structure
- **`apps/web`**: React + TypeScript + Vite. Feature-based structure (`src/features/`).
- **`apps/mobile`**: Flutter. Clean Architecture (`data`, `domain`, `presentation`).
- **`supabase`**: Backend. Edge Functions (`functions/`), Migrations (`migrations/`).
- **`docs`**: Documentation is the source of truth for Architecture.

## Style Guidelines

### Naming Conventions
- **Directories/Files**: `kebab-case` (web/backend), `snake_case` (mobile/dart).
- **React Components**: `PascalCase` (e.g., `PatientCard.tsx`).
- **Flutter Classes**: `PascalCase` (e.g., `PatientRepository`).
- **Database Tables**: `snake_case` plural (e.g., `patients`).

### Architecture Rules
- **Mobile**: Strict separation of layers. UI never talks to DB directly; goes through Domain Usecases/Repositories.
- **Web**: Feature-based. keep features self-contained.
- **Backend**: Logic in Edge Functions and RLS policies. No direct SQL access from client unless RLS allows it.

### Versioning
- **Edge Functions**: Versioned by directory name (e.g., `create-patient-v1`). DO NOT modify existing versions deploy new ones.
