import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
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
      backgroundColor: Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        title: const Text('Registration'),
        backgroundColor: Colors.grey[350],
      ),
      body: Padding(
        padding: const EdgeInsets.all(45.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              //Role
              Container(
                width: double.infinity,
                child: DropdownButtonFormField<String>(
                  value: _selectedClass,
                  onChanged: (value) {
                    setState(() {
                      _selectedClass = value;
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
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),

              SizedBox(height: 25),

              //email
              TextField(
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 25),

              //contact
              TextField(
                onChanged: (value) {
                  setState(() {
                    _contactNumber = value;
                  });
                },
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 25),

              //github
              TextField(
                onChanged: (value) {
                  setState(() {
                    _githubProfile = value;
                  });
                },
                decoration: InputDecoration(labelText: 'GitHub Profile'),
              ),

              SizedBox(height: 25),

              //password
              TextField(
                onChanged: (value) {
                  setState(() {
                    _password = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
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
                  },
                  child: const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
