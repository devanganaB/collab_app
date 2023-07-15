import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Messages extends StatefulWidget {
  final String projectid;

  Messages({required this.projectid});

  @override
  _MessagesState createState() => _MessagesState(projectid: projectid);
}

class _MessagesState extends State<Messages> {
  final String projectid;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _messageStream;

  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  _MessagesState({required this.projectid});

  @override
  void initState() {
    super.initState();
    getChats(projectid).then((stream) {
      setState(() {
        _messageStream = stream;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    print("hello builder");
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _messageStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          print("hello hasError");
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("hello");
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (_, index) {
            print("hello itemBuilder");
            Map<String, dynamic> documentData =
                snapshot.data!.docs[index].data();

            var user = FirebaseAuth.instance.currentUser;
            print(user!.uid);
            Timestamp t = documentData['time'];
            DateTime d = t.toDate();

            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: user.uid == documentData['uid']
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: Colors.purple,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      title: FutureBuilder<dynamic>(
                        future: getName(documentData['uid']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text("Something went wrong");
                          }
                          String data = snapshot.data.toString();
                          return Text(
                            data,
                            style: TextStyle(
                              fontSize: 15,
                            ),
                          );
                        },
                      ),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 200,
                            child: Text(
                              documentData['message'],
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            '${d.hour}:${d.minute}',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getChats(
      String projectid) async {
    Stream<QuerySnapshot<Map<String, dynamic>>> stream = _projectsCollection
        .doc(projectid)
        .collection('Messages')
        .orderBy('time')
        .snapshots();
    return stream;
  }

  Future<dynamic> getName(String uid) async {
    DocumentSnapshot userSnapshot = await _userCollection.doc(uid).get();
    return userSnapshot['name'];
  }
}
