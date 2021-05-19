import 'package:flutter/scheduler.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/Admin/AdminRoot.dart';
import 'package:orderista/Canteen/CanteenRoot.dart';
import 'package:orderista/Common/InternetCheck.dart';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/Root/root_app.dart';
import 'package:orderista/Common/login_screen.dart';
import 'package:orderista/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  SharedPreferences prefs;
  bool isChecking = false;
  String userID, userRole = "";
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    checkInternet(context);
    getTheme();

    // setColorTheme(isDarkMode);
  }

  void getTheme() async {
    prefs = await SharedPreferences.getInstance();
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
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void getPrefs() async {
    setState(() {
      isChecking = true;
    });
    prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");
    userRole = prefs.getString("userRole");
    setState(() {
      isChecking = false;
    });
    if (userID == null) {
      //OnTap route it to login page.
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    } else if (userRole == "admin") {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => AdminRoot(),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider<Cart>(create: (context) => Cart()),
              ChangeNotifierProvider<Menu>(create: (context) => Menu()),
            ],
            child: userRole == "student" ? Root() : CanteenRoot(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //Store the size of the screen for easy usage.
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Text(""),
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SvgPicture.asset("images/wlcm.svg",
                      width: size.width * 0.25, height: size.height * 0.25),
                  SizedBox(
                    height: 50,
                  ),
                  Text(
                    "oderista",
                    style: TextStyle(
                        color: isDarkMode ? textColorDark : textColorLight,
                        fontSize: 35),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    onTap: () {
                      getPrefs();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDarkMode ? buttonColorDark : buttonColorLight,
                        borderRadius: BorderRadius.circular(60),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12.withOpacity(.2),
                              blurRadius: 20,
                              offset: Offset(0, 10)),
                        ],
                      ),
                      child: Center(
                          child: !isChecking
                              ? Icon(
                                  SFSymbols.arrow_right,
                                  color: Colors.white,
                                )
                              : isDarkMode
                                  ? spinkit
                                  : spinkitDark),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
