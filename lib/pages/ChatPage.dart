import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'teacher.dart';
import 'LoginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dotted_line/dotted_line.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState();
  final _auth = FirebaseAuth.instance;
  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  final List<String> students = [
    'Student 1',
    'Student 2',
    'Student 3',
    'Student 4',
    'Student 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Projects"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout), //LOGOUT
            onPressed: () {
              logout(context);
            },
          ),
        ],
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
              List<dynamic> array = project['applied'];
              print(array);
              var user = _auth.currentUser;
              if (project['userDocId'] == user!.uid && array.isNotEmpty) {
                return Container(
                  height: 200,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Card(
                    semanticContainer: true,
                    color: Colors.blue,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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
              } else {
                return SizedBox();
              }
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
                // Action for chat
              },
            ),
            IconButton(
              icon: Icon(Icons.home, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Teacher()),
                );
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

  void _showProjectDetailsDialog(
      BuildContext context, DocumentSnapshot project) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 350,
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
                Container(
                  height: 150,
                  width: 300,
                  color: Colors.amber,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text("student1", style: TextStyle(fontSize: 18)),
                        Text("student2", style: TextStyle(fontSize: 18)),
                        Text("student3", style: TextStyle(fontSize: 18)),
                        Text("student4", style: TextStyle(fontSize: 18)),
                        Text("student5", style: TextStyle(fontSize: 18)),
                        Text("student1", style: TextStyle(fontSize: 18)),
                        Text("student2", style: TextStyle(fontSize: 18)),
                        Text("student3", style: TextStyle(fontSize: 18)),
                        Text("student4", style: TextStyle(fontSize: 18)),
                        Text("student5", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                ),
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
