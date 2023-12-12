import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hospital_ai_client/base/interfaces/interfaces.dart';
import 'package:hospital_ai_client/base/routes/routes.dart';
import 'package:hospital_ai_client/constants.dart';
import 'package:media_kit/media_kit.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  // runZonedGuarded(() async {
  //   await SentryFlutter.init(
  //     (options) {
  //       if (kDebugMode) {
  //         options.logger = kSentryLogger;
  //       }
  //       options.dsn =
  //           'https://cc0741f1b06728d5716e13a7d907f971@o4505797279940608.ingest.sentry.io/4506233328566272';
  //       options.tracesSampleRate = kDebugMode ? 1.0 : 0.7;
  //     },
  //   );

  // }, (error, stack) async {
  //   kLogger.e('$error');
  //   // kLogger.f('$stack');
  //   debugPrintStack(stackTrace: stack);
  //   await Sentry.captureException(error, stackTrace: stack);
  // });
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await setupDependencies();
  runApp(const AiClientApp());
}

class AiClientApp extends StatelessWidget {
  const AiClientApp({super.key});

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
              backgroundColor: const Color(0xFF0E1726),
              highlightColor: const Color(0x0DB6FF1A),
              selectedTextStyle:
                  ButtonState.all(const TextStyle(color: Color(0xFF409EFF))),
              unselectedTextStyle:
                  ButtonState.all(const TextStyle(color: Colors.white)),
              unselectedIconColor: ButtonState.all(Colors.white),
              selectedIconColor: ButtonState.all(const Color(0xFF409EFF)))),
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
