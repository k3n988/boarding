import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Gawin nating static/final ang instance para iisa lang ang ginagamit sa buong app
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔹 Register a new user
  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      final user = UserModel(
        id: uid, // Tiyakin na 'id' ang gamit sa model mo
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        role: role,
      );

      await _firestore.collection('users').doc(uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Registration failed');
    }
  }

  // 🔹 Login user (Email/Password)
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final snapshot = await _firestore.collection('users').doc(uid).get();

      if (!snapshot.exists) {
        throw Exception('User data not found.');
      }

      return UserModel.fromMap(snapshot.data()!, snapshot.id);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Login failed');
    }
  }

  // 🔹 Google Sign-In Method
  Future<UserModel?> loginWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled the picker
      }

      // 2. Get Auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create Firebase Credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Failed to sign in with Google.');
      }

      // 5. Check Firestore
      final snapshot = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (snapshot.exists) {
        return UserModel.fromMap(snapshot.data()!, snapshot.id);
      } else {
        // First time login: Split name and save to Firestore
        List<String> nameParts = (firebaseUser.displayName ?? 'Google User').split(' ');
        String firstName = nameParts.first;
        String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

        final newUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          firstName: firstName,
          lastName: lastName,
          phoneNumber: firebaseUser.phoneNumber ?? '',
          role: 'student', // Default role
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(newUser.toMap());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Firebase Google Sign-In failed');
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  // 🔹 Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    if (!snapshot.exists) return null;

    return UserModel.fromMap(snapshot.data()!, snapshot.id);
  }

  // 🔹 Logout
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}