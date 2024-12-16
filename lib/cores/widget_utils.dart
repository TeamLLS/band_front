import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//그냥 유틸 함수까지 같이 저장

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      duration: const Duration(seconds: 2),
    ),
  );
  return;
}

String formatToMDHM(DateTime dateTime) {
  DateFormat formatter = DateFormat('MM.dd HH:mm');
  return formatter.format(dateTime);
}

String formatToYMDHM(DateTime dateTime) {
  DateFormat formatter = DateFormat('yy.MM.dd HH:mm');
  return formatter.format(dateTime);
}

String formatStringToYMDHM(String date) {
  DateTime dateTime = DateTime.parse(date);
  DateFormat formatter = DateFormat('yy.MM.dd HH:mm');
  return formatter.format(dateTime);
}

String formatToYMD(DateTime dateTime) {
  DateFormat formatter = DateFormat('yy.MM.dd');
  return formatter.format(dateTime);
}

String formatToYM(DateTime dateTime) {
  DateFormat formatter = DateFormat('yy.MM');
  return formatter.format(dateTime);
}

Widget elevatedBtnUnit({
  required String text,
  IconData? icon,
  required VoidCallback onPressed,
  Color borderColor = Colors.black, // 테두리 색을 매개변수로 추가
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
    child: icon == null
        ? ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2), // 동적 테두리 색
              ),
            ),
            onPressed: onPressed,
            child: Text(
              text,
              style: const TextStyle(fontSize: 16.0),
            ),
          )
        : ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2), // 동적 테두리 색
              ),
            ),
            icon: Icon(icon, color: Colors.black),
            label: Text(
              text,
              style: const TextStyle(fontSize: 16.0),
            ),
            onPressed: onPressed,
          ),
  );
}

Widget inputTextUnit(TextEditingController ctl) {
  return Material(
    elevation: 3.0,
    borderRadius: BorderRadius.circular(40.0),
    child: TextField(
      controller: ctl,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
          borderSide: const BorderSide(color: Colors.grey, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40.0),
          borderSide: const BorderSide(color: Colors.grey, width: 0.8),
        ),
      ),
    ),
  );

  // return TextField(
  //   controller: ctl,
  //   decoration: InputDecoration(
  //     enabledBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(40.0),
  //       borderSide: const BorderSide(color: Colors.grey, width: 0.8),
  //     ),
  //     focusedBorder: OutlineInputBorder(
  //       borderRadius: BorderRadius.circular(40.0),
  //       borderSide: const BorderSide(color: Colors.grey, width: 0.8),
  //     ),
  //   ),
  // );
}

Widget inputOnelineTextUnit(TextEditingController ctl) {
  return Material(
    elevation: 3.0,
    borderRadius: BorderRadius.circular(20.0),
    child: TextField(
      controller: ctl,
      minLines: 1,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.grey, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
          borderSide: const BorderSide(color: Colors.grey, width: 0.8),
        ),
      ),
    ),
  );
}

Widget searchUnit({
  required TextEditingController ctl,
  required VoidCallback onSearchPressed,
}) {
  return Material(
    elevation: 3.0,
    borderRadius: BorderRadius.circular(20.0),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: ctl,
            minLines: 1,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
            ),
          ),
        ),
        IconButton(
          onPressed: onSearchPressed, // 파라미터로 전달된 함수 사용
          icon: const Icon(Icons.search),
        ),
      ],
    ),
  );
}

Widget InputMultiTextUnit(TextEditingController ctl) {
  //wrap with desUnit
  return TextField(
    controller: ctl,
    maxLines: 5,
    decoration: const InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 0.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 0.8),
      ),
    ),
  );
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

Widget budgetUnit({required int amount, required double parentWidth}) {
  final formattedAmount = NumberFormat.decimalPattern().format(amount);

  return desUnit(
    child: SizedBox(
      height: parentWidth * 0.3,
      child: Center(
        child: Text(
          "₩  $formattedAmount",
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
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
