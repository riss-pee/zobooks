import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DigiBuks'),
      ),
      body: const Center(
        child: Text('Home View - To be implemented'),
      ),
    );
  }
}

