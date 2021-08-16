import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/Pages/bottom_page.dart';
import 'package:instagram_clone/Pages/login_page.dart';
import 'package:instagram_clone/authProvider/auth_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
          title: 'Instagram Clone',
          initialRoute: LoginPage.id,
          routes: {
            BottomPage.id: (context) => BottomPage(),
            // TimeLinePge.id: (context) => TimeLinePge(),
            LoginPage.id: (context) => LoginPage(),
          },
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.teal,
          ),
          home: StreamBuilder(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (contex, userSnapshot) {
              if (userSnapshot.hasData) {
                return BottomPage();
              }
              return LoginPage();
            },
          ),),
    );
  }
}
