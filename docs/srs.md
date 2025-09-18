# Labor Service Finder — Draft SRS (v0.1)

Version: 0.1  
Date: 2025-09-18

## 1. Overview
A Flutter application that connects customers with local service workers (e.g., Electricians, Plumbers, Painters). This draft SRS is reverse-engineered from the current codebase to provide an initial baseline for alignment. Replace or refine with your formal SRS as needed.

## 2. Scope
- Platforms: Android, iOS, Web, Desktop (Flutter multi-platform enabled in repo)
- In-scope (as implemented in code):
  - Authentication with Firebase Auth (email/password)
  - Role selection (Customer / Worker)
  - Profile setup for both roles
  - Home with service discovery (search, popular services, suggestions)
  - Service list with filters and inline rating control backed by Firestore
  - Profile view/update flows
  - Simple, in-memory state only
- Out-of-scope (not yet implemented):
  - Advanced authorization/claims and role-based rules beyond basic rules
  - Backend APIs other than Firebase
  - Offline sync/local cache strategy
  - Booking, chat, payments, notifications

## 3. Users and Roles
- Guest: Unauthenticated user, sees Login / Sign Up screens.
- Customer: Searches services, views worker lists and details.
- Worker: Sets up profile, can be discovered by customers (Firestore data).

## 4. Functional Requirements
FR-1 Authentication UI
- FR-1.1: User can log in via email and password (UI/validation only).
- FR-1.2: User can sign up by providing username, email, password, and selecting a role (Customer/Worker).

FR-2 Role-based Profile Setup
- FR-2.1: After sign-up, user is routed to the corresponding profile setup.
- FR-2.2: Customer profile fields: full name, phone, DOB, address, area, city.
- FR-2.3: Worker profile fields: full name, phone, DOB, address, area, city, service, experience years.
- FR-2.4: User can update their profile later from My Profile page.

FR-3 Home and Navigation
- FR-3.1: Home shows a searchable list of services and “Popular Services” chips.
- FR-3.2: Typing an exact service name auto-navigates to that service list once per exact match.
- FR-3.3: If there’s a partial match, a primary suggestion is shown; tapping opens the service list.
- FR-3.4: If no match, show alternative service suggestions (based on string distance).
- FR-3.5: Home and Service List app bars include a quick “Home” action.

FR-4 Service Listing and Filters
- FR-4.1: Service list shows workers for the selected service from Firestore (collection: workers; filtered by service).
- FR-4.2: Filters: area (contains), city (contains), minimum rating.
- FR-4.3: User can open a bottom-sheet filter modal and apply filters.
- FR-4.4: Each worker card shows name, tags (service, city, experience), rating badge, phone.
- FR-4.5: “View Profile” opens worker detail page.

FR-5 Ratings
- FR-5.1: User can tap 1–5 stars to set worker’s rating.
- FR-5.2: Rating updates persist to Firestore on the worker document (field: rating) subject to security rules.

FR-6 My Profile
- FR-6.1: User can view profile details.
- FR-6.2: User can navigate to update profile (opens setup page prefilled).
- FR-6.3: Workers see a “Get Premium” prompt (informational dialog).
- FR-6.4: User can log out (clears in-memory state and returns to login).

## 5. Data Model (Current)
- AppState
  - currentRole: UserRole? (customer | worker)
  - customerProfile: CustomerProfile?
  - workerProfile: WorkerProfile?
- CustomerProfile: fullName, phone, dob, address, area, city
- WorkerProfile: fullName, phone, dob, address, area, city, service, experienceYears, rating (double)
- Firestore Collections:
  - workers/{uid}: fullName, phone, dob, address, area, city, service, experienceYears, rating, updatedAt
  - customers/{uid}: fullName, phone, dob, address, area, city, updatedAt

## 6. Navigation Flow (High-level)
- LoginPage → (Login) → HomePage
- LoginPage → (Go to Signup) → SignupPage →
  - if Customer → CustomerProfileSetupPage → HomePage
  - if Worker → WorkerProfileSetupPage → HomePage
- HomePage → MyProfilePage → (View/Update/Logout)
- HomePage → ServiceListPage(service)
- ServiceListPage → WorkerDetailPage

## 7. Validation (Current UI)
- Email requires “@” symbol.
- Password min length: 6.
- DOB required for both roles.
- Worker: service selection required; experience parsed to integer (defaults to 0 if invalid).

## 8. Non-Functional Requirements (Target)
- NFR-1 Usability: Simple, responsive UI across phone and web form factors.
- NFR-2 Performance: Screen transitions < 200ms on target devices; list scrolling remains smooth.
- NFR-3 Reliability: Input validation prevents common user errors; safe navigation guards.
- NFR-4 Maintainability: Modular screens, centralized theme, model separation.
- NFR-5 Portability: Flutter app runs on Android, iOS, Web, Desktop (as applicable).

## 9. Out-of-Scope / Assumptions (for v0.1)
- No real backend integration; data is mock or in-memory only.
- No persistent local storage (state resets on app restart).
- No payments, bookings, messaging, or push notifications.
- No geolocation-based discovery; filters are text-based.

## 10. Open Questions
1. Should authentication be real (Firebase/Auth0/custom backend) or remain local for MVP?
2. What persistence layer is preferred: local (Hive/Sqflite) and/or backend API?
3. Are booking flow, availability, and scheduling part of near-term scope?
4. Do we need phone/email verification and password reset?
5. Should workers upload documents, photos, or certificates? Profile pictures?
6. Any target cities/areas to pre-seed and any localization requirements?

## 11. Future Enhancements (Suggested)
- Real auth + role claims.
- Persistent profiles and worker directory (local + remote).
- Booking workflow (request → quote → confirm → track → complete).
- In-app chat and notifications.
- Geofencing and distance-based search.
- Reviews with comments, not just star rating.
- Premium subscription and worker boosting with rules.

## 12. Acceptance Criteria (Samples)
- AC-Home-1: When user types exactly “Electrician” and presses no extra buttons, ServiceListPage for Electrician opens once automatically.
- AC-Search-1: For partial input (e.g., “elec”), a suggestion row appears; tapping it opens the corresponding service list.
- AC-Filters-1: Applying area=“Andheri”, city=“Mumbai”, min rating=4.5 narrows results accordingly from mock dataset.
- AC-Profile-1: Updating profile via MyProfilePage reflects changes immediately upon returning.

---
This document is generated from the current code; please annotate changes and we will update the SRS accordingly.
