import 'package:flutter/material.dart';
import 'package:posventa/presentation/pages/inventory/inventory_audit_desktop_page.dart';
import 'package:posventa/presentation/pages/inventory/inventory_audit_mobile_page.dart';

class InventoryAuditPage extends StatelessWidget {
  const InventoryAuditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return const InventoryAuditDesktopPage();
        } else {
          return const InventoryAuditMobilePage();
        }
      },
    );
  }
}
