import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_clone/Pages/login_page.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/models/user_models.dart';
import 'package:instagram_clone/widgets/flutter_toast.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';

class EditProfile extends StatefulWidget {
  static String id = "editProfile";
  final UserModels editCurrent;
  EditProfile({this.editCurrent});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  GoogleSignIn googleSignIn = GoogleSignIn();

  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  bool isloding = false;

  // @override
  // void initState() {
  //   setState(() {
  //     isloding = true;
  //   });

  //   setState(() {
  //     isloding = false;
  //   });
  //   super.initState();
  // }

  @override
  void dispose() {
    displayNameController.clear();
    bioController.clear();

    super.dispose();
  }

  buildUploadProfile() {
    userRef.doc(currentUser.userid).update({
      "username": displayNameController.text,
      "bio": bioController.text,
    }).then(
      (value) => Navigator.pop(context),
    );
  }

  userValidation(BuildContext context) {
    if (displayNameController.text.isEmpty) {
      flutterToast(context: context, msg: "DisplayName is empty");
      return;
    } else if (displayNameController.text.length < 3) {
      flutterToast(
        context: context,
        msg: "DisplayName too low",
      );
      return;
    }
    if (bioController.text.isEmpty) {
      flutterToast(context: context, msg: "bio is empty");
      return;
    } else if (bioController.text.length > 100) {
      flutterToast(
        context: context,
        msg: "Bio too long",
      );
      return;
    } else {
      buildUploadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    displayNameController.text = widget.editCurrent.username;
    bioController.text = widget.editCurrent.bio;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("EditProfile"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.white,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: isloding
          ? circularProfress()
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                  physics: BouncingScrollPhysics(),
                children: [
                  Center(
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(widget.editCurrent.photo),
                      radius: 40,
                    ),
                  ),
                  TextFormField(
                    controller: displayNameController,
                    decoration: InputDecoration(
                      labelText: "DisplayName",
                    ),
                  ),
                  TextFormField(
                    controller: bioController,
                    decoration: InputDecoration(
                      labelText: "Bio",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MaterialButton(
                      child: Text(
                        "Update profile",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        userValidation(context);
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () => googleSignIn.signOut().then(
                              (value) => Navigator.pushNamedAndRemoveUntil(
                                  context, LoginPage.id, (route) => false),
                            ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.purple,
                            ),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
