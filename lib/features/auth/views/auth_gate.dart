import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
// TODO: Import your Main App Screen or Home Screen here
// import '../../properties/views/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show a loading indicator while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // If the user is logged in, send them to the Home Screen
          if (snapshot.hasData) {
            // Replace with your actual home screen widget
            return const Center(child: Text('Home Screen (Replace me)')); 
          }

          // Otherwise, show the Login Screen
          return const LoginScreen();
        },
      ),
    );
  }
}