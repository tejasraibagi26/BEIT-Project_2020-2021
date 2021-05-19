import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/Admin/AdminFeedback.dart';
import 'package:orderista/Canteen/CanteenRoot.dart';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Root/root_app.dart';
import 'package:orderista/Module/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class EmailVerification extends StatefulWidget {
  EmailVerification({this.onTap});

  final Widget onTap;

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  bool isDarkMode = false;
  bool isOTPSent = false;
  bool isWaiting = false;

  String role = "";

  TextEditingController _email = new TextEditingController();
  TextEditingController _otp = new TextEditingController();

  String message = "";
  String prefsEmail = "";

  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    getEmail();
    getTheme();
    getUserRole();
  }

  void getEmail() async {
    prefs = await SharedPreferences.getInstance();
    prefsEmail = prefs.getString("email");
    setState(() {
      _email.text = prefsEmail;
    });
  }

  void getTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void getUserRole() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString("userRole");
    });
  }

  void verifyOTP() async {
    if (_otp.text.isNotEmpty) {
      setState(() {
        message = "";
      });
      var data = {
        "email": _email.value.text,
        "otp": int.parse(_otp.value.text)
      };

      var result = await httpPost('api/v1/auth/verify-otp', data);
      if (result["status"] == 200) {
        setState(() {
          message = "Email Verified";
        });
        prefs.setString("email", _email.value.text);
        prefs.setBool("isEmailVerified", true);
        Navigator.of(context).pushReplacement(CupertinoPageRoute(
            builder: (context) => role == "student"
                ? MultiProvider(
                    providers: [
                      ChangeNotifierProvider<Cart>(create: (context) => Cart()),
                      ChangeNotifierProvider<Menu>(create: (context) => Menu())
                    ],
                    child: Root(),
                  )
                : role == "canteen"
                    ? CanteenRoot()
                    : AdminFeedbackViewPage()));
      } else {
        setState(() {
          message = "Incorrect OTP";
        });
      }
    } else {
      setState(() {
        message = "Email / OTP cannot be empty";
      });
    }
  }

  void sendOTP() async {
    if (_email.value.text.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_email.value.text)) {
      setState(() {
        message = "Enter Valid email";
      });
      return;
    }

    setState(() {
      isWaiting = true;
    });
    var data = {
      "email": _email.value.text,
      "userid": int.parse(prefs.getString('userID')),
      "otp_time": DateTime.now().toString(),
      "reason": "to verify email"
    };
    var isEmailPresent = await httpPost('api/v1/auth/check-email', data);
    if (isEmailPresent["code"] != 0) {
      var otp = await httpPost('api/v1/auth/send-otp', data);
      if (otp["status"] != 200) {
        setState(() {
          message = "Error sending OTP";
        });
      } else {
        setState(() {
          isWaiting = false;
          message = "OTP Sent";
          isOTPSent = true;
        });
      }
      setState(() {
        isWaiting = false;
      });
    } else {
      setState(() {
        message = "Email already exists";
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
        elevation: 0,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDarkMode ? iconColorDark : iconColorLight,
            size: 25,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => widget.onTap));
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeaderText(
                  headerTitle: 'Email Verification',
                  color: isDarkMode ? textColorDark : textColorLight,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  // initialValue: prefsEmail,
                  controller: _email,
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person,
                      color: isDarkMode ? iconColorDark : iconColorLight,
                    ),
                    hintText: "Enter Email",
                    hintStyle: TextStyle(
                      color: isDarkMode ? textColorDark : textColorLight,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: isDarkMode ? iconColorDark : iconColorLight),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                isOTPSent
                    ? TextFormField(
                        controller: _otp,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            SFSymbols.lock_fill,
                            color: isDarkMode ? iconColorDark : iconColorLight,
                          ),
                          hintText: "Enter OTP",
                          hintStyle: TextStyle(
                            color: isDarkMode ? textColorDark : textColorLight,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: isDarkMode
                                    ? iconColorDark
                                    : iconColorLight),
                          ),
                        ),
                      )
                    : Container(),
                isOTPSent
                    ? SizedBox(
                        height: 40,
                      )
                    : SizedBox(
                        height: 0,
                      ),
                Text(
                  message,
                  style: TextStyle(
                      color: isDarkMode ? textColorDark : textColorLight,
                      fontSize: 16),
                ),
                message == ""
                    ? SizedBox(
                        height: 0,
                      )
                    : SizedBox(
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
                        color: isDarkMode ? buttonColorDark : buttonColorLight,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(.20),
                              blurRadius: 20,
                              offset: Offset(0, 10))
                        ]),
                    child: isWaiting
                        ? isDarkMode
                            ? spinkit
                            : spinkitDark
                        : Text(
                            isOTPSent ? "Verify" : "Send OTP",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: textBodySize,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                  ),
                ),
                SizedBox(height: 10),
                isOTPSent
                    ? GestureDetector(
                        onTap: () {
                          sendOTP();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: 50,
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                                color:
                                    isDarkMode ? textColorDark : textColorLight,
                                fontSize: textBodySize - 4,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
