import 'package:flutter/material.dart';
import 'teacher.dart';
import 'student.dart';
import 'SideMenu.dart';

class ViewProfile extends StatelessWidget {
  const ViewProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.grey[350],
      ),
    );
  }
}
