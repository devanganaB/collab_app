import 'package:flutter/material.dart';

class Project extends StatelessWidget {
  const Project({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Post Title 1'),
        subtitle: Text('Post Description 1'),
      ),
    );
  }
}
