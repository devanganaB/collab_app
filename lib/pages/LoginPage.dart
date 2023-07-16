import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student.dart';
import 'teacher.dart';
import 'RegistrationPage.dart';
import 'ChatPage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscure3 = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  bool isTextFieldEmpty = true;

  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[600],
      ),
      body: Padding(
        padding: const EdgeInsets.all(45.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Welcome back you've been missed"),
                const SizedBox(height: 32),

                //LOGO
                Container(
                  width: 300,
                  height: 300,
                  child: Image.asset('assets/images/logo.jpg'),
                ),

                const SizedBox(height: 15),

                //EMAIL
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    setState(() {
                      isTextFieldEmpty = value.isEmpty;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter Email',
                  ),
                ),

                const SizedBox(height: 16),

                //PASSWRD
                TextField(
                  controller: passwordController,
                  onChanged: (value) {
                    setState(() {
                      isTextFieldEmpty = value.isEmpty;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                //button

                ElevatedButton(
                  onPressed: () {
                    print('Logged in');
                    signIn(emailController.text, passwordController.text);
                  },
                  child: const Text('Login'),
                ),

                const SizedBox(height: 32),

                //registration gateway
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegistrationPage()),
                    );
                  },
                  child: const Text(
                    "Don't have an account? Register here.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                //will open in new page
              ],
            ),
          ),
        ),
      ),
    );
  }

  void route() {
    User? user = FirebaseAuth.instance.currentUser;
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('role') == "Mentor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Teacher(),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Student(),
            ),
          );
        }
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  void signIn(String email, String password) async {
    if (_formkey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        route();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
    }
  }
}
