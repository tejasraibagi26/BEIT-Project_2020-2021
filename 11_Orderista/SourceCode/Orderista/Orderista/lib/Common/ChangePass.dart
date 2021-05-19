import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Common/login_screen.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/main.dart';
import 'package:orderista/Module/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({this.onTap});

  final Widget onTap;
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  bool isDarkMode = false;
  bool isObscure = true;
  bool isLoading = false;

  String message = "";

  TextEditingController _password = new TextEditingController();
  TextEditingController _password2 = new TextEditingController();

  void initState() {
    super.initState();
    getTheme();
  }

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void _onPressed() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  void _changePassword() async {
    if (_password.value.text != _password2.value.text) {
      setState(() {
        message = "Password Not Matched.";
      });
    } else {
      setState(() {
        message = "";
        isLoading = true;
      });

      var data = {
        "password": _password.value.text,
        "userid": int.parse(prefs.getString("userID"))
      };

      var res = await httpPost('api/v1/auth/change-password', data);

      setState(() {
        isLoading = false;
      });

      prefs.clear();
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
          padding: const EdgeInsets.all(40.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeaderText(
                  headerTitle: 'Change Password',
                  color: isDarkMode ? textColorDark : textColorLight,
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                  obscureText: isObscure,
                  controller: _password,
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      SFSymbols.lock_fill,
                      color: isDarkMode ? iconColorDark : iconColorLight,
                    ),
                    suffixIcon: IconButton(
                      onPressed: _onPressed,
                      icon: Icon(
                        isObscure
                            ? SFSymbols.eye_fill
                            : SFSymbols.eye_slash_fill,
                        color: isDarkMode ? iconColorDark : iconColorLight,
                      ),
                    ),
                    hintText: "Enter Password",
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
                TextFormField(
                  obscureText: isObscure,
                  controller: _password2,
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      SFSymbols.lock_fill,
                      color: isDarkMode ? iconColorDark : iconColorLight,
                    ),
                    hintText: "Enter Password Again",
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
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: textBodySize - 4,
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
                  onTap: _changePassword,
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
                    child: !isLoading
                        ? Text(
                            "Change Password",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: textBodySize,
                                fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          )
                        : isDarkMode
                            ? spinkitDark
                            : spinkit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
