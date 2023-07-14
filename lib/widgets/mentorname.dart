import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:softhack/widgets/cards.dart';

class DataDisplayWidget extends StatefulWidget {
  final DocumentSnapshot project;

  const DataDisplayWidget({
    super.key,
    required this.project,
  }) : super();

  @override
  _DataDisplayWidgetState createState() => _DataDisplayWidgetState();
}

class _DataDisplayWidgetState extends State<DataDisplayWidget> {
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  DocumentSnapshot<Object?> get project => project;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text with Future Data'),
      ),
      body: Center(
        child: FutureBuilder<dynamic>(
          future: getData(context, project),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              String data = snapshot.data.toString();
              return Text(data);
            }
          },
        ),
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
}
