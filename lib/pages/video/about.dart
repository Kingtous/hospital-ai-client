import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/constants.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '思易慧眼AI管理平台v1.1',
            style: TextStyle(fontSize: 24.0),
          ),
          SizedBox(
            height: 8.0,
          ),
          Text('数据库路径:    ${kdbPath}'),
          SizedBox(
            height: 8.0,
          ),
          Text('数据库版本:    ${kDbVersion}'),
          SizedBox(
            height: 8.0,
          ),
          Text('历史报警数:    ${alertsModel.historyAlertsRx.length}')
        ],
      ),
    );
  }
}
