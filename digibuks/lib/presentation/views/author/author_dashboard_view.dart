import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthorDashboardView extends StatelessWidget {
  const AuthorDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Author Dashboard'),
      ),
      body: const Center(
        child: Text('Author Dashboard View - To be implemented'),
      ),
    );
  }
}

