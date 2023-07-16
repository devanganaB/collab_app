import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Chat_Page.dart';
import 'student.dart';
import 'LoginPage.dart';

class ChatPageStudent extends StatefulWidget {
  const ChatPageStudent({super.key});

  @override
  State<ChatPageStudent> createState() => _ChatPageStudentState();
}

class _ChatPageStudentState extends State<ChatPageStudent> {
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
        title: Text("Accepted Projects"),
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
              Future<List<dynamic>> acceptedProjects = getAcceptedProjects();

              return FutureBuilder<List<dynamic>>(
                future: acceptedProjects,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    List<dynamic> acceptedProjects = snapshot.data!;
                    if (acceptedProjects.contains(project.id)) {
                      return Container(
                        height: 200,
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: Card(
                          semanticContainer: true,
                          color: Colors.indigoAccent,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(
                              project['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _truncateSubtitle(
                                            project['description'], 10),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Mentor: " + data,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => chatpage(
                                    projectid: project.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  }
                },
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
                // Action for chat
              },
            ),
            IconButton(
              icon: Icon(Icons.home, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Student()),
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

  getData(BuildContext context, DocumentSnapshot project) async {
    String userId = project['userDocId'];
    DocumentSnapshot userSnapshot = await _userCollection.doc(userId).get();
    print(userSnapshot['name']);

    String name = userSnapshot['name'];
    return name;
  }

  Future<List<dynamic>> getAcceptedProjects() async {
    var user = _auth.currentUser;
    DocumentSnapshot userSnapshot = await _userCollection.doc(user!.uid).get();
    List<dynamic> array = userSnapshot['acceptedProjects'];
    print(array);
    return array;
  }
}
