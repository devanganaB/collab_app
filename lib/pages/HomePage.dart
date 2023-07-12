import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Action for profile button
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Drawer Header',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Menu Item 1'),
              onTap: () {
                // Action for menu item 1
              },
            ),
            ListTile(
              title: Text('Menu Item 2'),
              onTap: () {
                // Action for menu item 2
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Posts in card views
            Card(
              child: ListTile(
                title: Text('Post Title 1'),
                subtitle: Text('Post Description 1'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Post Title 2'),
                subtitle: Text('Post Description 2'),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Post Title 3'),
                subtitle: Text('Post Description 3'),
              ),
            ),
            // Add more card views for additional posts
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                // Action for home button
              },
            ),
            IconButton(
              icon: Icon(Icons.chat),
              onPressed: () {
                // Action for chat button
              },
            ),
          ],
        ),
      ),
    );
  }
}
