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
- **Onboarding Flow**:
    - Guided setup for the first-time admin user.
    - Creation of initial cashier accounts.
    - Secure access PIN setup.

## Current Task: Implement Supplier Management

### Plan

The current goal is to add a new module for managing suppliers. This includes creating, reading, updating, and deleting (CRUD) supplier information.

1.  **Database Update**: The `DatabaseHelper` will be updated to include a new table for suppliers, with fields such as name, code, contact person, phone, email, etc.
2.  **Domain Layer**: A new `Supplier` entity will be created, along with a `SupplierRepository` interface and corresponding use cases (`GetAllSuppliers`, `CreateSupplier`, `UpdateSupplier`, `DeleteSupplier`).
3.  **Data Layer**: The `SupplierRepositoryImpl` will be created to implement the repository interface, handling the direct interaction with the `sqflite` database.
4.  **State Management**: `Riverpod` providers will be set up to manage the state of the suppliers list, exposing the repository and use cases to the UI.
5.  **User Interface**:
    *   A new `SuppliersPage` will be created to display a list of suppliers in a responsive data table.
    *   A `SupplierForm` will be developed to allow users to add and edit supplier details in a dialog.
    *   A new card will be added to the `Dashboard` to provide easy access to the supplier management page.
6.  **Routing Update**: The `go_router` configuration will be updated to include a new route `/suppliers` that navigates to the `SuppliersPage`.
