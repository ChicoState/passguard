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
     TextEditingController _hostNameController =
         TextEditingController(text: doc.id);
     TextEditingController _usernameController =
         TextEditingController(text: doc['username']);
     TextEditingController _passwordController =
         TextEditingController(text: doc['password']);
 
     showDialog(
       context: context,
       builder: (context) {
         bool _obscurePassword = true;
         return StatefulBuilder(
           builder: (context, setState) {
             return AlertDialog(
               title: const Text('Edit Account'),
               content: SingleChildScrollView(
                 child: Column(
                   children: [
                     TextField(
                       controller: _hostNameController,
                       decoration:
                           const InputDecoration(labelText: 'Host Name'),
                       readOnly: true,
                     ),
                     TextField(
                       controller: _usernameController,
                       decoration: const InputDecoration(
                           labelText: 'Username (optional)'),
                     ),
                     TextField(
                       controller: _passwordController,
                       obscureText: _obscurePassword,
                       decoration: InputDecoration(
                         labelText: 'Password',
                         suffixIcon: IconButton(
                           icon: Icon(_obscurePassword
                               ? Icons.visibility_off
                               : Icons.visibility),
                           onPressed: () {
                             setState(() {
                               _obscurePassword = !_obscurePassword;
                             });
                           },
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
               actions: [
                 TextButton(
                   onPressed: () {
                     Navigator.of(context).pop();
                   },
                   child: const Text('Cancel'),
                 ),
                 // Delete button in red
                 TextButton(
                   onPressed: () async {
                     await FirebaseFirestore.instance
                         .collection('users')
                         .doc(widget.userId)
                         .collection('accounts')
                         .doc(doc.id)
                         .delete();
                     Navigator.of(context).pop();
                   },
                   child: const Text(
                     'Delete',
                     style: TextStyle(color: Colors.red),
                   ),
                 ),
                 ElevatedButton(
                   onPressed: () async {
                     String hostName = _hostNameController.text.trim();
                     String username = _usernameController.text.trim();
                     String password = _passwordController.text.trim();
                     if (hostName.isNotEmpty && password.isNotEmpty) {
                       // Update via the service function.
                       await uploadPass(username, password, hostName);
                       Navigator.of(context).pop();
                     }
                   },
                   child: const Text('Update'),
                 ),
               ],
             );
           },
         );
       },
     );
   }
}
