import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_clone/Pages/bottom_page.dart';
import 'package:instagram_clone/models/user_models.dart';
import 'package:instagram_clone/widgets/flutter_toast.dart';

class AuthProvider extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  UserModels userModels;
  final usersRef = FirebaseFirestore.instance.collection("users");
  final DateTime timestamp = DateTime.now();
  User user;
  sendUserDataFirebase(BuildContext context) {
    usersRef.doc(user.uid).set({
      "userid": user.uid,
      "username": user.displayName,
      "email": user.email,
      "photo": user.photoURL,
      "bio": "",
      "name": nameController.text,
      "timestamp": timestamp,
    // });
    }).then(
      (value) => Navigator.pushNamedAndRemoveUntil(
          context, BottomPage.id, (route) => false),
    );
    notifyListeners();
  }

  userValidation(BuildContext context) {
    if (nameController.text.isEmpty) {
      flutterToast(context: context, msg: "Name is empty");
      return;
    } else if (nameController.text.length < 3) {
      flutterToast(
        context: context,
        msg: "Please provide a valid name",
      );
      return;
    } else {
      sendUserDataFirebase(context);
    }
    notifyListeners();
  }

  Future<void> googleSignUp(BuildContext context) async {
    try {
      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );
      final FirebaseAuth _auth = FirebaseAuth.instance;
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      user = (await _auth.signInWithCredential(credential)).user;

      if (user != null) {
        DocumentSnapshot doc = await usersRef.doc(user.uid).get();
        if (!doc.exists) {
          await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("User Name"),
                content: TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Enter username",
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  MaterialButton(
                    color: Theme.of(context).primaryColor,
                    child: Text("Continue"),
                    onPressed: () {
                      userValidation(context);
                    },
                  ),
                ],
              );
            },
          );
        }
        userModels = UserModels.fromDocument(doc);
        notifyListeners();
        Navigator.pushNamedAndRemoveUntil(
            context, BottomPage.id, (route) => false);
      } else {
        print("Signing Eror");
      }
    } catch (e) {
      print(e.message);
    }
    notifyListeners();
  }

  get userDetails {
    return userModels;
  }
}
