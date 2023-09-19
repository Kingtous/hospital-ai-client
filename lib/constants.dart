import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';

const kDbVersion = 1;
const kDefaultAdminName = 'admin';
const kDefaultAdminPassword = 'admin';


/// UI
Widget get bgImage => SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Image.asset(
        'assets/images/bg.jpeg',
        fit: BoxFit.cover,
      ),
    );