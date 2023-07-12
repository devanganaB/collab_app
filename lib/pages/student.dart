import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'CreatePostPage.dart';
import 'LoginPage.dart';
import 'package:softhack/widgets/cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Student extends StatefulWidget {
  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Action for profile button
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
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
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _projectsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var project = snapshot.data!.docs[index];

              // return GestureDetector(
              return Container(
                height: 150,
                padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: Card(
                  semanticContainer: true,
                  color: Colors.blue, // Set the desired color for the card
                  elevation: 2, // Set the desired elevation for the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Set the desired border radius for the card
                  ),
                  // Set the desired padding for the card content

                  child: ListTile(
                    title: Text(project['title']),
                    subtitle: Text(project['description']),
                    // Add more fields from the document as needed
                    onTap: () {
                      _showProjectDetailsDialog(context, project);
                    },
                  ),
                ),
              );

              // onTap: () {
              //   showDialog(
              //     context: context,
              //     builder: (BuildContext context) {
              //       return AlertDialog(
              //         title: Text(project['title']),
              //         content: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Text('Domain: ${project['domain']}'),
              //             Text('Description: ${project['description']}'),
              //             Text('Skills: ${project['skills']}'),
              //           ],
              //         ),
              //         actions: [
              //           TextButton(
              //             onPressed: () {
              //               Navigator.of(context).pop();
              //             },
              //             child: Text('Close'),
              //           ),
              //         ],
              //       );
              //     },
              //   );
              // },

              // end of display
              // );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  // Action for home button
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                // Action for chat button
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  void _showProjectDetailsDialog(
      BuildContext context, DocumentSnapshot project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(project['title']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: '),
              // Text('Skills: ${project['skills']}'),
              // Text('Domain: ${project['domain']}'),
              // Add more fields from the document as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
