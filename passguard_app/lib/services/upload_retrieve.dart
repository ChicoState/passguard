import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> uploadPass(String encUsername, String encPass, String hostName, [String? email]) async {
  String uid = (FirebaseAuth.instance.currentUser?.uid ?? 'nullUser');
  if (uid != 'nullUser'){
    FirebaseFirestore.instance.collection("users").doc(uid).collection("accounts").doc(hostName).set({
      'username': encUsername,
      'password': encPass,      
      'email': email ?? '', // Optional email

    });
  }
  
}

Future<MapEntry<String, String>> retrievePass(String hostName) async {
  String uid = (FirebaseAuth.instance.currentUser?.uid ?? 'nullUser');
  if (uid != 'nullUser'){
    DocumentSnapshot docSnap = await FirebaseFirestore.instance.collection("users").doc(uid).collection("accounts").doc(hostName).get();
    if (docSnap.exists){
      Map<String, dynamic>? data = docSnap.data() as Map<String, dynamic>?;
      if(data != null){
        return MapEntry(data['username'], data['password']);
      }
    }
  }
  return MapEntry('not found', 'not found');
}