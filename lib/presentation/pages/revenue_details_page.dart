import 'package:flutter/material.dart';
import 'package:myapp/presentation/pages/home_page.dart';

class RevenueDetailsScreen extends StatelessWidget {
  const RevenueDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePage(child: Center(child: Text('Revenue Details')));
  }
}
