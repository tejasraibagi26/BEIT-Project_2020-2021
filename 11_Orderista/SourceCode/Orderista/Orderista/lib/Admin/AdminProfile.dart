import 'package:orderista/Admin/AdminFeedback.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Common/EmailVerfication.dart';
import 'package:orderista/Common/forgot_pass.dart';
import 'package:orderista/Common/welcome_screen.dart';
import 'package:orderista/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

class AdminProfile extends StatefulWidget {
  @override
  _AdminProfileState createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  var userID = "";
  var email = "";
  String msg = "";
  bool isDarkModeEnabled = false;
  bool isDarkMode = false;
  bool isVerifying = false;

  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getPrefs();
    getTheme();
  }

  void getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");
    email = prefs.getString("email");
  }

  void clearPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  void setTheme(bool value) async {
    setState(() {
      isDarkModeEnabled = value;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("isDarkMode", isDarkModeEnabled);
    getTheme();
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => WelcomeScreen()));
  }

  void getTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
      isDarkModeEnabled = prefs.getBool("isDarkMode");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        elevation: 0,
        iconTheme:
            IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              children: [
                HeaderText(
                  headerTitle: "Profile",
                  color: isDarkMode ? textColorDark : textColorLight,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "User ID: " + userID,
                  style: TextStyle(
                    color: isDarkMode ? subTitleDark : subTitleLight,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Email: " + email.toString(),
                      style: TextStyle(
                        color: isDarkMode ? subTitleDark : subTitleLight,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    prefs.getString("email") != null
                        ? Text("")
                        : IconButton(
                            icon: Icon(
                              SFSymbols.pencil,
                              color: isDarkMode ? subTitleDark : subTitleLight,
                            ),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  CupertinoPageRoute(
                                      builder: (context) => EmailVerification(
                                          onTap: AdminFeedbackViewPage())));
                            })
                  ],
                ),
                Divider(
                  height: 25,
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => ForgotPassword(
                              onTap: AdminFeedbackViewPage(),
                            )));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 50,
                    width: size.width,
                    child: Row(
                      children: [
                        Icon(SFSymbols.lock,
                            size: textHeaderSize,
                            color: isDarkMode ? iconColorDark : iconColorLight),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Change Password",
                          style: TextStyle(
                              color:
                                  isDarkMode ? textColorDark : textColorLight,
                              fontSize: textBodySize,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    clearPrefs();
                    Navigator.of(context).pushReplacement(CupertinoPageRoute(
                      builder: (context) => WelcomeScreen(),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 50,
                    width: size.width,
                    child: Row(
                      children: [
                        Icon(
                          SFSymbols.square_arrow_right,
                          size: textHeaderSize,
                          color: isDarkMode ? iconColorDark : iconColorLight,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Logout",
                          style: TextStyle(
                              color:
                                  isDarkMode ? textColorDark : textColorLight,
                              fontSize: textBodySize,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      SFSymbols.moon_fill,
                      size: textHeaderSize,
                      color: isDarkMode ? iconColorDark : iconColorLight,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Enable Dark Mode",
                      style: TextStyle(
                          color: isDarkMode ? textColorDark : textColorLight,
                          fontSize: textBodySize,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CupertinoSwitch(
                      onChanged: (value) {
                        setTheme(value);
                      },
                      value: isDarkModeEnabled,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                LimitedBox(
                  maxHeight: 100,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    width: size.width,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: isDarkMode
                            ? waringBgColorDark.withOpacity(.3)
                            : warningBgColorLight.withOpacity(.3)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          SFSymbols.exclamationmark_triangle_fill,
                          color: isDarkMode ? iconColorDark : iconColorLight,
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          width: size.width * 0.8,
                          child: Text("App will restart after changing theme.",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? textColorDark
                                      : textColorLight,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.start),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
