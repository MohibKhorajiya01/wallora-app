import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2)); // Minimum splash duration

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        bool isAdmin = false;
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('isAdmin')) {
            isAdmin = data['isAdmin'] == true;
          }
        }

        if (!mounted) return;

        if (isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (!user.emailVerified) {
          Navigator.pushReplacementNamed(context, '/verify');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) Navigator.pushReplacementNamed(context, '/home'); // Guest users go to Home
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black, // Dark theme match karne ke liye
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo ya App Name
            Text(
              "WALLORA",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 5,
              ),
            ),
            SizedBox(height: 20),

            Text(
              "CURATED AESTHETIC",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w100,
                color: Colors.white54,
                letterSpacing: 6,
              ),
            ),

          ],
        ),
      ),
    );
  }
}