# Blueprint: Cash Management App

## Overview

This document outlines the architecture, design, and features of the Cash Management App. The application is a Flutter-based mobile and web app designed to help users track cash flow through distinct work sessions.

## Style & Design

- **Theme:** The app uses a custom theme defined in `lib/app/theme.dart`, which provides a consistent color scheme and styling across the application.
- **Layout:** The layout is designed to be clean, modern, and intuitive, with a focus on ease of use. It uses standard Material Design components with custom styling.
- **Typography:** The app uses the default Material Design typography.

## Features Implemented

### 1. Authentication
- **Login:** Users can log in with their credentials.
- **Create Account:** New users can create an account.

### 2. Cash Sessions
- **Open Session:** Users can start a new cash session with an initial opening balance.
- **View Current Session:** The main screen displays the details of the active cash session, including:
    - Initial Amount
    - Cash Flow (total income minus total expenses)
    - Expected Total
- **Close Session:** Users can close the active session by providing the final cash amount. The app calculates and displays the difference between the expected and actual closing balances.

### 3. Cash Movements
- **Add Movement:** Users can add new transactions (income or expense) to the active session. Each movement includes:
    - Amount
    - Type (Income/Expense)
    - Description
- **List Movements:** The main screen displays a list of all movements for the current session.

### 4. Navigation
- The app uses `go_router` for declarative navigation, with the following routes:
    - `/` (Home/Cash Session Screen)
    - `/login`
    - `/create-account`
    - `/open-session`
    - `/add-movement`

## Current Task: Stabilize and Refactor

### Plan & Steps

1.  **Identify and Fix Critical Errors:**
    - **`cash_session_screen.dart`:**
        - Corrected widget lifecycle by moving `_buildSessionHeader` out of the `build` method.
        - Fixed mismatched braces.
        - Corrected property names from `initialAmount` and `total` to `openingBalanceCents` and `currentBalanceCents`.
        - Implemented a robust `_showCloseSessionDialog` to handle session closing with a form for the final cash amount.
    - **`add_movement_screen.dart`:**
        - Fixed the "The instance member 'ref' can't be accessed in an initializer" error by moving the session ID retrieval logic into the `onPressed` callback.

2.  **Code Formatting and Analysis:**
    - Formatted the entire codebase using `dart format .`.
    - Ran `flutter analyze` to ensure there are no remaining analysis issues.

3.  **Documentation:**
    - Created this `blueprint.md` file to document the application.
