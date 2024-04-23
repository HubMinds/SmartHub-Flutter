import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:logger/logger.dart';
 
 // Register Section

var logger = Logger();

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = 0.0;
    const end = 1.0;
    const curve = Curves.easeInOut;

    var tween =
        Tween<double>(begin: begin, end: end).chain(CurveTween(curve: curve));

    var fadeAnimation = animation.drive(tween);

    return FadeTransition(opacity: fadeAnimation, child: child);
  }
}

var db = FirebaseFirestore.instance;

class RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController newEmailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController _passwordCheck = TextEditingController();
  final TextEditingController _goal = TextEditingController();

  bool login = false;
  bool passCheck = false;
  bool pass = false;
  bool email = false;
  bool value = false;

  

  Future<void> _createUser() async {
    // Check for empty fields
    if (newEmailController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        _passwordCheck.text.isEmpty ||
        _goal.text.isEmpty) {
      email = true;
      pass = true;
      passCheck = true;
      value = true;
      setState(() {});
      // Display an error message or handle the case where fields are empty.
      return;
    }

    // Check for password match
    if (newPasswordController.text != _passwordCheck.text) {
      passCheck = true;
      setState(() {});
      return;
    }

    // Validate email and password format
    // Add more sophisticated validation as needed

    try {
      UserCredential newUser = await _auth.createUserWithEmailAndPassword(
        email: newEmailController.text,
        password: newPasswordController.text,
      );

      logger.i("User signed in: ${newUser.user!.uid}");
      String user = newUser.user!.uid;

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(uid: user)),
        );
      }

      newEmailController.clear();
      newPasswordController.clear();
      _passwordCheck.clear();
      _goal.clear();
    } catch (e) {
      logger.i("Failed to sign in: $e");
      // Handle the error, e.g., show a snackbar or display an error message
      email = true;
      pass = true;
      value = true;
      newEmailController.clear();
      newPasswordController.clear();
      _passwordCheck.clear();
      _goal.clear();
      setState(() {});
    }
  }
              
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Register',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        fontSize: 34,
                        fontFamily: 'helvetica',
                        color: Color(0xffffffff),
                      ),
                    ),
                    TextFormField(
                      controller: newEmailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: email ? "Email must be in abc@def.com format" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: pass ? "Password must be at least 6 characters" : null,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      controller: _passwordCheck,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        filled: true,
                        fillColor: Colors.white,
                        errorText: passCheck ? "Passwords do not match" : null,
                      ),
                    ),

                    SizedBox(height: 32.0),
                    ElevatedButton(
                      onPressed: _createUser,
                      child: Text('Register'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 