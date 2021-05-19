import 'package:orderista/Common/Banner.dart';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Root/root_app.dart';
import 'package:orderista/Common/EmailVerfication.dart';
import 'package:orderista/Common/forgot_pass.dart';
import 'package:orderista/Common/welcome_screen.dart';
import 'package:orderista/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orderista/main.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var userID = "";
  var email = "";
  String msg = "";

  bool isDarkModeEnabled = false;
  bool isDarkMode = false;
  bool isVerifying = false;
  bool isOTPSent = false;

  TextEditingController _email = new TextEditingController();
  TextEditingController _otp = new TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    if (prefs.getBool("isEmailVerified") == null) {
      prefs.setBool("isEmailVerified", false);
    }
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
      isDarkModeEnabled = prefs.getBool("isDarkMode");
    });
  }

  void sendOTP() async {}

  void verifyOTP() async {}

  void emailScreen() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(10.0),
            scrollable: true,
            backgroundColor: isDarkMode ? cardColorDark : cardColorLight,
            title: Text(
              "Email",
              style: TextStyle(
                color: isDarkMode ? textColorDark : textColorLight,
                fontSize: textBodySize,
              ),
            ),
            actions: <Widget>[],
            content: StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  height: isOTPSent ? 200 : 155,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black),
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  SFSymbols.envelope_fill,
                                  color: isDarkMode
                                      ? iconColorDark
                                      : iconColorLight,
                                  size: 22,
                                ),
                                hintText: "Enter Email",
                                hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? textColorDark.withOpacity(0.6)
                                      : textColorLight.withOpacity(0.6),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            isOTPSent
                                ? TextFormField(
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.black),
                                    controller: _otp,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        SFSymbols.lock_fill,
                                        color: isDarkMode
                                            ? iconColorDark
                                            : iconColorLight,
                                        size: 22,
                                      ),
                                      hintText: "Enter OTP",
                                      hintStyle: TextStyle(
                                        color: isDarkMode
                                            ? textColorDark.withOpacity(0.6)
                                            : textColorLight.withOpacity(0.6),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          isOTPSent ? verifyOTP() : sendOTP();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12.withOpacity(.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)),
                            ],
                          ),
                          child: !isVerifying
                              ? Text(
                                  isOTPSent ? "VERIFY" : "SEND OTP",
                                  style: TextStyle(
                                      letterSpacing: 2.0,
                                      color: Colors.white,
                                      fontSize: textBodySize,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                )
                              : isDarkMode
                                  ? spinkitDark
                                  : spinkit,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        this.msg,
                        style: TextStyle(
                            color: isDarkMode ? textColorDark : textColorLight),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: size.height,
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
                SizedBox(
                  height: 5,
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
                                      onTap: MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider<Cart>(
                                          create: (context) => Cart()),
                                      ChangeNotifierProvider<Menu>(
                                          create: (context) => Menu())
                                    ],
                                    child: Root(),
                                  )),
                                ),
                              );
                            })
                  ],
                ),
                Divider(
                  height: 25,
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    const snackbar = SnackBar(
                      content: Text("Wallet under maintenance"),
                      duration: Duration(seconds: 1),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    // Fluttertoast.showToast(
                    //     msg: "Wallet is under maintenance",
                    //     fontSize: textBodySize,
                    //     gravity: ToastGravity.BOTTOM,
                    //     backgroundColor:
                    //         isDarkMode ? cardColorDark : Colors.black,
                    //     textColor: isDarkMode ? textColorDark : Colors.white,
                    //     toastLength: Toast.LENGTH_LONG);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 50,
                    width: size.width,
                    child: Row(
                      children: [
                        Icon(
                          SFSymbols.money_dollar,
                          size: textHeaderSize,
                          color: isDarkMode ? iconColorDark : iconColorLight,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Wallet",
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
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => ForgotPassword(
                            source: "profile",
                            onTap: MultiProvider(
                              providers: [
                                ChangeNotifierProvider<Cart>(
                                  create: (context) => Cart(),
                                ),
                                ChangeNotifierProvider<Menu>(
                                  create: (context) => Menu(),
                                )
                              ],
                              child: Root(),
                            ))));
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
                BannerAlert(
                    size: size,
                    isDarkMode: isDarkMode,
                    bannerText: "App will restart after changing theme.")
              ],
            ),
          ),
        ),
      ),
    );
  }
}
