import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passguard_app/screens/passwordcheck_screen.dart';
import 'package:passguard_app/services/upload_retrieve.dart';

class HomeScreen extends StatefulWidget {
  final String userId;

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dialog to add a new account
  void _showAddAccountDialog() {
  TextEditingController _hostNameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      bool _obscurePassword = true;
      String _errorMessage = '';
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Account'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _hostNameController,
                    decoration:
                        const InputDecoration(labelText: 'Host Name'),
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
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _errorMessage,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 12),
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
              ElevatedButton(
                onPressed: () async {
                  String hostName = _hostNameController.text.trim();
                  String username = _usernameController.text.trim();
                  String password = _passwordController.text.trim();
                  if (hostName.isEmpty || password.isEmpty) {
                    setState(() {
                      _errorMessage =
                          'Host Name and Password are required.';
                    });
                    return;
                  }
                  await uploadPass(username, password, hostName);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

  // Dialog to edit an existing account (includes Delete option)
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
                    await _firestore
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Using a Column to include both the title and a welcome message.
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Home Screen"),
            Text(
              "Welcome! Your userId is ${widget.userId}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(widget.userId)
            .collection('accounts')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No accounts added yet.'));
          }

          // Debug: print the documents received.
          // print("Fetched documents: ${snapshot.data!.docs.map((doc) => doc.data())}");

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: AccountCard(
                  doc: doc,
                  onEdit: () {
                    _showEditAccountDialog(doc);
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Positions FABs at both edges
        children: [
          // Password Check Button (Bottom Left)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 0.0), 
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PasswordCheckScreen()),
                );
              },
              heroTag: 'password_check_fab',
              tooltip: 'Check Password Leak', // Unique tag to prevent conflicts
              child: const Icon(Icons.security),
            ),
          ),

          // Spacer to push add button to the right
          const Spacer(),

          // Add Account Button (Bottom Right)
          Padding(
            padding: const EdgeInsets.only(right: 16.0, bottom: 0.0),
            child: FloatingActionButton(
              onPressed: _showAddAccountDialog,
              heroTag: 'add_account_fab', // Unique tag to prevent conflicts
              tooltip: 'Add Account',
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),

    );
  }
}

// New stateful widget for account cards with password visibility toggle.
class AccountCard extends StatefulWidget {
  final DocumentSnapshot doc;
  final VoidCallback onEdit;

  const AccountCard({Key? key, required this.doc, required this.onEdit})
      : super(key: key);

  @override
  _AccountCardState createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    String password = widget.doc['password'];
    String obscuredPassword = '•' * password.length; // simple obfuscation
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ExpansionTile(
        title: Text(
          widget.doc.id, // using the host name as the document ID
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: [
          ListTile(
            title: Text('Password: ${_showPassword ? password : obscuredPassword}'),
            subtitle: (widget.doc['username'] != null &&
                    widget.doc['username'].toString().isNotEmpty)
                ? Text('Username: ${widget.doc['username']}')
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show Password
                IconButton(
                  icon: Icon(
                      _showPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                // Copy Password
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: password));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password copied to clipboard'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                // Edit Password
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: widget.onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}