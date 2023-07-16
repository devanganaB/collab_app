import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'message.dart';

class chatpage extends StatefulWidget {
  String projectid;
  chatpage({required this.projectid});
  @override
  _chatpageState createState() => _chatpageState(projectid: projectid);
}

Future<Map<String, dynamic>> fetchProjectData(String projectid) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection('projects')
      .doc(projectid)
      .get();
  return snapshot.data() as Map<String, dynamic>;
}

class _chatpageState extends State<chatpage> {
  String projectid;
  _chatpageState({required this.projectid});

  final fs = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final TextEditingController message = new TextEditingController();
  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchProjectData(projectid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            //APPBAR AND BODY LOADING
            appBar: AppBar(
              backgroundColor: Colors.grey[300],
              title: const Text("Loading..."),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasError) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.grey[300],
                //APPBAR AND BODY ERROR
                title: const Text("Error"),
              ),
              body: const Center(
                child: Text("Error occurred while fetching project data."),
              ),
            );
          } else {
            var projectData = snapshot.data!;
            String projectTitle = projectData['title'];
            return Scaffold(
              //APPBAR
              appBar: AppBar(
                backgroundColor: Colors.grey[300],
                title: Text(projectTitle),
              ),

              //BODY
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      //TEXTY
                      Container(
                        padding: EdgeInsets.all(10),
                        height: MediaQuery.of(context).size.height * 0.819,
                        child: Messages(
                          projectid: projectid,
                        ),
                      ),
                      //BOTTOM MESSAGE TYPE
                      Container(
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 6, 0, 10),
                                child: TextFormField(
                                  controller: message,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.purple[100],
                                    hintText: 'message',
                                    enabled: true,
                                    contentPadding: const EdgeInsets.only(
                                        left: 18.0, bottom: 6.0, top: 8.0),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.purple),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.purple),
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                    ),
                                  ),
                                  validator: (value) {},
                                  onSaved: (value) {
                                    message.text = value!;
                                  },
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (message.text.isNotEmpty) {
                                  var user = _auth.currentUser;
                                  _projectsCollection
                                      .doc(projectid)
                                      .collection('Messages')
                                      .doc()
                                      .set({
                                    'message': message.text.trim(),
                                    'time': DateTime.now(),
                                    'uid': user!.uid,
                                  });

                                  message.clear();
                                }
                              },
                              icon: const Icon(Icons.send_sharp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
