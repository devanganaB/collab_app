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
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _messageStream,
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
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

            return Container(
              padding: EdgeInsets.only(
                  top: 2,
                  bottom: 2,
                  left: documentData['uid'] == user.uid ? 0 : 5,
                  right: documentData['uid'] == user.uid ? 5 : 0),
              alignment: documentData['uid'] == user.uid
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: documentData['uid'] == user.uid
                    ? const EdgeInsets.only(left: 30)
                    : const EdgeInsets.only(right: 30),
                padding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 15, right: 60),
                decoration: BoxDecoration(
                    borderRadius: documentData['uid'] == user.uid
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                    color: documentData['uid'] == user.uid
                        ? Theme.of(context).primaryColor
                        : Colors.grey[700]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<dynamic>(
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
                          textAlign: TextAlign.start,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(documentData['message'],
                        textAlign: TextAlign.start,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white))
                  ],
                ),
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
