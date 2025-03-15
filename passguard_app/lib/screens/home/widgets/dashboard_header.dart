// lib/screens/home/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:passguard_app/theme.dart';

class DashboardHeader extends StatelessWidget {
  final String userId;

  const DashboardHeader({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: kDefaultPadding * 2,
        horizontal: kDefaultPadding,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, Color(0xFF4DB8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your userId is $userId",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

