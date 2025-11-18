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
*   **Core Data Management (CRUD):**
    *   Full Create, Read, Update, and Delete functionality for:
        *   Departments
        *   Categories
        *   Brands
        *   Suppliers
        *   Warehouses
        *   Tax Rates

## Current Task: Enhanced Product Management

This task focuses on implementing a comprehensive product management module with advanced UI and backend functionalities.

### 1. Product Form (UI Form)

**Layout:**
A structured form to input all product details efficiently.
*   Row 1: Code, Barcode, Name, Description
*   Row 2: Department, Category, Brand, Supplier
*   Row 3: Unit of Measure, Is Sold by Weight toggle
*   Row 4: Cost Price, Sale Price, Wholesale Price
*   Row 5: Product Taxes (Multi-select)
*   Row 6: Is Active toggle

**Key Details & Validations:**
*   **Price Validation:** Ensure that `sale_price_cents` is greater than `cost_price_cents`.
*   **Taxes:**
    *   Display a list of all active `tax_rates`.
    *   Allow the user to select multiple taxes for a single product.
    *   The order in which taxes are applied (`apply_order`) must be editable if more than one tax is selected.
    *   Display tax labels clearly (e.g., "IVA 16%", "Exento", "IEPS 8%").

### 2. Product List Page (UI List Page)

**Item Structure:**
A clear and concise layout for each product in the list.
*   Row 1: Product Name
*   Row 2: Code, Barcode
*   Row 3: Sale Price
*   Row 4: Unit of Measure

**Functionalities:**
*   **Search:** Implement a search bar that queries against product `name`, `code`, and `description` using a `FULLTEXT` index (`idx_search`) for fast and relevant results.
*   **Filtering:** Provide options to filter the product list by `department`, `category`, `brand`, and `supplier`.
*   **Sorting:** Allow users to sort the list by `price`, `name`, or `creation_date`.
*   **Quick Actions:** Each product item will have a menu with quick actions:
    *   **Edit:** Navigate to the Product Form.
    *   **Duplicate:** Pre-fill the Product Form with the data of the selected product to create a new one.
    *   **Deactivate/Activate:** Toggle the `is_active` status of the product.

### Implementation Plan

1.  **Database Schema (`database_helper.dart`):**
    *   Finalize the `CREATE TABLE` statement for `product_taxes`, including columns for `product_id`, `tax_rate_id`, and `apply_order`.
    *   Add a `FULLTEXT` index named `idx_search` on the `name`, `code`, and `description` columns of the `products` table.
2.  **Domain & Data Layers:**
    *   Define a `ProductTax` entity in the domain layer.
    *   Update the `Product` entity to include a `List<ProductTax>`.
    *   Implement data access methods in `DatabaseHelper` for advanced product queries (search, filter, sort) and for managing the `product_taxes` relationship.
3.  **Presentation Layer (Providers):**
    *   Refactor `ProductNotifier` to handle the new state requirements, including search queries, filter parameters, and sort order.
    *   The provider will orchestrate calls to the data layer to fetch and update the product list based on user interactions.
4.  **Presentation Layer (UI):**
    *   **Product Form:** Redesign the UI to match the specified layout. Implement the price validation and the multi-select tax widget with drag-and-drop reordering.
    *   **Product List:** Redesign the product list items. Integrate the search bar, filter controls, sorting options, and the quick actions menu.
