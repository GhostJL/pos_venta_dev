
# Blueprint

## Overview

This document outlines the structure and features of a Flutter application with a complete authentication and authorization system. The app allows users to create accounts, log in, and access protected content based on their assigned roles. The system is built using Riverpod for state management and GoRouter for navigation.

## Features

*   **Authentication:**
    *   User registration with username, email, and password.
    *   Secure password hashing using the `crypto` package.
    *   User sign-in with username and password.
    *   Persistent sessions using a local SQLite database.
    *   Sign-out functionality.
*   **Authorization:**
    *   Role-based access control (RBAC) with predefined user roles (admin, manager, cashier, viewer).
    *   The UI dynamically adapts to the user's role, showing or hiding features accordingly.
*   **Navigation:**
    *   Declarative routing using `GoRouter`.
    *   Protected routes that require authentication.
    *   Automatic redirection based on the user's authentication state.
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
│   └── models
│       └── user_model.dart
├── domain
│   ├── entities
│   │   └── user.dart
│   └── repositories
│       └── auth_repository.dart
├── presentation
│   ├── pages
│   │   ├── create_account_page.dart
│   │   ├── home_page.dart
│   │   └── login_page.dart
│   ├── providers
│   │   └── auth_provider.dart
│   └── router.dart
└── main.dart
```

## Current Plan

I have finished implementing the initial user authentication and authorization. The following steps have been completed:

1.  **Project Setup:**
    *   Initialized a new Flutter project.
    *   Added necessary dependencies: `flutter_riverpod`, `go_router`, `sqflite`, `path`, and `crypto`.
2.  **Domain Layer:**
    *   Defined the `User` entity with roles and properties.
    *   Created the `AuthRepository` interface.
3.  **Data Layer:**
    *   Implemented the `DatabaseHelper` for all database operations.
    *   Created the `AuthRepository` implementation.
4.  **Presentation Layer:**
    *   Set up `GoRouter` for navigation and authentication-based redirects.
    *   Implemented `Riverpod` providers for the authentication state.
    *   Created the `LoginPage`, `CreateAccountPage`, and `HomePage`.

