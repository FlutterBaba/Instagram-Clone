import 'package:flutter/material.dart';

AppBar appBar(BuildContext context, {bool appTitle = false, String title}) {
  return AppBar(
    elevation: 0,
    backgroundColor: appTitle
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColor,
    centerTitle: true,
    title: Text(
      appTitle ? title : "Instagram Clone",
      style: TextStyle(
        fontSize: appTitle ? 25 : 40,
        fontFamily: appTitle ? "" : "Signatra",
      ),
    ),
  );
}
