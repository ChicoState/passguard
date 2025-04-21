import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'forgotpass_screen.dart';
import 'signup_screen.dart';
import 'package:passguard_app/screens/home/home_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Email and password are required';
      });
      return;
    }

    //sign-in --- we'll have to implement it on sign in screen 
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Navigator.push(      //HomeScreen on successful login
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userId: userCredential.user!.uid, accPassword: password),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Incorrect email or password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //bckground Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/loginBg.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          //logo at the Top Left Corner
          Positioned(
            top: 40, 
            left: 20, 
            child: Image.asset(
              'assets/logo.png',
              width: 80, 
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  //email field
                  Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //password field
                  Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_errorMessage.isNotEmpty)                  //eerror Message
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  //log in button
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(222, 19, 162, 238),
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Log in'),
                  ),
                  const SizedBox(height: 20),
                  //forgot password button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  //sign up button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
