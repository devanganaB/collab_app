import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'LoginPage.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  _RegistrationPageState();

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController name = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController contactController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController githubProfileController =
      new TextEditingController();
  List<String> acceptedProjects = [];

  String _name = '';
  String _contactNumber = '';
  String _email = '';
  String _githubProfile = '';
  String _password = '';
  String? _selectedClass;
  bool _showPassword = false;

  List<String> _classOptions = ['Student', 'Mentor'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registration',
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
              children: [
                //Role
                Container(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    value: _selectedClass,
                    onChanged: (value) {
                      setState(() {
                        _selectedClass = value!;
                      });
                    },
                    items: _classOptions
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(labelText: 'Role'),
                  ),
                ),

                SizedBox(height: 25),

                //name
                TextField(
                  controller: name,
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Name', hintText: 'Enter your name'),
                ),

                SizedBox(height: 25),

                //email
                TextField(
                  controller: emailController,
                  onChanged: (value) {
                    setState(() {
                      _email = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Email', hintText: 'Enter your email'),
                  keyboardType: TextInputType.emailAddress,
                ),

                SizedBox(height: 25),

                //contact
                TextFormField(
                  controller: contactController,
                  onChanged: (value) {
                    setState(() {
                      _contactNumber = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'Contact', hintText: 'Enter Contact number'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Only allow digits
                  ],
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter your contact number';
                    }

                    return null;
                  },
                ),

                SizedBox(height: 25),

                //github
                TextField(
                  controller: githubProfileController,
                  onChanged: (value) {
                    setState(() {
                      _githubProfile = value;
                    });
                  },
                  decoration: InputDecoration(
                      labelText: 'GitHub Profile', hintText: 'Profile Link'),
                ),

                SizedBox(height: 25),

                //password
                TextField(
                  controller: passwordController,
                  onChanged: (value) {
                    setState(() {
                      _password = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter password',
                    suffixIcon: IconButton(
                      color: const Color.fromARGB(255, 14, 28, 107),
                      icon: Icon(_showPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !_showPassword,
                ),

                SizedBox(height: 35),

                //Button

                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      print('registered');
                      signUp(emailController.text, passwordController.text,
                          _selectedClass!);
                    },
                    child: const Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUp(String email, String password, String role) async {
    CircularProgressIndicator();
    if (_formkey.currentState != null && _formkey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore(email, role)})
          .catchError((e) {
        print(e);
      });
    }
  }

  postDetailsToFirestore(String email, String role) async {
    if (_auth.currentUser != null) {
      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      var user = _auth.currentUser;
      CollectionReference ref = FirebaseFirestore.instance.collection('users');
      await ref.doc(user!.uid).set({
        'name': _name,
        'email': email,
        'role': role,
        'contactNumber': _contactNumber,
        'githubProfile': _githubProfile,
        'acceptedProjects': acceptedProjects
      });
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
