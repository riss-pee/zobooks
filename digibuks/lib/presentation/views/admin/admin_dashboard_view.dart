import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: const Center(
        child: Text('Admin Dashboard View - To be implemented'),
      ),
    );
  }
}

