import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  const HomeScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: Text('Welcome! Your userId is $userId'),
      ),
    );
  }
}
