import 'package:flutter/material.dart';
import 'package:softhack/pages/RegistrationPage.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(45.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(
              size: 120,
            ),
            const SizedBox(height: 35),

            //email
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBox(height: 16),

            //password
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 32),

            //button

            ElevatedButton(
              onPressed: () {
                print('Logged in');
              },
              child: const Text('Login'),
            ),

            const SizedBox(height: 32),

            //registration gateway
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              child: const Text(
                "Don't have an account? Register here.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            //will openin new page
          ],
        ),
      ),
    );
  }
}
