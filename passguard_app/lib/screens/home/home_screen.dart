import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/upload_retrieve.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/stats_card_row.dart';
import 'widgets/accounts_list.dart';
import 'widgets/add_account_dialog.dart';
import 'package:passguard_app/theme.dart';
import 'widgets/passgen.dart';
import 'package:passguard_app/screens/passwordchecker.dart';
class HomeScreen extends StatefulWidget {
  final String userId;
  final String accPassword;
  final enc.Key encryptionKey;
  final Uint8List iv;

  const HomeScreen({Key? key, required this.userId, required this.accPassword, required this.encryptionKey, required this.iv}) : super(key: key);
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Searching Query variable, default ('') displays all accounts
  String _searchQuery = '';

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
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardHeader(userId: widget.userId),
                              Padding(
                                padding: const EdgeInsets.only(top: kDefaultPadding),
                                child: StatsCardRow(userId: widget.userId),
                              ),
                              const SizedBox(height: kDefaultPadding),
                              const PassGen(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              //right side (accounts + add button)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                        child: Row(
                        children: [
                          //the _checkAll button
                          SizedBox(
                            height: 45,
                            width: 80,
                            child: ElevatedButton(
                              onPressed: _checkAll,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:const Color.fromARGB(255, 37, 99, 214),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(Icons.shield, color:Colors.white, size: 25,), 
                            ),
                            
                          ), 

                          //Search Filtering:
                          Expanded(flex: 1, child: const SizedBox(width:0)), //space between the searchbar and button
                            Expanded(
                              flex:20,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                                decoration: InputDecoration(
                                  hintText: 'Search accounts...',
                                  prefixIcon: Icon(Icons.search),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  
                      //List of Accounts:
                      Expanded(
                        child: AccountsList(
                          accountsStream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.userId)
                              .collection('accounts')
                              .snapshots(),
                          onEdit: (doc) => _showEditAccountDialog(doc),
                          accPass: widget.accPassword,
                          encryptionKey: widget.encryptionKey,
                          iv: widget.iv,

                          searchQuery: _searchQuery,
                        ),
                      ),
                      //space between add and list
                      SizedBox(height: 10),
                      //Add button
                      FloatingActionButton.extended(
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

                      //spacer from bottom of box
                      SizedBox(height: 15), //size 30 to match top of page
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
  void _checkAll() async {
  final accountsSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.userId)
      .collection('accounts')
      .get();

  List<String> compromisedHosts = [];

  for (var doc in accountsSnapshot.docs) {
    final data = doc.data();
    final password = data['password'];
    final host = doc.id;

    // Only check and update if it's not already marked as compromised
    if (password != null && !(data['isCompromised'] == true)) {
      bool isCompromised = await PasswordChecker.checkPasswordLeak(password);
      if (isCompromised) {
        await doc.reference.update({'isCompromised': true});
        compromisedHosts.add(host);
      }
    }
  }

  if (!mounted) return;

  if (compromisedHosts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No compromised passwords found.')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${compromisedHosts.length} compromised password(s) found. Cards updated.'),
      ),
    );
  }
}
  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAccountDialog(
        onSave: (hostName, username, password, email) async {
          uploadPass(username, password, hostName, widget.accPassword, widget.encryptionKey, widget.iv, email);
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
        TextEditingController(text: decrypt(widget.accPassword, doc['password']  ?? '', widget.encryptionKey, widget.iv));
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
                      uploadPass(username, password, hostName,widget.accPassword, widget.encryptionKey, widget.iv, email);
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