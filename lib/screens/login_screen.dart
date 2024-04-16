import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:logger/logger.dart';

var logger = Logger();

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
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

class LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

      FirebaseFirestore.instance.collection('users').doc(user).set({
        'goal(current)': int.parse(_goal.text),
        'Expense': [],
        'expense(index)': [],
        'expense(value)': [],
        'Income': [],
        'Income(Value)': [],
        'Income(index)': [],
      });

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

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      logger.i("User signed in: ${userCredential.user!.uid}");
      String user = userCredential.user!.uid;

      // Reset the login variable to false
      setState(() {
        login = false;
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(uid: user)),
        );
      }
      // Navigate to the next screen or perform other actions after successful login
    } catch (e) {
      logger.i("Failed to sign in: $e");
      login = true;
      _passwordController.clear();
      setState(() {});
      // Handle the error, e.g., show a snackbar or display an error message
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Temp logo for now
              const FlutterLogo(size: 100.0),
              const SizedBox(height: 50.0),
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  errorText: login ? 'not a valid email or password' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  filled: true,
                  fillColor: Colors.white,
                  errorText: login ? 'incorrect password or email' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: const LinearGradient(
                    colors: [Color(0xff667eea), Color(0xff764ba2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      )),
                  onPressed: _signIn,
                  child: const Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
