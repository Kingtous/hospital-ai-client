import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors;
import 'package:hospital_ai_client/constants.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [bgImage, _buildLoginForm(context)],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        height: 400,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.grey.withAlpha(100)),
        child: const Column(
          children: [
            Row(
              children: [
                Expanded(child: TextBox()),
              ],
            ),
            Row(
              children: [
                Expanded(child: TextBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}