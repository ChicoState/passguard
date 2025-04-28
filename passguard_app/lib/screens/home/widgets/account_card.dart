// lib/screens/home/widgets/account_card.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:passguard_app/theme.dart';
import 'package:passguard_app/screens/passwordchecker.dart';
import 'package:url_launcher/url_launcher.dart';



class AccountCard extends StatefulWidget {
  final DocumentSnapshot doc;
  final VoidCallback onEdit;

  const AccountCard({
    Key? key,
    required this.doc,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _showPassword = false;
  bool _isCheckingLeak = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final String password = data['password'] ?? '';
    final String username = data['username'] ?? '';
    final String email = data['email'] ?? '';

    final bool isCompromised = data['isCompromised'] == true; //optional
    final String hostName = widget.doc.id;

    final obscuredPassword = '•' * password.length;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ExpansionTile(
        iconColor: kPrimaryColor,
        collapsedIconColor: kPrimaryColor,
        title: Row(
          children: [
            Expanded(
              child: Text(
                hostName,
                style: const TextStyle(
                  color: kTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isCompromised)
              const Icon(Icons.warning_amber, color: Colors.redAccent),
          ],
        ),
        children: [
          ListTile(
            title: Text(
              "Password: ${_showPassword ? password : obscuredPassword}",
              style: const TextStyle(color: kTextColor),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (username.isNotEmpty)
                  Text(
                    "Username: $username",
                    style: const TextStyle(color: Colors.grey),
                  ),
                if (email.isNotEmpty)
                  Text(
                    "Email: $email",
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //check Leak
                IconButton(
                  icon: Icon(
                    Icons.security,
                    color: _isCheckingLeak ? Colors.grey : kPrimaryColor,
                  ),
                  onPressed: _isCheckingLeak ? null : () => _checkLeak(password),
                  tooltip: 'Check Leak',
                ),

                //view/hide password
                IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: kPrimaryColor,
                  ),
                  onPressed: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                ),
                //Go to hostname URL button
                IconButton(
                  icon: const Icon(Icons.open_in_browser, color: kPrimaryColor),
                  tooltip: 'Open Website',
                  onPressed: () async {
                    String formattedHost = hostName.trim();

                    // Add 'https://' if missing
                    if (!formattedHost.startsWith('http')) {
                      formattedHost = 'https://' + formattedHost;
                    }

                    // Add 'www.' if missing after protocol
                    Uri uri = Uri.parse(formattedHost);
                    if (uri.host.split('.').length == 2) {
                      formattedHost = uri.scheme + '://www.' + uri.host + (uri.hasPort ? ':${uri.port}' : '') + uri.path;
                      uri = Uri.parse(formattedHost);
                    }

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open website')),
                      );
                    }
                  },

                ),
                //copy
                IconButton(
                  icon: Icon(Icons.copy, color: kPrimaryColor),
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
                
                //edit
                IconButton(
                  icon: Icon(Icons.edit, color: kPrimaryColor),
                  onPressed: widget.onEdit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkLeak(String password) async {
    setState(() => _isCheckingLeak = true);

    try {
      await Future.delayed(const Duration(seconds: 1)); 
      final bool leaked = await PasswordChecker.checkPasswordLeak(password);

      //show user a snack or update Firestore:
      if (leaked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password found in a leak!')),
        );
        await widget.doc.reference.update({'isCompromised': true});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No leaks found for this password.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking leak: $e')),
      );
    } finally {
      setState(() => _isCheckingLeak = false);
    }
  }
}
