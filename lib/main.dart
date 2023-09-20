import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/routes/routes.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FluentApp.router(
      title: '医院AI视频监控',
      theme: FluentThemeData(
          shadowColor: Colors.white,
          // typography: Typography.raw(body: TextStyle(color: Color(0x333333E5))),
          navigationPaneTheme: NavigationPaneThemeData(
              animationCurve: Curves.ease,
              backgroundColor: Color(0xFF0E1726),
              highlightColor: Color(0x0DB6FF1A),
              selectedTextStyle:
                  ButtonState.all(TextStyle(color: Color(0xFF409EFF))),
              unselectedTextStyle:
                  ButtonState.all(TextStyle(color: Colors.white)),
              unselectedIconColor: ButtonState.all(Colors.white),
              selectedIconColor: ButtonState.all(Color(0xFF409EFF)))),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
    );
  }
}
