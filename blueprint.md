# POS System Blueprint

## Overview

This document outlines the architecture and features of a Point of Sale (POS) system built with Flutter. The application follows the principles of Clean Architecture to ensure a modular, scalable, and maintainable codebase.

## Architecture

The project is structured into three main layers:

*   **Domain:** Contains the core business logic, entities, and use cases. This layer is independent of any other layer.
*   **Data:** Implements the repositories defined in the domain layer and manages data sources (e.g., local database, network).
*   **Presentation:** Contains the UI and state management logic (e.g., using Provider).

## Features

### 1. Authentication

*   **Login:** Users can log in with their email and password.
*   **Roles:** The app supports two user roles: Admin and Cashier.
*   **Onboarding:** A simple onboarding process for setting up the initial admin user.

### 2. Dashboard

*   **Sales Summary:** A dashboard displaying key sales metrics for the day.
*   **Quick Access:** Shortcuts to common tasks like managing inventory and viewing reports.
*   **Recent Activity:** A list of recent sales transactions.

### 3. CRUD Operations

The app provides full CRUD (Create, Read, Update, Delete) functionality for the following entities:

*   **Departments:** Organize products into different departments.
*   **Categories:** Further categorize products within departments.
*   **Brands:** Manage product brands.
*   **Suppliers:** Keep track of product suppliers.
*   **Warehouses:** Manage warehouses and branches.

### 4. Cashier Interface

*   **Simple Interface:** A streamlined interface for cashiers to process sales quickly.

## Current Plan

*   Implement the `warehouses` table and its corresponding CRUD operations, following the clean architecture principles already established in the project.
*   Create the UI for managing warehouses.
