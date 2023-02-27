import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kloser/settings/locale/app_localizations.dart';
import 'package:kloser/viewes/profile/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${AppLocale.of(context)!.translate("home")}"),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text("${AppLocale.of(context)!.translate("profile")}"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ProfilePage();
                }));
              },
            ),
            ListTile(
              title: Text('${AppLocale.of(context)!.translate("log_out")}'),
              onTap: () async {
                _signOut();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('uuid');
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, '/sign_in');
              },
            )
          ],
        ),
      ),
      body: Container(
        color: Colors.amber,
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
