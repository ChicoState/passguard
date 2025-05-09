// lib/screens/home/widgets/accounts_list.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passguard_app/theme.dart';
import 'account_card.dart';
import 'package:encrypt/encrypt.dart' as enc;

class AccountsList extends StatelessWidget {
  final Stream<QuerySnapshot> accountsStream;
  final Function(DocumentSnapshot doc) onEdit;
  final String accPass;
  final enc.Key encryptionKey;
  final Uint8List iv;
  final String searchQuery;

  const AccountsList({
    Key? key,
    required this.accountsStream,
    required this.onEdit,
    required this.accPass,
    required this.encryptionKey,
    required this.iv,
    required this.searchQuery,
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
        
        //filtering:
        final docs = snapshot.data!.docs.where((doc) {
          final host = doc.id.toLowerCase(); // hostName
          return host.contains(searchQuery); // match against search query
        }).toList();

        return ListView(
          children: docs.map((doc) {
            return AccountCard(
              doc: doc,
              onEdit: () => onEdit(doc),
              accPass: accPass,
              encryptionKey: encryptionKey,
              iv: iv
            );
          }).toList(),
        );

      },
    );
  }
}

