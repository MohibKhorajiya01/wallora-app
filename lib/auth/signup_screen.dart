import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(width: 15),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "WALLORA",
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 50),

                    CustomTextField(
                      controller: _nameController,
                      label: "FULL NAME",
                      hint: "Enter your name",
                      icon: Icons.person_outline_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _emailController,
                      label: "EMAIL ADDRESS",
                      hint: "Enter your email",
                      icon: Icons.alternate_email_rounded,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required";
                        if (!value.contains('@')) return "Invalid format";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    CustomTextField(
                      controller: _passwordController,
                      label: "PASSWORD",
                      hint: "Enter your password",
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Required";
                        if (value.length < 6) return "Min 6 chars";
                        return null;
                      },
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _handleSignup,
                        child: const Text(
                          "REGISTER",
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account? ", style: TextStyle(color: Colors.white54)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        await userCredential.user!.updateDisplayName(_nameController.text.trim());
        await userCredential.user!.sendEmailVerification();
        
        if (mounted) {
          Navigator.pop(context); // Close loading
          Navigator.pushReplacementNamed(context, '/verify');
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) Navigator.pop(context);
        debugPrint("FirebaseAuthException during signup: ${e.code}");
        String errorMessage = "An error occurred";
        if (e.code == 'email-already-in-use') errorMessage = "Email already registered";
        else if (e.code == 'weak-password') errorMessage = "Password is too weak";
        
        SnackBarUtils.showMsg(context, errorMessage, isError: true);
      } catch (e) {
        if (mounted) Navigator.pop(context);
        debugPrint("Unknown error during signup: $e");
        SnackBarUtils.showMsg(context, "An unexpected error occurred.", isError: true);
      }
    }
  }
}
