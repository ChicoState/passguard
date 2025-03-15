// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/upload_retrieve.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/stats_card_row.dart';
import 'widgets/accounts_list.dart';
import 'widgets/add_account_dialog.dart';
import 'package:passguard_app/theme.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1)header
            DashboardHeader(userId: widget.userId),

            // 2)stats row (now real-time via StreamBuilder inside StatsCardRow)
            Padding(
              padding: const EdgeInsets.all(kDefaultPadding),
              child: StatsCardRow(userId: widget.userId),
            ),

            // 3)list of accounts
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: AccountsList(
                  accountsStream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('accounts')
                      .snapshots(),
                  onEdit: (doc) => _showEditAccountDialog(doc),
                ),
              ),
            ),
          ],
        ),
      ),

      //only "Add Account" button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
        onPressed: _showAddAccountDialog,
      ),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAccountDialog(
        onSave: (hostName, username, password) async {
          await uploadPass(username, password, hostName);
        },
      ),
    );
  }

  void _showEditAccountDialog(DocumentSnapshot doc) {
    //
  }
}
