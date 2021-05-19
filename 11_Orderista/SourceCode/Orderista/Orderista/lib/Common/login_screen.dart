//Import all required packagaes
import 'package:flutter/scheduler.dart';
import 'package:orderista/Admin/AdminRoot.dart';
import 'package:orderista/Canteen/CanteenRoot.dart';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Root/root_app.dart';
import 'package:orderista/Common/forgot_pass.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;
  bool _isLoading = false;
  TextEditingController moodleidController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  String _customMessage = "";
  bool isDarkMode = false;
  SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getTheme();
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

  login() async {
    if (this.mounted) {
      setState(() {
        _customMessage = "";
      });
    }
    var data = {
      "moodleid": moodleidController.text,
      "password": passwordController.text
    };

    var result = await httpPost("api/v1/auth/login", data);

    setState(() {
      _isLoading = !_isLoading;
    });
    if (result["status"] == 200) {
      //Set the prefs variable with the userID
      prefs = await SharedPreferences.getInstance();
      prefs.setString("userID", moodleidController.text);
      prefs.setString("userRole", result["role"]);
      prefs.setString("email", result["email"]);

      //Navigate to the homepage based on the role provided.
      if (result["role"] != "admin") {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => MultiProvider(
              providers: [
                ChangeNotifierProvider<Cart>(create: (context) => Cart()),
                ChangeNotifierProvider<Menu>(create: (context) => Menu()),
              ],
              child: result["role"] == "student" ? Root() : CanteenRoot(),
            ),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => AdminRoot(),
          ),
        );
      }
    } else {
      setState(() {
        _customMessage = result["message"].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HeaderText(
                  headerTitle: 'LOGIN',
                  color: isDarkMode ? textColorDark : textColorLight,
                ),
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                        controller: moodleidController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter Moodle ID';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: isDarkMode ? iconColorDark : iconColorLight,
                          ),
                          hintText: "Enter Moodle ID",
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? textColorDark.withOpacity(0.6)
                                : textColorLight.withOpacity(0.6),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color:
                                    isDarkMode ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Password cannot be empty';
                          }

                          return null;
                        },
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                        controller: passwordController,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            color: isDarkMode ? iconColorDark : iconColorLight,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            },
                            icon: _isObscure
                                ? Icon(
                                    Icons.visibility,
                                    color: isDarkMode
                                        ? iconColorDark
                                        : iconColorLight,
                                  )
                                : Icon(Icons.visibility_off,
                                    color: isDarkMode
                                        ? iconColorDark
                                        : iconColorLight),
                          ),
                          hintText: "Password",
                          hintStyle: TextStyle(
                              color: isDarkMode
                                  ? textColorDark.withOpacity(0.6)
                                  : textColorLight.withOpacity(0.6),
                              fontSize: 20,
                              fontWeight: FontWeight.w500),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ForgotPassword(
                              onTap: LoginScreen(),
                              source: "login",
                            ),
                          ));
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                fontSize: textBodySize - 4,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode
                                    ? textColorDark
                                    : textColorLight),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        _customMessage,
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            login();
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color:
                                isDarkMode ? buttonColorDark : buttonColorLight,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12.withOpacity(.2),
                                  blurRadius: 20,
                                  offset: Offset(0, 10)),
                            ],
                          ),
                          child: _isLoading
                              ? spinkit
                              : Text(
                                  "LOGIN",
                                  style: TextStyle(
                                      letterSpacing: 2.0,
                                      color: Colors.white,
                                      fontSize: textBodySize,
                                      fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                    ],
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
