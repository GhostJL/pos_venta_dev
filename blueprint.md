
# Blueprint

## Overview

This document outlines the structure and features of a Flutter application with a complete authentication and authorization system. The app allows users to create accounts, log in, and access protected content based on their assigned roles. It now includes features for cash management, allowing cashiers to open and close cash sessions. The system is built using Riverpod for state management and GoRouter for navigation.

## Features

*   **Authentication:**
    *   User registration with username, email, and password.
    *   Secure password hashing using the `crypto` package.
    *   User sign-in with username and password.
    *   Persistent sessions using a local SQLite database.
    *   Sign-out functionality.
*   **Authorization:**
    *   Role-based access control (RBAC) with predefined user roles (admin, manager, cashier, viewer).
    *   Admin users are automatically assigned all permissions upon registration.
    *   The UI dynamically adapts to the user's role, showing or hiding features accordingly.
*   **Cash Management (for Cashier role):**
    *   **Cash Opening Screen:** Allows cashiers to open a new cash session with an initial balance.
    *   **Cash Closing Screen:** Allows cashiers to close their session, recording the final cash amount and showing any discrepancies.
    *   **Database Tables:** Includes `cash_sessions` and `cash_movements` to track cash flow.
*   **Navigation:**
    *   Declarative routing using `GoRouter`.
    *   Protected routes that require authentication.
    *   Automatic redirection based on the user's authentication state.
    *   Role-based redirection after login (admins to `HomePage`, cashiers to `CashOpeningPage`).
*   **State Management:**
    *   Centralized app state managed by `Riverpod`.
    *   `StateNotifier` for managing the authentication state.
*   **Database:**
    *   Local SQLite database for storing user data.
    *   The `sqflite` package for database interactions.

## Project Structure

```
lib
├── data
│   ├── datasources
│   │   └── database_helper.dart
│   ├── models
│   │   ├── user_model.dart
│   │   ├── cash_session_model.dart
│   │   └── cash_movement_model.dart
│   └── repositories
│       ├── ...
├── domain
│   ├── entities
│   │   ├── user.dart
│   │   ├── cash_session.dart
│   │   └── cash_movement.dart
│   └── repositories
│       ├── auth_repository.dart
│       ├── ...
├── presentation
│   ├── pages
│   │   ├── create_account_page.dart
│   │   ├── home_page.dart
│   │   ├── login_page.dart
│   │   ├── cash_opening_page.dart
│   │   └── cash_closing_page.dart
│   ├── providers
│   │   └── auth_provider.dart
│   └── router.dart
└── main.dart
```

## Current Plan

I will now implement the new cashier and admin role features.

1.  **Database Update:**
    *   Add the `cash_sessions` and `cash_movements` tables to the `DatabaseHelper`.
    *   Modify the `User` table to include a `role` column.
2.  **Domain & Data Layers:**
    *   Create `CashSession` and `CashMovement` entities.
    *   Create `CashSessionModel` and `CashMovementModel` for data mapping.
    *   Create repositories for managing cash sessions and movements.
3.  **Admin Role Assignment:**
    *   Update the `signUp` method in `auth_provider.dart` to assign the 'admin' role to new users.
    *   Grant all permissions to the new admin user.
4.  **Presentation Layer:**
    *   Create the `CashOpeningPage` and `CashClosingPage` widgets.
    *   Update the `GoRouter` configuration to include the new routes.
    *   Implement role-based redirection after login.
5.  **Final Polish:**
    *   Ensure the UI is clean, responsive, and follows the application's theme.
    *   Add appropriate error handling and user feedback.
