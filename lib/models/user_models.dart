import 'package:cloud_firestore/cloud_firestore.dart';

class UserModels {
  final String username;
  final String email;
  final String photo;
  final String userid;
  final String bio;
  final String name;
  UserModels({
    this.username,
    this.email,
    this.photo,
    this.userid,
    this.name,
    this.bio,
  });
  factory UserModels.fromDocument(DocumentSnapshot doc) {
    return UserModels(
      username: doc["username"],
      email: doc["email"],
      photo: doc["photo"],
      userid: doc["userid"],
      name: doc["name"],
      bio: doc["bio"],
    );
  }
}
