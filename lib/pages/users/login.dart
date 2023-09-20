import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' hide Colors, FilledButton;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/components/header.dart';
import 'package:hospital_ai_client/constants.dart';

class UserLogin extends StatefulWidget {
  const UserLogin({super.key});

  @override
  State<UserLogin> createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  var userName = "";
  var password = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppHeader(),
        Expanded(
          child: Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                ),
                bgImage,
                _buildLoginForm(context)
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Center(
      child: Container(
        width: 800,
        height: 250,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.white.withAlpha(170)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/login-mg.png',
              width: 340,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              width: 120,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: InfoBar(title: Text('请使用管理员提供的用户名密码登录本系统'))),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextBox(
                        onChanged: (v) {
                          userName = v;
                        },
                        prefix: Text('用户名').paddingOnly(left: 16.0),
                      )),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: TextBox(
                        obscureText: true,
                        onChanged: (v) {
                          password = v;
                        },
                        onSubmitted: (value) {
                          password = value;
                          _login(WeakReference(context));
                        },
                        prefix: Text('密码').paddingOnly(left: 16.0),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      FilledButton(
                          child: Text('登录'),
                          autofocus: true,
                          onPressed: () => _login(WeakReference(context))),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _login(WeakReference<BuildContext> wc) async {
    final isLogin = await userModel.login(userName, password);
    final context = wc.target;
    if (context == null) {
      return;
    }
    if (isLogin) {
      // ignore: use_build_context_synchronously
      context.goNamed('home');
    } else {
      // ignore: use_build_context_synchronously
      displayInfoBar(context, builder: (context, close) {
        return InfoBar(
            title: Text('登录账号或密码不正确'),
            severity: InfoBarSeverity.warning,
            action: Button(
              child: Icon(FluentIcons.accept),
              onPressed: close,
            ));
      }, alignment: Alignment.topCenter);
    }
  }
}
