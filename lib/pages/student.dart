import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ChatPage.dart';
import 'CreatePostPage.dart';
import 'LoginPage.dart';
import 'package:softhack/widgets/cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softhack/widgets/mentorname.dart';
import 'package:dotted_line/dotted_line.dart';

class Student extends StatefulWidget {
  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  final _auth = FirebaseAuth.instance;
  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), //LOGOUT
            onPressed: () {
              logout(context);
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

              return Container(
                height: 200,
                padding: EdgeInsets.fromLTRB(30, 10, 30, 0),
                child: Card(
                  semanticContainer: true,
                  color: Colors.blue, // Set the desired color for the card
                  elevation: 4, // Set the desired elevation for the card
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Set the desired border radius for the card
                  ),
                  // Set the desired padding for the card content

                  child: ListTile(
                    title: Text(
                      project['title'],
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),

                    subtitle: FutureBuilder<dynamic>(
                      future: getData(context, project),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          String data = snapshot.data.toString();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _truncateSubtitle(project['description'],
                                    10), // Set the desired word limit
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(height: 30),
                              // Spacer(flex: 2),

                              DottedLine(
                                lineThickness: 1.0,
                                dashLength: 4.0,
                                dashColor: Colors.grey,
                              ),

                              Text(
                                data,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          );
                        }
                      },
                    ),

                    // Add more fields from the document as needed
                    onTap: () {
                      _showProjectDetailsDialog(context, project);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.home, size: 30),
              onPressed: () {
                // Action for home button
              },
            ),
            IconButton(
              icon: Icon(Icons.account_circle, size: 30),
              onPressed: () {
                // Action for account
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
        return Container(
          height: 150,
          child: AlertDialog(
            backgroundColor: Color.fromARGB(255, 218, 232, 238),
            title: Text(project['title']),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Description:${project['description']} ',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 15),
                Text('Skills: ${project['skills']}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 15),
                Text('Domain: ${project['domain']}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 15),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  var user = _auth.currentUser;
                  List<dynamic> array = project['applied'];
                  if (array.contains(user!.uid)) {
                    // Element already exists, show a message
                    print('Element is already present');
                    return;
                  }
                  array.add(user.uid);
                  project.reference.update({'applied': array});
                  print(array);
                },
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blueAccent),
                ),
                child: Text(
                  "Apply",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  //WORD LIMIT
  String _truncateSubtitle(String subtitle, int wordLimit) {
    List<String> words = subtitle.split(' ');
    if (words.length <= wordLimit) {
      return subtitle;
    } else {
      List<String> truncatedWords = words.sublist(0, wordLimit);
      return '${truncatedWords.join(' ')}...';
    }
  }

  getData(BuildContext context, DocumentSnapshot project) async {
    String userId = project['userDocId'];
    DocumentSnapshot userSnapshot = await _userCollection.doc(userId).get();
    print(userSnapshot['name']);

    String name = userSnapshot['name'];
    return name;
  }
}
