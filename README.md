# VYORA – Visitor Management App

A Flutter app for front-desk and security staff. Register visitors, give them a QR pass, scan the pass, check visitors in and out, and see live numbers on a dashboard.

Light theme is white and gold. Dark theme is black and gold. The theme can be switched from the dashboard.

## Screenshots

| Dashboard | Visitor list | Register visitor |
|---|---|---|
| ![Dashboard](screenshots/dashboard.png) | ![Visitor list](screenshots/visitor_list.png) | ![Register](screenshots/register.png) |

| Visitor pass with QR | QR scanner | Light theme |
|---|---|---|
| ![Pass](screenshots/pass_qr.png) | ![Scanner](screenshots/scanner.png) | ![Light](screenshots/light_theme.png) |

## Features

- Dashboard with Total Today, Checked In and Checked Out counts, quick actions and recent visitors
- Register a visitor with validation (name, 10 digit mobile, optional email, type, project, purpose)
- QR pass generated from the visitor id the server returns
- Visitor list with search by name or mobile, filters by status and project, pull to refresh
- Edit and delete visitors (delete asks for confirmation)
- QR scanner with flashlight, plus an option to upload a QR image from the gallery
- Check in and check out from the visitor details screen
- Loading, empty and error states with a retry button on every screen
- Light and dark theme, saved between launches

## Versions

Fill these in from your machine (`flutter --version`):

- Flutter: `3.xx.x` (stable channel)
- Dart: `3.x.x`
- Minimum Android SDK: 23

## Setup and run

1. Install Flutter and an Android emulator or a real device.
2. Clone the repository and get the packages:
   ```
   git clone <your-repo-link>
   cd vyora
   flutter pub get
   ```
3. Set the API URL in `lib/services/api_service.dart`:
   ```dart
   const String baseUrl = 'https://xxxx.mockapi.io/api/v1';
   ```
   If `baseUrl` still contains `YOUR_ID`, the app runs on built-in demo data (5 sample visitors kept in memory) so it can be tried without a server.
4. Run the app:
   ```
   flutter run
   ```
5. Run the tests:
   ```
   flutter test
   ```
6. Build the APK:
   ```
   flutter build apk --release
   ```
   The file is created at `build/app/outputs/flutter-apk/app-release.apk`.

## Login

Not applicable. The assignment does not include authentication, so there is no login screen and no test credentials.

## API details

Mock API created with [MockAPI.io](https://mockapi.io). Resource: `visitors`.

Base URL: `<add your MockAPI base URL here>`

| Action | Method | Endpoint |
|---|---|---|
| List visitors | GET | `/visitors` |
| Get one visitor (used by the scanner) | GET | `/visitors/{id}` |
| Register visitor | POST | `/visitors` |
| Edit visitor, check in, check out | PUT | `/visitors/{id}` |
| Delete visitor | DELETE | `/visitors/{id}` |

Sample record:

```json
{
  "id": "1",
  "name": "Aarav Mehta",
  "mobile": "9876543210",
  "email": "aarav@example.com",
  "visitor_type": "Customer",
  "project": "Project A",
  "purpose": "Site walkthrough",
  "status": "Registered",
  "created_at": "2026-10-29T09:30:00.000Z",
  "check_in_time": null,
  "check_out_time": null
}
```

- `status` is one of `Registered`, `Checked In`, `Checked Out`.
- `visitor_type` is one of `Customer`, `Vendor`, `Other`.
- The server creates the `id`. The QR code contains only this id.
- Dates are sent in UTC and shown in the phone's local time.

## How it is built

The app uses MVC with Provider for state management.

```
lib/
  main.dart
  models/        visitor_model.dart
  controllers/   visitor_controller.dart, theme_controller.dart
  services/      api_service.dart
  views/         screens and widgets/
  theme/         app_theme.dart
  utils/         validators.dart, snack_bar.dart
test/
```

- `VisitorController` holds the visitor list and all rules. Every screen reads from it, so a check-in made anywhere shows up everywhere straight away.
- Status flow is Registered, then Checked In, then Checked Out. Before any change, the controller fetches the latest visitor from the server and checks the flow is valid. A second tap while a change is running is ignored. Because of this a visitor cannot be checked in twice, even from repeated scans.
- The scanner ignores repeated callbacks while a code is being checked. It shows separate messages for an invalid QR code, a visitor that is not found, and a network problem.

## Packages used

| Package | Why |
|---|---|
| provider | State management |
| dio | HTTP calls to the API |
| qr_flutter | Generate the QR pass |
| mobile_scanner | Scan QR codes with the camera and read QR images |
| image_picker | Pick a QR image from the gallery |
| google_fonts | Manrope font |
| flutter_animate | Small entrance and loading animations |
| shared_preferences | Remember the chosen theme |
| intl | Date formatting |

## Known limitations

- No login or user roles, because the assignment does not ask for them.
- MockAPI has no real validation or security. Anyone with the URL can read and change data.
- Search and filters run on the phone after the full list is downloaded, which is fine for small data but not for thousands of records.
- Dashboard counts are calculated on the phone from the list, since there is no dashboard endpoint.
- Two staff members acting on the same visitor at the same moment can still overlap, because a mock API cannot lock a record. The app re-checks the status right before each change to keep this rare.
- "Today" uses the phone's date and timezone.
- Fonts are downloaded the first time the app opens, so the very first launch needs internet.
- Tested on Android only.
