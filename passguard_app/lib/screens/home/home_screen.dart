import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/upload_retrieve.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/stats_card_row.dart';
import 'widgets/accounts_list.dart';
import 'widgets/add_account_dialog.dart';
import 'package:passguard_app/theme.dart';
import 'widgets/passgen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String accPassword;

  const HomeScreen({Key? key, required this.userId, required this.accPassword}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bgDashPass.png'), //bgDashPass.png 
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              //left side (header + stats)
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DashboardHeader(userId: widget.userId),
                        Padding(
                          padding: const EdgeInsets.only(top: kDefaultPadding),
                          child: StatsCardRow(userId: widget.userId),
                        ),
                        // Password Generator Box
                        const SizedBox(height: kDefaultPadding),
                        const PassGen(),
                      ],
                    ),
                  ),
                ),
              ),
              //right side (accounts + add button)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  child: Column(
                    children: [
                      Expanded(
                        child: AccountsList(
                          accountsStream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userId)
                              .collection('accounts')
                              .snapshots(),
                          onEdit: (doc) => _showEditAccountDialog(doc),
                          accPass: widget.accPassword,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: FloatingActionButton.extended(
                          backgroundColor: const Color.fromARGB(255, 37, 99, 214),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                              'Add Account',
                              style: TextStyle(color: Colors.white), 
                          ), 
                          hoverColor: Color(0xFF4DB8FF),
                          // colors: [kPrimaryColor, Color(0xFF4DB8FF)],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),

                          heroTag: 'addAccountButton',
                          onPressed: _showAddAccountDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAccountDialog(
        onSave: (hostName, username, password, email) async {
          uploadPass(username, password, hostName, widget.accPassword, email);
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
    TextEditingController _emailController =
      TextEditingController(text: doc.data().toString().contains('email') ? doc['email'] : '');

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
                      controller: _emailController,
                      decoration:
                          const InputDecoration(labelText: 'Email (optional)'),
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
                    String email = _emailController.text.trim();
                    if (hostName.isNotEmpty && password.isNotEmpty) {
                      uploadPass(username, password, hostName, email);
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