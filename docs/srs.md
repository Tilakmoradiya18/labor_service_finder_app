# Labor Service Finder — SRS (v0.2)

Version: 0.2  
Date: 2025-09-21

## 1. Overview
A Flutter application that connects customers with local service workers (e.g., Electricians, Plumbers, Painters). This SRS reflects the current implemented behavior using Firebase Auth and Cloud Firestore for profiles, listings, ratings, and premium boosting.

## 2. Scope
- Platforms: Android (primary), iOS, Web, Desktop (Flutter multi-platform enabled).
- In-scope (implemented):
  - Firebase Auth (email/password) login and signup with role selection.
  - Customer/Worker profile setup and update.
  - Home with search, “Popular Services” chips (curated 6), suggestions, and service grid (full catalog).
  - Service list from Firestore with filters (area, city, min rating) and inline star rating.
  - Ratings are averaged across users; user’s own stars persist across sessions.
  - Worker availability toggle in My Profile; unavailable workers are hidden from lists.
  - Premium plans (1 Month, 6 Months, 1 Year) + dummy checkout; premium badge and premium-first sorting.
  - Navigation to worker detail and My Profile.
- Out-of-scope (not yet implemented):
  - Real payment gateway; current checkout is mock.
  - Bookings, chat, notifications.
  - Media uploads/photo gallery.
  - Offline cache strategy.

## 3. Users and Roles
- Guest: Unauthenticated; can reach login/signup.
- Customer: Searches services, filters, rates workers, views profiles.
- Worker: Sets up/edit profile, toggles availability, purchases premium.

## 4. Functional Requirements
FR-1 Authentication
- FR-1.1: Login via email/password using Firebase Auth.
- FR-1.2: Signup collects email/password and role (Customer/Worker).

FR-2 Profiles
- FR-2.1: After signup, route to the respective profile setup.
- FR-2.2: Customer fields: full name, phone, DOB, address, area, city.
- FR-2.3: Worker fields: full name, phone, DOB, address, area, city, service, experience years.
- FR-2.4: Profile can be edited later from My Profile.

FR-3 Home & Search
- FR-3.1: Shows curated “Popular Services” chips (Electrician, Plumber, Painter, Carpenter, AC Repair, House Cleaning).
- FR-3.2: Search with exact match auto-open; partial match suggestion row; alternative suggestions if no match.
- FR-3.3: Service grid lists the full catalog regardless of popular chips.

FR-4 Service Listing
- FR-4.1: Lists workers from Firestore collection `workers`, filtered by exact `service` field.
- FR-4.2: Client-side filters: area contains, city contains, minimum rating.
- FR-4.3: Filter modal is interactive (StatefulBuilder) and applies without rebuild issues.
- FR-4.4: Each card shows: name, city, experience years, rating badge (average), star row (current user’s rating), View Profile, phone.
- FR-4.5: Unavailable workers (available=false) are excluded.

FR-5 Ratings
- FR-5.1: Star tap writes/updates `workers/{id}/ratings/{userId}.value` and transactionally recomputes average and `ratingCount` in `workers/{id}`.
- FR-5.2: Yellow badge shows average rating (to 1 decimal); user star row reflects user’s own rating and persists across sessions.
- FR-5.3: Optimistic UI shows the star selected immediately; reverts on failure.

FR-6 My Profile
- FR-6.1: View profile; update opens setup screens prefilled.
- FR-6.2: Logout signs out from Firebase and clears AppState.
- FR-6.3: Workers: Availability toggle writes `available` to Firestore.
- FR-6.4: Workers: “Get Premium” opens Premium Plans.

FR-7 Premium
- FR-7.1: Premium Plans screen shows 3 plans with large cards: 1 Month, 6 Months, 1 Year.
- FR-7.2: Tapping a plan opens a Checkout screen with dummy payment fields; tapping Pay activates premium (mock) and sets `premium`, `premiumPlan`, `premiumUntil`.
- FR-7.3: Service list prioritizes: premium workers first, ordered by plan priority (1 Year > 6 Months > 1 Month), then later expiry, then higher rating, then name.
- FR-7.4: Premium workers display a “Premium” badge on cards; My Profile shows “Premium Active”; Premium Plans shows “Premium active until …” and “Current plan: …”.

## 5. Data Model / Firestore Schema
- AppState
  - currentRole: enum { customer, worker } | null
  - customerProfile: CustomerProfile | null
  - workerProfile: WorkerProfile | null
- CustomerProfile
  - fullName, phone, dob: Date, address, area, city
- WorkerProfile
  - fullName, phone, dob: Date, address, area, city, service, experienceYears: int
  - rating: double (average), ratingCount: int
  - available: bool
  - premium: bool, premiumPlan: string | null, premiumUntil: Date | null
- Firestore
  - customers/{uid}
    - fullName, phone, dob (ISO or Timestamp), address, area, city, updatedAt
  - workers/{uid}
    - fullName, phone, dob (ISO or Timestamp), address, area, city, service, experienceYears
    - rating (double), ratingCount (int), available (bool)
    - premium (bool), premiumPlan (string|null), premiumUntil (ISO date), updatedAt
    - ratings/{userId}
      - value: double (1..5), updatedAt

## 6. Navigation Flow
- LoginPage → HomePage (onLoggedIn)
- LoginPage → SignupPage →
  - Customer → CustomerProfileSetupPage → HomePage
  - Worker → WorkerProfileSetupPage → HomePage
- HomePage → MyProfilePage → (View / Update / Get Premium / Logout)
- HomePage → ServiceListPage(service)
- ServiceListPage → WorkerDetailPage
- MyProfilePage → PremiumPlansPage → PremiumCheckoutPage → (success) back

## 7. Validation & UX
- Auth: Email must contain “@”; password >= 6 chars.
- Profiles: DOB required; Worker service selection required; experience parsed to int.
- Filters: Modal uses StatefulBuilder to keep slider interactive.
- Ratings: Optimistic star fill; snackbar on error.

## 8. Non-Functional Requirements
- Usability: Clean, responsive UI; consistent Material 3 theme.
- Performance: Smooth lists; avoid blocking UI on network calls; use streams.
- Reliability: Defensive parsing for Firestore types (ISO strings, Timestamps, numbers/strings).
- Security: Recommend Firestore rules to restrict writes to own documents; limit fields for certain updates (e.g., available, ratings).
- Portability: Flutter multi-platform; validated primarily on Android.

## 9. Assumptions & Limitations
- Payments are mocked (no real gateway).
- No offline persistence; state reloads from Firestore after login/navigation.
- Services are predefined constants; no dynamic service taxonomy yet.

## 10. Future Enhancements
- Real payment integration (Razorpay/Stripe) and receipts.
- Media uploads, profile pictures, gallery.
- Booking workflow and messaging.
- Geolocation and distance filters.
- Reviews with text, reporting, moderation.
- Admin dashboards and service taxonomy management.

## 11. Acceptance Criteria (Selected)
- AC-Search-Exact: Typing exactly “Electrician” auto-opens its list once per session.
- AC-Search-Suggest: Typing “elec” shows a suggestion; tapping opens Electrician list.
- AC-Filters: Setting Area=“Vesu”, City=“Surat”, Min Rating=4.0 hides lower-rated or mismatched entries.
- AC-Rating-Average: After two users rate 4 and 3, the badge shows 3.5; each user sees their own star selection.
- AC-Availability: Toggling “Available” off hides the worker from service lists.
- AC-Premium-Order: With two premium workers (1 Year vs 1 Month), the 1 Year plan appears first.
- AC-Premium-Activate: Choosing a plan → Checkout → Pay sets premium=true, premiumPlan, and premiumUntil, and shows Premium badge.

---
This document reflects the current code state (v0.2). Update alongside feature changes.
