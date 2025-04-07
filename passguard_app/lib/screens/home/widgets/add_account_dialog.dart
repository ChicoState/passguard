// lib/screens/home/widgets/add_account_dialog.dart
import 'package:flutter/material.dart';
import 'package:passguard_app/theme.dart';

class AddAccountDialog extends StatefulWidget {
  final Function(String hostName, String username, String password, String email) onSave;


  const AddAccountDialog({
    Key? key,
    required this.onSave,
  }) : super(key: key);

  @override
  State<AddAccountDialog> createState() => _AddAccountDialogState();
}

class _AddAccountDialogState extends State<AddAccountDialog> {
  final _hostNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();


  bool _obscurePassword = true;
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: kCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: const Text(
        'Add Account',
        style: TextStyle(color: kTextColor),
      ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _buildTextField(_hostNameController, 'Host Name', false),
            const SizedBox(height: 8),
            _buildTextField(_usernameController, 'Username (optional)', false),
            const SizedBox(height: 8),
            _buildTextField(_emailController, 'Email (optional)', false),
            const SizedBox(height: 8),
            _buildTextField(_passwordController, 'Password', true),
           

            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: kPrimaryColor)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
          onPressed: () {
            String hostName = _hostNameController.text.trim();
            String username = _usernameController.text.trim();
            String password = _passwordController.text.trim();
            String email = _emailController.text.trim(); // 👈_

            if (hostName.isEmpty || password.isEmpty) {
              setState(() {
                _errorMessage = 'Host Name and Password are required.';
              });
              return;
            }
            widget.onSave(hostName, username, password, email);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: kTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: kPrimaryColor),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              )
            : null,
      ),
    );
  }
}

