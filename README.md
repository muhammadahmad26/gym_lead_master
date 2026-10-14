# 🏋️ Gym Lead Master

> A Flutter + Firebase gym management app: member approval, check-in, attendance, payments and chat in one place, for gym owners and their members.

![Flutter](https://img.shields.io/badge/Flutter-Dart%20%5E3.7.2-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase&logoColor=black)
![Version](https://img.shields.io/badge/version-1.0.0%2B1-blue)
![License](https://img.shields.io/badge/license-TBD-lightgrey)
<!-- No CI workflow exists in the repo, so no build-status badge. Add one if you set up GitHub Actions. -->

---

## 🎬 Demo

<!-- VIDEO_DEMO_HERE -->

## 📸 Screenshots

| Login | Admin Home | Member Check-in |
|:---:|:---:|:---:|
| <!-- screenshot --> | <!-- screenshot --> | <!-- screenshot --> |

| Payments | Attendance | Chat |
|:---:|:---:|:---:|
| <!-- screenshot --> | <!-- screenshot --> | <!-- screenshot --> |

---

## Overview

Small gyms often track members, attendance and payments with spreadsheets, paper registers and WhatsApp groups. **Gym Lead Master** replaces that with one app.

- **Gym owners (admins)** register a gym under a unique Gym ID, approve new members, review payment screenshots, track attendance, send notifications and chat with members.
- **Members and trainers** sign up with their gym's ID, check in with the exercises they plan to do, submit payments, and see notifications and chat messages.

Every gym's data lives under its own `gyms/{gymId}` document, so many gyms can share one Firebase project.

---

## ✨ Key Features

**Onboarding & access**
- Separate admin and member login/signup flows; password reset by email.
- Admins create a unique Gym ID at signup. Signup is rejected if the ID is already taken.
- Members choose a role (`Gym Member` or `Trainer`) and sign up with their Gym ID.
- Members stay **pending** until an admin approves them. Pending or removed members are signed out at login with a clear message.
- If saving the profile fails during signup, the newly created Auth user is rolled back.

**Admin tools**
- **Pending Approvals** screen (approve or reject, with a live badge count).
- Member list with status chips (`ACTIVE`, `PENDING`, `NOT PAID`, `EXPIRED`) and an expired-membership count.
- Member detail view with **delete member**, which removes payments, attendance records, notifications and the member record.
- **Manage Exercises**: add or remove the exercise list members see at check-in.
- Payments: review submissions (approve/reject with a reason) and manage membership plans (Monthly / Quarterly / Yearly) and payment methods.
- Attendance dashboard by month, per-member attendance, and **PDF report export**.
- Notifications: send to all or selected members, with types (General, Gym Timing, Payment Reminder, Membership Expiring, Event, Emergency, and more), and delete for everyone.

**Member tools**
- Check-in with a scrollable exercise picker (falls back to a default list if the admin hasn't configured one).
- Payments: pick a plan and payment method, upload a screenshot (max 500 KB), and view history filtered by status.
- After approval, the plan period is stored and a new payment is blocked until it expires.
- Notifications with a full-detail bottom sheet; text chat with the gym admin.
- Profile: name, location, email, password, profile photo; Help & FAQ, Contact Support, About, Terms, Privacy.

**Platform**
- Firebase Hosting config for the web build.
- On web, the UI is constrained to a phone-width column (max 480 px) and centred.

---

## 🧰 Tech Stack

| Area | Technology |
|---|---|
| Framework | Flutter (Dart SDK `^3.7.2`) |
| Auth / Database | `firebase_auth ^6.1.2`, `cloud_firestore ^6.1.1`, `firebase_core ^4.2.1` |
| Image hosting | Cloudinary (unsigned upload via `http ^1.6.0`) |
| Local storage | `shared_preferences ^2.5.3` |
| Media / files | `image_picker ^1.2.1`, `pdf ^3.11.3`, `path_provider ^2.1.5`, `share_plus ^12.0.2` |
| UI / utils | `google_fonts ^6.3.2`, `intl ^0.20.2`, `timeago ^3.7.1`, `url_launcher ^6.3.2`, `device_info_plus ^10.1.0` |
| Tooling | `flutter_lints ^5.0.0`, `flutter_launcher_icons ^0.13.1`, `flutter_native_splash ^2.4.1` |
| Also declared | `firebase_storage ^13.0.5` |

Platform folders are present for Android, iOS, Web, Windows, macOS and Linux. `firebase_options.dart` defines options for web, Android, iOS, macOS and Windows. Android `minSdk` is 23.

---

## 🗂️ Project Structure

```
gym_lead_master/
├── lib/
│   ├── main.dart                  # Firebase init, MaterialApp, web width wrapper
│   ├── firebase_options.dart      # Firebase config per platform
│   ├── services/                  # Backend logic
│   │   ├── auth_service.dart          # Admin/member signup (with rollback)
│   │   ├── database_service.dart      # Firestore: payments, plans, chat, exercises, approvals
│   │   ├── attendance_service.dart    # Monthly attendance records & summaries
│   │   ├── notification_service.dart  # Send/read/delete notifications
│   │   ├── cloudinary_service.dart    # Image upload to Cloudinary
│   │   ├── pdf_report_service.dart    # Attendance PDF export
│   │   ├── settings_service.dart      # Theme/language prefs (SharedPreferences)
│   │   └── storage_service.dart       # Firebase Storage helper (see Questions)
│   └── src/
│       ├── core/                  # Constants, validators, responsive helpers, shared widgets
│       ├── data/                  # Models (attendance, payment, plan, notification, ...)
│       └── presentation/
│           ├── routes/            # appRoutes.dart + appRouter.dart (named routes)
│           └── pages/
│               ├── splash_page/       # Splash + login chooser
│               ├── login_pages/       # Admin / member login wrappers
│               ├── signUp_page/       # Admin / member signup wrappers
│               ├── common/            # Shared screens (login, signup, home, profile, notifications)
│               ├── admin_pages/       # Members, approvals, exercises, attendance, payments, chat
│               └── member_pages/      # Home/check-in, payments, chat, profile
├── test/widget_test.dart          # Default Flutter template test (see Testing)
├── firestore.rules                # Firestore security rules
├── firestore.indexes.json         # Composite indexes
├── storage.rules                  # Storage rules
├── firebase.json / .firebaserc    # Hosting, rules, emulators; default project gym-lead-master-app
└── assets/                        # Images, Roboto fonts
```

---

## Prerequisites

- Flutter SDK that bundles **Dart ≥ 3.7.2**
- A Firebase project with **Email/Password** Authentication and **Cloud Firestore** enabled
- [Firebase CLI](https://firebase.google.com/docs/cli) for deploying rules and hosting
- A Cloudinary account with an **unsigned upload preset**
- Android Studio / Xcode for mobile targets; Chrome for web

---


**Using your own Firebase project** (the repo currently points to `gym-lead-master-app`):

1. Replace the values in `lib/firebase_options.dart` with your project's config (for example by regenerating it with the FlutterFire CLI).
2. Update the default project in `.firebaserc`.
3. Deploy rules and indexes:
```bash
   firebase deploy --only firestore:rules,firestore:indexes
```

---

## Configuration

This project has **no `.env` file** and no dotenv dependency. Configuration is set in code:

| Setting | Location | Description | Required |
|---|---|---|---|
| Firebase options (API key, app ID, project ID, bucket) | `lib/firebase_options.dart` | Per-platform Firebase config | Yes |
| Default Firebase project | `.firebaserc` | Used by the Firebase CLI | Yes (for deploys) |
| `CloudinaryService.cloudName` | `lib/services/cloudinary_service.dart` | Cloudinary cloud name | Yes (image uploads) |
| `CloudinaryService.uploadPreset` | `lib/services/cloudinary_service.dart` | Unsigned upload preset name | Yes (image uploads) |
| Support email / phone / WhatsApp | `lib/src/presentation/pages/common/profile_page/contact_support_screen.dart` | Contact details shown in Contact Support | Optional |
| Android `applicationId` | `android/app/build.gradle.kts` | Currently `com.example.gym_lead_master` | Change before publishing |

Debug builds disable Firestore persistence (`main.dart`, `kDebugMode`).

---

## Usage

**Main flows**

1. **Admin signup:** choose "Gym Admin", sign up with a *unique Gym ID*, then log in on the admin side.
2. **Set up the gym:** in the Payments tab add membership plans and payment methods. On the Home screen, open the 🏋️ icon to manage the exercise list.
3. **Member signup:** the member signs up with the gym's Gym ID and sees "pending approval" when logging in.
4. **Approval:** the admin opens **Gym Members → ✓ icon (Pending Approvals)** and approves or rejects.
5. **Payment:** the member picks a plan and method, uploads a screenshot and submits. The admin approves in Payments, and the member's membership becomes active until the plan period ends.
6. **Check-in:** an active member taps the centre button, selects exercises and checks in. Attendance and the live home-screen counters update.

**External API:** the app has no REST backend. The only direct HTTP call is the Cloudinary upload:

```
POST https://api.cloudinary.com/v1_1/<cloudName>/image/upload   (multipart: file, upload_preset)
```

**Firestore layout (from code and `firestore.rules`)**

| Path | Purpose |
|---|---|
| `users/{uid}` | Profile, role, `gymId` |
| `users/{uid}/notifications/{id}` | A member's notifications |
| `gyms/{gymId}` | Gym document (`adminId`, name, location) |
| `gyms/{gymId}/members/{uid}` | Member record (status, `approvalStatus`, `membershipExpiresAt`) |
| `gyms/{gymId}/payments`, `payment_methods`, `membership_plans` | Billing |
| `gyms/{gymId}/attendance_months/{month}/records/{uid}` | Monthly attendance |
| `gyms/{gymId}/exercises` | Admin-managed exercise list |
| `gyms/{gymId}/stats/{yyyy-MM-dd}` | Daily live counters |
| `gyms/{gymId}/chat_rooms/{id}/messages` | Chat |
| `support_requests` | Contact Support submissions |

---

## Testing

```bash
flutter analyze
flutter test
```

⚠️ `test/widget_test.dart` is still the **default Flutter counter test**, and the app has no counter, so it is expected to fail. It also pumps `MyApp` without initialising Firebase. There are no other tests yet.

---

## Deployment

**Web (Firebase Hosting)**: `firebase.json` serves `build/web` with a single-page-app rewrite.

```bash
flutter build web --release
firebase deploy --only hosting
```

Add your hosting domain under **Firebase Console → Authentication → Settings → Authorized domains**, or sign-in will fail.

**Android**

```bash
flutter build apk --release
```

Before distributing, replace the placeholder `applicationId` and set up proper release signing.

**Security rules**

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

---

## Roadmap

*Proposed, based on gaps visible in the code. Edit to match your plans.*

- [ ] Image attachments in chat (chat is text-only today)
- [ ] Make the home-screen exercise cards fully dynamic (currently six fixed cards; custom exercises are counted under `exerciseCounts` but not shown)
- [ ] Cloud Function to delete a removed member's Firebase Auth account (the client can't; removal currently deletes Firestore data and blocks login)
- [ ] Replace the placeholder widget test with real unit and widget tests
- [ ] Add CI (analyze + test)
- [ ] Tighten `storage.rules` and add rules for `support_requests`

---

## Contributing

1. Fork the repo and create a branch: `git checkout -b feature/your-feature`
2. Make your changes and run `flutter analyze` and `flutter test`
3. Commit with a clear message and open a Pull Request describing what changed and why

---

## License

<!-- No LICENSE file exists in the repo. Choose one (e.g. MIT) and add a LICENSE file. -->
License: **TBD**

## Author / Contact

- **Name:** <!-- your name -->
- **LinkedIn:** <!-- link -->
- **Email:** <!-- email -->

---

## ❓ Questions (resolve, then delete this section)

1. **License:** which one do you want? No `LICENSE` file exists.
2. **Committed Firebase config:** `firebase_options.dart` contains real project values. Is the repo public with these values intended?
3. **`storage.rules`** currently allows `read, write: if true`. Is Firebase Storage actually used? `storage_service.dart` is declared but appears unused (images go through Cloudinary).
4. **`support_requests`** is written by the app but has no Firestore rule. Is that intentional?
5. **Super-admin routes** (`/super_admin_login`, `/super_admin_dashboard`, `/admin_management`) are defined in `appRoutes.dart` but not registered in `appRouter.dart`. Planned feature or leftover?
6. **Theme/language:** `settings_service.dart` stores them, but only the profile screen reads them. Is app-wide theming/localisation intended?
7. **Emulators:** `firebase.json` defines them, but the emulator connection code in `main.dart` is commented out. Should the README document an emulator workflow?
8. **Supported platforms:** which targets do you officially support? `firebase_options.dart` has no Linux config.
9. **Minimum Flutter version:** the repo only pins Dart `^3.7.2`.
10. **`gyms/{gymId}/broadcasts`** has a Firestore rule, but nothing in the code uses it. Remove or planned?
