// lib/screens/home/widgets/accounts_list.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passguard_app/theme.dart';
import 'account_card.dart';

class AccountsList extends StatelessWidget {
  final Stream<QuerySnapshot> accountsStream;
  final Function(DocumentSnapshot doc) onEdit;
  final String accPass;

  const AccountsList({
    Key? key,
    required this.accountsStream,
    required this.onEdit,
    required this.accPass,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: accountsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'No accounts added yet.',
              style: TextStyle(color: kTextColor),
            ),
          );
        }
        return ListView(
          children: snapshot.data!.docs.map((doc) {
            return AccountCard(
              doc: doc,
              onEdit: () => onEdit(doc),
              accPass: accPass,
            );
          }).toList(),
        );
      },
    );
  }
}

