import 'package:flutter/material.dart';
import 'package:passguard_app/passwordchecker.dart';


TextEditingController mycontroller = TextEditingController();
bool pwned = false;
class PasswordCheckScreen extends StatefulWidget {
  PasswordCheckScreen({super.key});

  @override
  _PasswordCheckScreenState createState() => _PasswordCheckScreenState();
}

class _PasswordCheckScreenState extends State<PasswordCheckScreen> {
void _check () async {
  bool x;
  x = await checkPasswordPwned(mycontroller.text);
  setState(() {
        pwned = x;
      });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Password Leak')),
      body: Column(
        children: [
          Text('$pwned'),
          const SizedBox(height:300),
          TextField(
            controller: mycontroller,
          ),
          FilledButton(onPressed: _check, child: Text('Check')),
        ],
      ),
      
    );
  }
}
