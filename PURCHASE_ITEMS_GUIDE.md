# Purchase Items Module - Quick Start Guide

## Accessing the Module

### From the Navigation Menu
The purchase items module can be accessed through the application's navigation system.

### Direct Navigation
```dart
// Navigate to purchase items list
context.push('/purchase-items');

// Navigate to create new item
context.push('/purchase-items/new');

// Navigate to specific item detail
context.push('/purchase-items/$itemId');
```

## Common Use Cases

### 1. Viewing All Purchase Items
Navigate to `/purchase-items` to see a complete list of all purchased items across all purchases.

**Features:**
- Search by product name
- Filter options
- Tap any item to view details

### 2. Creating a Standalone Purchase Item
```dart
// Option 1: Navigate directly
context.push('/purchase-items/new');

// Option 2: Use the form page directly
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PurchaseItemFormPage(
      purchaseId: purchaseId, // Optional: pre-select purchase
    ),
  ),
);
```

### 3. Viewing Purchase Item Details
```dart
// Navigate to detail page
context.push('/purchase-items/$itemId');
```

### 4. Editing a Purchase Item
```dart
// Navigate to edit form
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PurchaseItemFormPage(
      itemId: itemId, // Existing item ID
    ),
  ),
);
```

### 5. Deleting a Purchase Item
Delete functionality is available in the detail page through the delete button in the app bar.

## Using Providers

### Get All Purchase Items
```dart
final purchaseItemsAsync = ref.watch(purchaseItemNotifierProvider);

purchaseItemsAsync.when(
  data: (items) => ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return ListTile(title: Text(item.productName ?? ''));
    },
  ),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### Get Purchase Items by Purchase ID
```dart
final itemsAsync = ref.watch(
  purchaseItemsByPurchaseIdProvider(purchaseId),
);
```

### Get Purchase Items by Product ID
```dart
final itemsAsync = ref.watch(
  purchaseItemsByProductIdProvider(productId),
);
```

### Get Recent Purchase Items
```dart
final recentItemsAsync = ref.watch(
  recentPurchaseItemsProvider(limit: 20),
);
```

### Get Purchase Items by Date Range
```dart
final itemsAsync = ref.watch(
  purchaseItemsByDateRangeProvider(startDate, endDate),
);
```

### Perform CRUD Operations
```dart
// Create
await ref.read(purchaseItemNotifierProvider.notifier).addPurchaseItem(item);

// Update
await ref.read(purchaseItemNotifierProvider.notifier).updatePurchaseItem(item);

// Delete
await ref.read(purchaseItemNotifierProvider.notifier).deletePurchaseItem(itemId);

// Refresh
await ref.read(purchaseItemNotifierProvider.notifier).refresh();
```

## Using Widgets

### Display Statistics
```dart
// In your dashboard or any page
PurchaseItemStatsCard(items: purchaseItems)
```

### Display Recent Items
```dart
// Show recent items with default settings
RecentPurchaseItemsWidget()

// Customize
RecentPurchaseItemsWidget(
  limit: 15,
  showTitle: true,
)
```

### Display Item as List Tile
```dart
PurchaseItemListTile(
  item: purchaseItem,
  onTap: () {
    // Custom action
  },
  onDelete: () {
    // Custom delete action
  },
  showActions: true,
)
```

## Integration with Existing Features

### From Purchase Detail Page
You can view all items of a specific purchase:
```dart
final itemsAsync = ref.watch(
  purchaseItemsByPurchaseIdProvider(purchase.id!),
);
```

### From Product Page
View purchase history of a specific product:
```dart
final itemsAsync = ref.watch(
  purchaseItemsByProductIdProvider(product.id!),
);
```

## POS Dashboard Integration

### Add to Dashboard
```dart
Column(
  children: [
    // Statistics Card
    PurchaseItemStatsCard(items: allItems),
    
    SizedBox(height: 16),
    
    // Recent Items
    RecentPurchaseItemsWidget(limit: 10),
  ],
)
```

## Data Model

### PurchaseItem Entity
```dart
class PurchaseItem {
  final int? id;
  final int? purchaseId;
  final int productId;
  final double quantity;
  final String unitOfMeasure;
  final int unitCostCents;
  final int subtotalCents;
  final int taxCents;
  final int totalCents;
  final String? lotNumber;
  final DateTime? expirationDate;
  final DateTime createdAt;
  final String? productName; // For display
}
```

### Creating a Purchase Item
```dart
final item = PurchaseItem(
  purchaseId: purchaseId,
  productId: product.id!,
  productName: product.name,
  quantity: 10.0,
  unitOfMeasure: 'pieza',
  unitCostCents: 5000, // $50.00
  subtotalCents: 50000, // $500.00
  taxCents: 8000, // $80.00
  totalCents: 58000, // $580.00
  lotNumber: 'LOT-2024-001',
  expirationDate: DateTime(2025, 12, 31),
  createdAt: DateTime.now(),
);
```

## Best Practices

### 1. Always Use Cents for Money
Store all monetary values in cents (integers) to avoid floating-point precision issues:
```dart
final costInDollars = 49.99;
final costCents = (costInDollars * 100).round(); // 4999
```

### 2. Validate Before Saving
Always validate form data before creating/updating items:
```dart
if (!_formKey.currentState!.validate()) return;
if (_selectedProduct == null) {
  // Show error
  return;
}
```

### 3. Handle Async Operations Properly
Use try-catch for error handling:
```dart
try {
  await ref.read(purchaseItemNotifierProvider.notifier).addPurchaseItem(item);
  // Show success message
} catch (e) {
  // Show error message
}
```

### 4. Refresh After Modifications
Refresh the list after CRUD operations:
```dart
await ref.read(purchaseItemNotifierProvider.notifier).refresh();
```

## Troubleshooting

### Items Not Showing
1. Check if the purchase_id foreign key is valid
2. Verify the product_id exists in products table
3. Check database constraints

### Form Validation Errors
1. Ensure all required fields are filled
2. Check numeric inputs are valid numbers
3. Verify quantity is greater than 0

### Navigation Issues
1. Ensure routes are properly configured in router.dart
2. Check item IDs are not null when navigating
3. Verify GoRouter is properly initialized

## Performance Tips

### 1. Use Pagination for Large Lists
For large datasets, consider implementing pagination in the list page.

### 2. Optimize Queries
The repository already uses JOINs to minimize database queries. Avoid making additional queries in loops.

### 3. Cache Recent Items
Use the recent items provider with a reasonable limit to avoid loading all items.

### 4. Debounce Search
Implement search debouncing to avoid excessive filtering:
```dart
Timer? _debounce;

void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 500), () {
    setState(() => _searchQuery = query);
  });
}
```

## Support

For issues or questions about the purchase items module, refer to:
- `PURCHASE_ITEMS_IMPLEMENTATION.md` for detailed implementation information
- The codebase documentation in each file
- Clean Architecture principles documentation
