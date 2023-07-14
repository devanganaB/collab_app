import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case where the user is not signed in
      return Drawer();
    }

    return Drawer(
      child: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While the document is being fetched, show a loading indicator
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            // Handle any errors that occurred while fetching the document
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Handle the case where the user document does not exist
            return Drawer();
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;
          var name = userData['name'] as String;
          var email = userData['email'] as String;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(name),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/pp.jpg',
                      fit: BoxFit.cover,
                      height: double.infinity,
                      width: double.infinity,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[300],
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ListTile(
                title: Text('Menu Item 1'),
                onTap: () {
                  // Action for menu item 1
                },
              ),
              ListTile(
                title: Text('Menu Item 2'),
                onTap: () {
                  // Action for menu item 2
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
