# Project Blueprint

## Overview

A Flutter application to manage point of sale, cash sessions and cash movements.

## Style, Design, and Features

- **Theme:** A custom theme is implemented in `lib/app/theme.dart` with a color scheme and typography based on Google Fonts.
- **Authentication:** The application uses Firebase Authentication to manage user accounts.
- **Routing:** The application uses `go_router` for navigation.
- **State Management:** The application uses `flutter_riverpod` for state management.

## Current Plan

### Implemented Features

- [x] **Authentication:**
  - [x] Login screen (`lib/presentation/pages/login_page.dart`)
  - [x] Create account screen (`lib/presentation/pages/create_account_page.dart`)
- [x] **Cash Session:**
  - [x] Open cash session screen (`lib/presentation/screens/open_session_screen.dart`)
  - [x] Cash session screen (`lib/presentation/screens/cash_session_screen.dart`)
- [x] **Cash Movement:**
  - [x] Add movement screen (`lib/presentation/screens/add_movement_screen.dart`)
  - [x] Movements list widget (`lib/presentation/widgets/movements_list.dart`)
- [x] **Dashboard:**
  - [x] Dashboard home page (`lib/presentation/pages/home_page.dart`)
  - [x] Dashboard card widget (`lib/presentation/widgets/dashboard_card.dart`)

### Next Steps

- [ ] Implement the revenue details screen.
- [ ] Implement the movements list screen.
