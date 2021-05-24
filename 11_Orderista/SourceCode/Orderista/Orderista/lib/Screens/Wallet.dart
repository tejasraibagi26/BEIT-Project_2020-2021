import 'package:flutter/material.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wallet extends StatefulWidget {
  final String wallet;

  const Wallet({Key key, @required this.wallet}) : super(key: key);

  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  var userID, email = "";
  bool isDarkModeEnabled = false;
  bool isDarkMode = false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        elevation: 0,
        backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
        centerTitle: true,
        title: Text(
          "orderista",
          style: TextStyle(
            color: isDarkMode ? textColorDark : textColorLight,
          ),
        ),
        iconTheme: IconThemeData(
          color: isDarkMode ? iconColorDark : iconColorLight,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                headerTitle: "Wallet",
                color: isDarkMode ? textColorDark : textColorLight,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "User : $userID",
                style: TextStyle(
                  color: isDarkMode ? subTitleDark : subTitleLight,
                  fontSize: 16,
                ),
              ),
              Divider(
                height: 25,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Total amount in wallet",
                style: TextStyle(
                  color: isDarkMode ? subTitleDark : subTitleLight,
                  fontSize: textBodySize,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Rs. ${widget.wallet}",
                style: TextStyle(
                  color: isDarkMode ? textColorDark : textColorLight,
                  fontSize: 32,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
