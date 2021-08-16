import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/Pages/time_line_page.dart';
import 'package:instagram_clone/widgets/progress_widget.dart';
import 'package:path/path.dart' as Path;

// import 'package:image/image.dart' as Im;
import 'package:uuid/uuid.dart';

var postRef = FirebaseFirestore.instance.collection('post');
var timlineRef = FirebaseFirestore.instance.collection('timeline');

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  Geolocator _geolocator = Geolocator();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  var timestamp = DateTime.now();

  var mediaUrl;

  bool isUploading = false;
  File imageFile;
  String postId = Uuid().v4();

  imagePicker({ImageSource source}) async {
    Navigator.pop(context);
    PickedFile imagePicked = await ImagePicker().getImage(
      source: source,
      imageQuality: 30,
    );
    setState(() {
      imageFile = File(imagePicked.path);
    });
  }

  selectedImage() {
    // show the dialog
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Create post"),
          children: [
            SimpleDialogOption(
              child: Text("Photo With Camrea"),
              onPressed: () {
                imagePicker(
                  source: ImageSource.camera,
                );
              },
            ),
            SimpleDialogOption(
              child: Text("Photo From Gallery"),
              onPressed: () {
                imagePicker(
                  source: ImageSource.gallery,
                );
              },
            ),
            SimpleDialogOption(
              child: Text("Canel"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Column buildSplashScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: selectedImage,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SvgPicture.asset("images/upload.svg"),
          ),
        ),
        // MaterialButton(
        //   onPressed: selectedImage,
        //   color: Theme.of(context).primaryColor,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   child: Center(
        //     child: Text(
        //       "Upload  Image",
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontSize: 22,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  clearImage() {
    setState(() {
      imageFile = null;
    });
  }

  getUserLocation() async {
    Position position = await _geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    List<Placemark> placemarks = await _geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String currentLocation = "${placemark.locality} ${placemark.country}";
    locationController.text = currentLocation;
  }

  // compressImage() async {
  //   final tempDir = await getTemporaryDirectory();
  //   final path = tempDir.path;
  //   Im.Image imagefile = Im.decodeImage(imageFile.readAsBytesSync());
  //   final compressedImageFile = File("$path/img_$postId.jpg")
  //     ..writeAsBytesSync(
  //       Im.encodeJpg(imagefile, quality: 85),
  //     );
  //   setState(() {
  //     this.imageFile = compressedImageFile;
  //   });
  // }

  Future uploadImage({@required File imageFile}) async {
    var storageReference = FirebaseStorage.instance
        .ref()
        .child('postImages/${Path.basename(imageFile.path)}}}');
    var uploadTask = storageReference.putFile(imageFile);
    await uploadTask;
    await storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        mediaUrl = fileURL;
      });

      print('Image Uploaded');
    });
  }

  Future uploadPostDataInFirebase() async {
    postRef.doc(currentUser.userid).collection("userPost").doc(postId).set(
      {
        "psotId": postId,
        "ownerId": currentUser.userid,
        "MediaUrl": await mediaUrl,
        "description": descriptionController.text,
        "location": locationController.text,
        "timestamp": timestamp,
        "name": currentUser.name,
        "like": {}
      },
    );

    timlineRef.doc(postId).set(
      {
        "psotId": postId,
        "ownerId": currentUser.userid,
        "MediaUrl": await mediaUrl,
        "description": descriptionController.text,
        "location": locationController.text,
        "timestamp": timestamp,
        "name": currentUser.name,
        "like": {}
      },
    );
  }

  hindleSubmit() async {
    setState(() {
      isUploading = true;
    });
    //await compressImage();
    await uploadImage(imageFile: imageFile);
    await uploadPostDataInFirebase();
    descriptionController.clear();
    locationController.clear();
    setState(() {
      imageFile = null;
      isUploading = false;
    });
    // await Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Timeline))
  }

  buildUploadFrom() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("Caption Post"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        actions: [
          MaterialButton(
            child: Text(
              "Post",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            onPressed: isUploading ? null : () => hindleSubmit(),
          )
        ],
      ),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          isUploading ? linearProfress() : Text(""),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: FileImage(imageFile),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(currentUser.photo),
            ),
            title: Container(
              width: 250.0,
              child: TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: "Write a caption...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              size: 35.0,
              color: Colors.orange,
            ),
            title: Container(
              width: 250.0,
              child: TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: "Write was this photo taken?",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Container(
            width: 100.0,
            height: 100.0,
            alignment: Alignment.center,
            child: MaterialButton(
              color: Theme.of(context).primaryColor,
              onPressed: getUserLocation,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              child: ListTile(
                leading: Icon(Icons.my_location),
                title: Text("User Current Location"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: imageFile == null ? buildSplashScreen() : buildUploadFrom(),
    );
  }
}
