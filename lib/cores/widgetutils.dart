import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2),
    ),
  );
  return;
}

Widget mainUnit({required Widget child}) {
  return Card(
    margin: const EdgeInsets.fromLTRB(40, 0, 40, 40),
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shadowColor: Colors.black.withOpacity(1),
    elevation: 10.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    child: child,
  );
}

Widget desUnit({required Widget child}) {
  return Card(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shadowColor: Colors.black.withOpacity(1),
    elevation: 10.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    child: child,
  );
}

Widget menuUnit({required double width, required Widget child}) {
  return Container(
    width: width,
    child: Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withOpacity(1),
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: child,
    ),
  );
}

Widget titleUnit({required double width, required Widget child}) {
  return SizedBox(
    width: width,
    child: Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withOpacity(1),
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: child,
    ),
  );
}

Widget desTextUnit({required int maxLine, required String description}) {
  return TextFormField(
    readOnly: true,
    maxLines: maxLine,
    decoration: InputDecoration(
      border: InputBorder.none,
      hintText: description,
      hintStyle: const TextStyle(color: Colors.black),
    ),
  );
}
