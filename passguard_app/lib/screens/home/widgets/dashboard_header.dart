// lib/screens/home/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:passguard_app/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardHeader extends StatefulWidget {
  final String userId;

  const DashboardHeader({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    if (doc.exists) {
      setState(() {
        userName = doc['name'] ?? '';
      });
    }
  }

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
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            userName.isNotEmpty ? 'Hello, $userName' : '',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}


