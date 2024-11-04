import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dataclass.dart';
import 'enumeration.dart';

class MyInfo with ChangeNotifier {
  User? me;
  Role? myRole;
}
