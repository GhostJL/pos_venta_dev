# POS System Blueprint

## Overview

This document outlines the architecture, features, and ongoing development of a Point of Sale (POS) system built with Flutter. The application is designed with a focus on Clean Architecture to ensure a modular, scalable, and maintainable codebase.

## Project Outline

### Architecture

The project is structured into three main layers:

*   **Presentation:** Contains the UI (Widgets) and state management logic (using `flutter_riverpod`).
*   **Domain:** Includes the core business logic, entities (data structures), and use cases (application-specific business rules). This layer is the core of the application and is independent of any UI or data implementation details.
*   **Data:** Implements the repository interfaces defined in the domain layer. It's responsible for fetching data from and storing data to various sources, such as a local SQLite database.

### Implemented Features

*   **Authentication:**
    *   User login with email and password.
    *   Support for Admin and Cashier user roles.
    *   Initial onboarding flow for setting up the first admin user.
*   **Dashboard:**
    *   Displays key sales metrics.
    *   Provides quick access to common features.
    *   Shows a log of recent sales activity.
*   **CRUD Operations:**
    *   Full Create, Read, Update, and Delete functionality for:
        *   Departments
        *   Categories
        *   Brands
        *   Suppliers
        *   Warehouses
        *   Tax Rates

## Current Task: Refactoring & Dependency Simplification

The following steps were taken to refactor the application and reduce its dependencies:

*   **Removed `fpdart` and `equatable`:**
    *   Replaced the `Either` type from `fpdart` with standard Dart `Future`s and `try-catch` blocks for error handling across the data and domain layers.
    *   Removed the `equatable` package from entity classes, simplifying the models and relying on manual comparison where necessary.
*   **Updated Domain Layer:**
    *   Modified all use cases (`create_tax_rate`, `delete_tax_rate`, etc.) to return `Future<void>` or `Future<T>` directly, instead of `Future<Either<Failure, T>>`.
*   **Updated Data Layer:**
    *   Adjusted the `TaxRateRepositoryImpl` to align with the updated repository interface, removing `fpdart`.
*   **Updated Presentation Layer:**
    *   Refactored `TaxRateNotifier` (`tax_rate_provider.dart`) to handle state and errors from the simplified use cases using `AsyncValue.error` within `try-catch` blocks.
*   **Cleaned Up Dependencies:**
    *   Removed the `fpdart` and `equatable` packages from `pubspec.yaml`.
    *   Deleted the now-unused `lib/core/errors/failures.dart` file.
    *   Executed `flutter pub get` to synchronize project dependencies.
