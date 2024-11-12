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
    elevation: 3.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
      side: const BorderSide(color: Colors.grey, width: 0.8),
    ),
    child: child,
  );

  // return Container(
  //   margin: const EdgeInsets.fromLTRB(40, 0, 40, 40),
  //   decoration: BoxDecoration(
  //     color: Colors.white,
  //     borderRadius: BorderRadius.circular(50.0),
  //     border: Border.all(
  //       color: Colors.grey, // 회색 테두리
  //       width: 1, // 테두리의 두께
  //     ),
  //   ),
  //   child: child,
  // );

  // return Card(
  //   margin: const EdgeInsets.fromLTRB(40, 0, 40, 40),
  //   color: Colors.white,
  //   clipBehavior: Clip.antiAlias,
  //   shadowColor: Colors.black.withOpacity(1),
  //   elevation: 5.0,
  //   shape: RoundedRectangleBorder(
  //     borderRadius: BorderRadius.circular(50.0),
  //   ),
  //   child: child,
  // );
}

Widget desUnit({required Widget child}) {
  return Card(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    shadowColor: Colors.black.withOpacity(1),
    elevation: 3.0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
      side: const BorderSide(color: Colors.grey, width: 0.8),
    ),
    child: child,
  );
}

Widget menuBarUnit({required double width, required Widget child}) {
  //club detail의 아이콘 메뉴 바
  return SizedBox(
    width: width,
    child: Card(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.black.withOpacity(1),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
        side: const BorderSide(color: Colors.grey, width: 0.8),
      ),
      child: child,
    ),
  );
}

// Widget titleUnit({required double width, required Widget child}) {
//   return SizedBox(
//     width: width,
//     child: Card(
//       color: Colors.white,
//       clipBehavior: Clip.antiAlias,
//       shadowColor: Colors.black.withOpacity(1),
//       elevation: 10.0,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(50.0),
//       ),
//       child: child,
//     ),
//   );
// }

Widget desTextUnit({required int maxLine, required String description}) {
  //desUnit 안에 들어갈 text field
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
