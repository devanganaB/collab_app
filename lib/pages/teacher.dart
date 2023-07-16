import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:softhack/pages/SideMenu.dart';
import 'package:softhack/pages/ViewProfile.dart';
import 'ChatPage.dart';
import 'CreatePostPage.dart';
import 'LoginPage.dart';
import 'package:softhack/widgets/cards.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:softhack/widgets/mentorname.dart';
import 'package:dotted_line/dotted_line.dart';
import 'SideMenu.dart';
import 'package:google_fonts/google_fonts.dart';

class Teacher extends StatefulWidget {
  @override
  State<Teacher> createState() => _TeacherState();
}

class _TeacherState extends State<Teacher> {
  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.lightBlueAccent,
              Colors.deepPurple,
              Colors.purple,
              Colors.redAccent
            ],
          ),
        ),
        child: Column(
          children: [
            //TOP
            Container(
              height: 60,
              padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(builder: (context) {
                    return IconButton(
                      icon: Icon(Icons.menu), // Hamburger icon for side menu
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  }),
                  IconButton(
                    icon: Icon(Icons.logout), // Logout icon
                    onPressed: () {
                      logout(context);
                    },
                  ),
                ],
              ),
            ),
            Container(
                height: 40,
                child: Text("Collaborate & learn",
                    style: GoogleFonts.sacramento(
                        textStyle:
                            TextStyle(fontSize: 40, color: Colors.white)))),
            SizedBox(
              height: 20,
            ),

            //CARDS
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 243, 240, 240),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _projectsCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            var project = snapshot.data!.docs[index];

                            return Container(
                              height: 200,
                              padding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                              child: Container(
                                child: Card(
                                  semanticContainer: true,
                                  color: Colors.indigoAccent,
                                  elevation: 15,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      project['title'],
                                      style: TextStyle(
                                          fontSize: 25,
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
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else {
                                          String data =
                                              snapshot.data.toString();
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _truncateSubtitle(
                                                    project['description'], 10),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16),
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    "Mentor: " + data,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    onTap: () {
                                      _showProjectDetailsDialog(
                                          context, project);
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: SideMenu(),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewProfile()),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddProjectPage()),
          );
          print("POST ADD");
        },
        child: Icon(Icons.add),
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
            title: Center(
              child: Text(
                project['title'],
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('${project['description']} ',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Text('Skills: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('${project['skills']}',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Text('Domain: ',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    Text('${project['domain']}',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
            actions: [
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Close'),
                  ),
                ],
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
