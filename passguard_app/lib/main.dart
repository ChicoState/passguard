import 'package:flutter/material.dart';
//import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'screens/introduction_screen.dart';

void main(){
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp(
//    options: DefaultFirebaseOptions.currentPlatform,
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PassGuard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IntroductionScreen(),
    );
  }
}

