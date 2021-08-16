import 'package:flutter/material.dart';
import 'package:instagram_clone/authProvider/auth_provider.dart';


import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  static String id = "login";
  @override
  Widget build(BuildContext context) {
    AuthProvider providerType = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).accentColor,
              Theme.of(context).primaryColor
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              "Instagram",
              style: TextStyle(
                fontFamily: "Signatra",
                fontSize: 90.0,
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: () {
                providerType.googleSignUp(context);
              },
              child: Container(
                height: 60,
                width: 260.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/google_auth_button.png"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
