import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'Chat_Page.dart';
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

Future<List<String>> fetchStudentNames(List<dynamic> userIds) async {
  List<String> studentNames = [];

  for (String userId in userIds) {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      String name = userSnapshot.get('name') as String;
      studentNames.add(name);
    }
  }

  return studentNames;
}

class _ChatPageState extends State<ChatPage> {
  _ChatPageState();
  final _auth = FirebaseAuth.instance;
  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  Map<String, bool> studentAcceptance = {};
  List<String> studentNames = [];

  // @override
  // void initState() {
  //   super.initState();
  //   fetchStudentNames().then((names) {
  //     setState(() {
  //       studentNames = names;
  //     });
  //   }).catchError((error) {
  //     // Handle any potential errors during data retrieval
  //     print('Error fetching student names: $error');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        title: Text("Project Requests"),
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
                    color: Colors.indigoAccent,
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text(
                        project['title'],
                        style: const TextStyle(
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
                            return Text('Error: ${snapshot.error}');
                          } else {
                            String data = snapshot.data.toString();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _truncateSubtitle(project['description'], 10),
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Mentor: " + data,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  ),
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

  acceptStudent(
      BuildContext context, DocumentSnapshot project, String studentId) async {
    String projectId = project.id;
    DocumentSnapshot userSnapshot = await _userCollection.doc(studentId).get();
    DocumentSnapshot projectSnapshot =
        await _projectsCollection.doc(projectId).get();
    List<dynamic> array = userSnapshot['acceptedProjects'];
    List<dynamic> members = projectSnapshot['members'];
    members.add(studentId);
    array.add(projectId);
    userSnapshot.reference.update({'acceptedProjects': array});
    projectSnapshot.reference.update({'members': members});
  }

  void _showProjectDetailsDialog(
      BuildContext context, DocumentSnapshot project) async {
    List<dynamic> appliedUserIds = project.get('applied') as List<dynamic>;

    List<String> studentNames = await fetchStudentNames(appliedUserIds);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 350,
          child: AlertDialog(
            backgroundColor: Color.fromARGB(255, 210, 232, 242),
            title: Center(
              child: Text(project['title'],
                  style: TextStyle(fontWeight: FontWeight.w500)),
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
                Text("Applied students",
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Container(
                  constraints: BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8)),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: studentNames.map((name) {
                          int ind = studentNames.indexOf(name);
                          return Container(
                              width: 300,
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 218, 231, 238),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(name, style: TextStyle(fontSize: 18)),
                                    ElevatedButton(
                                        onPressed: () {
                                          acceptStudent(context, project,
                                              appliedUserIds[ind]);
                                        },
                                        child: Text("accept"))
                                  ],
                                ),
                              ));
                        }).toList(),
                      ),
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
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => chatpage(
                            projectid: project.id,
                          ),
                        ),
                      );
                    },
                    child: Text('Chat'),
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
