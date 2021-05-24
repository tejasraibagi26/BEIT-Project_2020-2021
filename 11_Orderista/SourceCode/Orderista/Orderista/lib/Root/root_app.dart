import 'dart:async';

import 'package:orderista/Common/InternetCheck.dart';
import 'package:orderista/Screens/Favourites.dart';
import 'package:orderista/Screens/Feedback.dart';
import 'package:orderista/Screens/OrderHistory.dart';
import 'package:orderista/Screens/homepage.dart';
import 'package:orderista/Screens/Cart.dart';
import 'package:orderista/Screens/order_page.dart';
import 'package:orderista/Screens/profile.dart';
import 'package:orderista/Screens/AI.dart';
import 'package:orderista/constants.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  int activeTab = 0;
  bool isDarkMode = false;

  List<Widget> _tabs = [
    HomePage(),
    Favourites(),
    OrderHistory(),
    CartPage(),
    AIRecco(),
    Profile(),
    OrderPage(),
    FeedbackPage()
  ];

  Timer timer;

  @override
  void initState() {
    super.initState();
    getTheme();

    timer = Timer.periodic(
        Duration(seconds: 10), (Timer t) => checkInternet(context));
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        toolbarHeight: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "orderista",
          style: TextStyle(color: isDarkMode ? textColorDark : textColorLight),
        ),
        leading: IconButton(
          onPressed: () {
            setState(() {
              activeTab = 4;
            });
          },
          icon: Icon(SFSymbols.sparkles),
          color: activeTab == 4
              ? Colors.green
              : isDarkMode
                  ? textColorDark
                  : textColorLight,
          splashColor: Colors.transparent,
          splashRadius: 0.1,
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                activeTab = 5;
              });
            },
            icon: Icon(SFSymbols.person_fill),
            color: activeTab == 5
                ? Colors.green
                : isDarkMode
                    ? textColorDark
                    : textColorLight,
            splashColor: Colors.transparent,
            splashRadius: 0.1,
          ),
          IconButton(
            onPressed: () {
              setState(() {
                activeTab = 7;
              });
            },
            icon: Icon(SFSymbols.info_circle_fill),
            color: activeTab == 7
                ? Colors.green
                : isDarkMode
                    ? textColorDark
                    : textColorLight,
            splashColor: Colors.transparent,
            splashRadius: 0.1,
          ),
        ],
      ),
      body: PageTransitionSwitcher(
        transitionBuilder: (Widget child, Animation<double> primaryAnimation,
            Animation<double> secondaryAnimation) {
          return SharedAxisTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
        child: _tabs[activeTab],
        // index: activeTab,
        // children: _tabs,
      ),
      floatingActionButton: activeTab != 0 ? null : getFAB(),
      bottomNavigationBar: getBottomBar(),
    );
  }

  Widget getFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        setState(() {
          activeTab = 6;
        });
      },
      icon: Icon(
        SFSymbols.bag_fill,
        color: Colors.white,
      ),
      label: Text(
        "ORDERS",
        // style: TextStyle(letterSpacing: 0),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget getBottomBar() {
    List activeTabs = [
      SFSymbols.house_fill,
      SFSymbols.heart_fill,
      SFSymbols.arrow_counterclockwise_circle_fill,
      SFSymbols.cart_fill
    ];
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 70,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(top: 0, bottom: 10, left: 15, right: 15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.black,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(activeTabs.length, (index) {
                return IconButton(
                    icon: Icon(
                      activeTabs[index],
                      size: activeTab == index ? 28 : 25,
                      color: activeTab == index ? Colors.white : Colors.white38,
                    ),
                    onPressed: () {
                      setState(() {
                        activeTab = index;
                      });
                    });
              }),
            ),
          ),
        ),
      ),
    );
  }
}
