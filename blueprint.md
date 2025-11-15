# Blueprint: Cash Management App

## Overview

This document outlines the architecture, features, and design of the Cash Management Flutter application. It serves as a single source of truth for the project's implementation details.

## Style & Design

- **UI Framework**: Flutter with Material Design 3.
- **Theme**: A consistent theme is applied using `ThemeData`, with support for both light and dark modes. Colors are generated from a seed color for a modern look.
- **Typography**: Custom fonts are managed via `google_fonts` to ensure a unique and readable text style across the app.
- **Layout**: The app uses a responsive layout, ensuring a great user experience on both mobile and web. Key components are organized in a clean, intuitive manner.

## Features Implemented

- **Authentication**:
    - Secure user login.
    - Role-based access control (Admin, Manager, Cashier, Viewer).
    - State managed by `AsyncNotifier` from `flutter_riverpod`.
- **Routing**:
    - Declarative routing managed by `go_router`.
    - Authentication-aware redirects to protect routes.
    - Shell route for persistent UI elements like the main app bar.
- **Database**:
    - Local persistence using `sqflite`.
    - Repository pattern to abstract data sources.
- **Architecture**:
    - Layered architecture (Presentation, Domain, Data).
    - Dependency injection using `flutter_riverpod`.

## Current Task: Implement Onboarding Flow

### Plan

The current goal is to replace the existing public sign-up flow with a guided onboarding process for the first-time admin user.

1.  **Remove Public Sign-Up**: The `SignUpPage` will be deleted, and the corresponding route will be removed.
2.  **First-Run Detection**: The app will check if an admin user exists in the database on startup. If not, it will trigger the onboarding flow.
3.  **Onboarding Screens**: A series of new screens will be created:
    *   **Admin Setup Screen**: Allows the initial admin to confirm or edit their pre-filled details (username, password). A default admin user will be provided.
    *   **Add Cashiers Screen**: A screen for the admin to add up to 4 cashier accounts.
    *   **Set Access PIN Screen**: A screen to define a numeric PIN for quick access (initially hardcoded to '1234').
4.  **Router Update**: `go_router` will be updated to handle the new onboarding logic:
    *   On startup, if no admin exists, redirect to `/setup-admin`.
    *   The onboarding screens will navigate sequentially: `/setup-admin` -> `/add-cashiers` -> `/set-pin`.
    *   After onboarding, the user will be directed to the `/login` page.
5.  **Repository & Provider Updates**: The `AuthRepository` and `authProvider` will be modified to support the creation of users with specific roles (Admin and Cashier) as part of the new flow.
6.  **Login Page Cleanup**: The `LoginPage` will be updated to remove the link to the old sign-up page.
