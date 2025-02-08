

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider for FirebaseAuth
final authProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider to get the current user
final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.currentUser;
});

// Provider to handle authentication state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authProvider);
  return auth.authStateChanges();
});
