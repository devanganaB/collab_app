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
  final TextEditingController githubLink = new TextEditingController();
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
                actions: [
                  ElevatedButton(
                      onPressed: () async {
                        var user = _auth.currentUser;
                        DocumentSnapshot userSnapshot =
                            await _userCollection.doc(user!.uid).get();
                        if (userSnapshot['role'] == 'Student') {
                          DocumentSnapshot project =
                              await _projectsCollection.doc(projectid).get();
                          _showProjectDetailsDialog(context, project);
                        } else {}
                      },
                      child: Text("GitHub"))
                ],
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

  void _showProjectDetailsDialog(
      BuildContext context, DocumentSnapshot project) async {
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
                    TextField(
                      controller: githubLink,
                      onChanged: (value) {
                        githubLink.text = value;
                      },
                      decoration: InputDecoration(
                          labelText: 'Github  ',
                          hintText: 'Enter Github repository link'),
                    ),
                  ],
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
                      if (githubLink.text.isNotEmpty) {
                        _projectsCollection
                            .doc(projectid)
                            .update({'githubLink': githubLink.text});
                      }
                    },
                    child: Text('Github'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
//   _launchURL() async {
//    final Uri url = Uri.parse('https://flutter.dev');
//    if (!await launchUrl(url)) {
//         throw Exception('Could not launch $_url');
//     }
// }
}
