// test/mocks/mocks.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';

import 'mocks.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference<Map<String, dynamic>>, // Use the correct generic type
  DocumentReference<Map<String, dynamic>>,  // Use the correct generic type
  DocumentSnapshot<Map<String, dynamic>>,  // Use the correct generic type
])
void main() {}
