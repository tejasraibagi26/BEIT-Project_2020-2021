import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/Common/Banner.dart';
import 'package:orderista/Common/ChangePass.dart';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Root/root_app.dart';
import 'package:orderista/Module/http.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class ForgotPassword extends StatefulWidget {
  ForgotPassword({this.onTap, this.source});

  final Widget onTap;
  final String source;

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  bool isDarkMode = false;
  bool isOTPSent = false;
  bool isWaiting = false;

  TextEditingController _email = new TextEditingController();
  TextEditingController _otp = new TextEditingController();
  TextEditingController _userid = new TextEditingController();

  String message = "";
  String prefsEmail = "";
  int userid;

  SharedPreferences prefs;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getEmail();
    getTheme();
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

  void verifyOTP() async {
    var data = {"email": _email.value.text, "otp": int.parse(_otp.value.text)};

    var verified = await httpPost('api/v1/auth/verify-otp', data);
    setState(() {
      isWaiting = false;
    });
    if (verified["status"] == 200) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: ChangePassword(
            onTap: widget.onTap,
          ),
          alignment: Alignment.center,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
      );
    } else {
      setState(() {
        message = "Incorrect OTP";
      });
    }
  }

  void sendOTP() async {
    if (_email.value.text.isEmpty ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(_email.value.text)) {
      setState(() {
        message = "Enter valid email";
      });
      return;
    }

    setState(() {
      message = "";
      isWaiting = true;
    });

    if (widget.source == "login") {
      userid = int.parse(_userid.value.text);
    } else {
      userid = int.parse(prefs.getString("userID"));
    }

    var data = {
      "email": _email.value.text,
      "userid": userid,
      "otp_time": DateTime.now().toString(),
      "reason": "to change password",
      "source": widget.source,
    };
    var otp = await httpPost('api/v1/auth/send-otp', data);

    print(otp);

    if (otp["status"] == 200) {
      setState(() {
        isOTPSent = true;
        message = "OTP Sent";
        isWaiting = false;
      });
    } else {
      setState(() {
        isOTPSent = false;
        message = otp["msg"];
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeaderText(
                  headerTitle: 'Forgot Password',
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
                      Icons.email,
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
                widget.source == 'login'
                    ? TextFormField(
                        // initialValue: prefsEmail,
                        controller: _userid,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: isDarkMode ? iconColorDark : iconColorLight,
                          ),
                          hintText: "Enter Moodle ID",
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
                SizedBox(
                  height: 20,
                ),
                isOTPSent
                    ? Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: _otp,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Please Enter Valid OTP.";
                            }
                            return null;
                          },
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              SFSymbols.lock_fill,
                              color:
                                  isDarkMode ? iconColorDark : iconColorLight,
                            ),
                            hintText: "Enter OTP",
                            hintStyle: TextStyle(
                              color:
                                  isDarkMode ? textColorDark : textColorLight,
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
                    color: Colors.red,
                    fontSize: 16,
                  ),
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
                    if (isOTPSent) {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          isWaiting = true;
                        });
                        verifyOTP();
                      } else
                        return;
                    } else
                      sendOTP();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
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
                            ? spinkitDark
                            : spinkit
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
                SizedBox(
                  height: 20,
                ),
                BannerAlert(
                    size: size,
                    isDarkMode: isDarkMode,
                    bannerText:
                        "If you haven't added email, contact admin for assistance."),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
