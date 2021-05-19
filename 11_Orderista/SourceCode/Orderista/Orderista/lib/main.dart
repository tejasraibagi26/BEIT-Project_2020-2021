import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:orderista/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

import 'Common/welcome_screen.dart';

SharedPreferences prefs;
bool isDarkMode = false;
void main() async {
  await DotEnv.load(fileName: ".env");
  prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('shouldCheckFeedbackStatus') == null ||
      prefs.getBool('shouldCheckFeedbackStatus') == false)
    prefs.setBool('shouldCheckFeedbackStatus', true);

  if (prefs.getBool("isDarkMode") == null) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;

    if (brightness == Brightness.dark) {
      prefs.setBool("isDarkMode", true);
    } else {
      prefs.setBool("isDarkMode", false);
    }

    if (prefs.getString("email") == "null") {
      prefs.setString("email", "No Email");
    }
    if (prefs.getBool("isEmailVerified") == null) {
      prefs.setBool("isEmailVerified", false);
    }
  }

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      // systemNavigationBarColor: Colors.white,
      statusBarColor: Colors.transparent,
    ),
  );

  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: Platform.isAndroid
            ? ThemeData(
                fontFamily: "Rubik",
                scaffoldBackgroundColor:
                    prefs.getBool("isDarkMode") ? bgColorDark : bgColorLight)
            : ThemeData(
                scaffoldBackgroundColor:
                    prefs.getBool("isDarkMode") ? bgColorDark : bgColorLight),
        home: WelcomeScreen());
  }
}
