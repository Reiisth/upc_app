# UPC Connect (Mobile)

Mobile counterpart to the UPC Connect church management system, focused on **attendance tracking and analytics** for UPC Batangas. Built with Flutter and Firebase.

## Overview

UPC Connect Mobile serves three roles through a single login page:

- **Member** — views their profile, QR code, and attendance history
- **Usher** — records attendance via QR scanning and manages the member roster
- **Pastor** — starts/stops services, views present members, and reviews attendance analytics

Only two Firebase Auth accounts exist for staff-facing roles: one shared **Usher** login and one **Pastor** login. Each supports multiple identities per account (e.g. several ushers sharing one department email), selected via a Netflix-style profile picker after login. Members each have their own individual login, created at registration.

## Tech Stack

- **Flutter** (Android target)
- **Firebase Authentication** — email/password
- **Cloud Firestore** — application data
- ~~Firebase Storage~~ — not available on current plan; photo upload UI exists but is display-only

## Roles & Login Flow

| Role | Login → Landing |
|---|---|
| Member | Login → Profile Selection (family/shared logins may have multiple member profiles) → Member Home |
| Usher | Login → Profile Selection (shared department login may have multiple ushers) → Usher Home |
| Pastor | Login → Pastor Home (single hardcoded account, no picker) |

Login checks Firebase Auth, then reads a `role` field from the matching `users/{uid}` Firestore doc to route accordingly.

## Data Model

### `users/{uid}`
Auth-linked account record — one per Firebase Auth account (shared usher account, pastor account, or an individual member's own login).
| Field | Type |
|---|---|
| `name` | string |
| `role` | string — `"usher"` \| `"member"` \| `"pastor"` |
| `email` | string |

### `members/{memberId}`
Document ID **is** the member's 5-digit Member ID (randomly generated, checked for uniqueness at registration) — not a separate field.
| Field | Type |
|---|---|
| `firstName`, `lastName`, `middleName` | string |
| `birthdate` | timestamp |
| `gender` | string — `"male"` \| `"female"` |
| `civilStatus` | string |
| `address` | string |
| `memberSince` | timestamp |
| `photoUrl` | string — currently always empty |
| `linkedUid` | string — the Firebase Auth account that can log in as this member |

`ministry` and `age` are **computed client-side**, not stored:
- Age 0–12 → Sunday School
- Age 13–17 → Youth
- Age 18+ → Men's Ministry / Women's Ministry, based on `gender`

Member "Active"/"Inactive" status is also computed, not stored: a member is marked inactive if they've missed more than 4 services since their last attendance (or ever, if they've never attended).

### `ushers/{usherId}`
| Field | Type |
|---|---|
| `linkedUid` | string — the shared ushering department account |
| `name` | string |

### `services/{serviceId}`
Only one service may be active church-wide at a time. Ending a service blocks further attendance scans against it.
| Field | Type |
|---|---|
| `name` | string — defaults to e.g. "Sunday Evening Service" if left blank at creation |
| `startedAt` | timestamp |
| `endedAt` | timestamp \| null |
| `status` | string — `"active"` \| `"ended"` |
| `startedBy` | string — pastor's uid |

### `attendance/{autoId}`
| Field | Type |
|---|---|
| `memberId` | string — matches a `members` doc ID |
| `serviceId` | string — matches a `services` doc ID |
| `timestamp` | timestamp |
| `scannedBy` | string — matches an `ushers` doc ID |

## Features by Portal

### Member
- Profile card: name, birthdate, age, civil status, address, computed ministry, computed active/inactive status, last service attended
- QR code display (encodes the member's document ID) for scanning at check-in
- Attendance history: total services attended count, most-recent-first list (service name + date only)
- Logout clears login form fields on return

### Usher
- Home: current date, active-service indicator, count of attendance scanned by this usher this service, total attendees this service
- QR scanner (`mobile_scanner`) with confirmation sheet before recording, session-only recent scan log, duplicate-scan guard
- Manage Members: searchable roster (by name or ID), tap for full profile + delete
- Add Member: registration form (personal details + civil status + address), creates a brand-new Firebase Auth login for the member via a secondary app instance (so the acting usher stays signed in), assigns a random unique 5-digit member ID

### Pastor
- Home tab: greeting, current date, start/stop service (with optional custom name, defaults to a generated name), services list, view present members for the active service
- Analytics tab: placeholder, not yet built
- Members tab: searchable roster, tap for full profile + delete (no add — that's Usher-only)

