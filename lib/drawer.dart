// lib/widgets/drawer.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/store.dart';
import 'main.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedInUser =
        Provider.of<AppStore>(context, listen: true).loggedInUser;

    final username = loggedInUser?.username;
    final name = loggedInUser?.preferredName;

    return Drawer(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://www.w3schools.com/howto/img_avatar.png',
                  ),
                  backgroundColor: Colors.grey,
                ),
                SizedBox(height: 12),
                Text(
                  '$name',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('$username', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 16.0, bottom: 8.0),
            child: Text(
              'OPTIONS',
              style: TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 147, 147, 148),
                letterSpacing: 1.2,
                height: 1.5,
              ),
            ),
          ),
          // ListTile(
          //   leading: Icon(Icons.room_preferences),
          //   title: Text('Preferences'),
          //   onTap: () {
          //     Navigator.pop(context);
          //   },
          // ),

          ListTile(
            leading: Icon(Icons.logout_sharp),
            title: Text('Logout'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
