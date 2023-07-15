import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class messages extends StatefulWidget {
  String projectid;
  messages({required this.projectid});
  @override
  _messagesState createState() => _messagesState(projectid: projectid);
}

class _messagesState extends State<messages> {
  String projectid;
  _messagesState({required this.projectid});
  Stream<QuerySnapshot>? _messageStream;

  CollectionReference _projectsCollection =
      FirebaseFirestore.instance.collection('projects');
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // void initState() {
  //   getChatandAdmin();
  //   super.initState();
  // }

  // getChatandAdmin() {
  //   getChats(projectid).then((val) {
  //     setState(() {
  //       _messageStream = val;
  //       print(_messageStream);
  //     });
  //   });
  // }

  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: getChats(projectid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("something is wrong");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          physics: ScrollPhysics(),
          shrinkWrap: true,
          primary: true,
          itemBuilder: (_, index) {
            QueryDocumentSnapshot qs = snapshot.data!.docs[index];
            var user = _auth.currentUser;
            Timestamp t = qs['time'];
            DateTime d = t.toDate();
            print(d.toString());
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: user!.uid == qs['uid']
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
                      title: StreamBuilder<dynamic>(
                          stream: getName(qs['uid']),
                          builder: (context, snapshot) {
                            String data = snapshot.data.toString();
                            return Text(
                              data,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            );
                          }),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 200,
                            child: Text(
                              qs['message'],
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Text(
                            d.hour.toString() + ":" + d.minute.toString(),
                          )
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

  getChats(String projectid) async {
    return _projectsCollection
        .doc(projectid)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  getName(String uid) async {
    DocumentSnapshot userSnapshot = await _userCollection.doc(uid).get();
    return userSnapshot['name'];
  }
}
