import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

flutterToast({String msg, BuildContext context}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Theme.of(context).primaryColor,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
