import 'package:flutter/services.dart';
import 'package:orderista/Admin/FoodRatingsFeedback.dart';
import 'package:orderista/Admin/OverallFeedback.dart';
import 'package:orderista/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminFeedbackViewPage extends StatefulWidget {
  @override
  _AdminFeedbackViewPageState createState() => _AdminFeedbackViewPageState();
}

class _AdminFeedbackViewPageState extends State<AdminFeedbackViewPage> {
  bool isDarkMode = false;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        // systemNavigationBarColor: Colors.white,
        // statusBarColor: Colors.white,
      ),
    );
    getTheme();
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            brightness: isDarkMode ? Brightness.dark : Brightness.light,
            elevation: 0,
            backgroundColor: Colors.transparent,
            bottom: TabBar(
              unselectedLabelColor: isDarkMode ? subTitleDark : subTitleLight,
              labelColor: isDarkMode ? textColorDark : textColorLight,
              indicatorColor: isDarkMode ? Colors.white : Colors.black,
              tabs: [
                Tab(
                  text: 'Feedback',
                ),
                Tab(
                  text: 'Rating',
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [OverallFeedback(), FoodRatingsFeedback()],
          ),
        ),
      ),
    );
  }
}
