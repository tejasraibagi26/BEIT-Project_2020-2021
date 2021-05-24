import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:orderista/Common/404.dart';
import 'package:orderista/Common/Banner.dart';
import 'package:orderista/Common/FoodConstructor.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Screens/ServerMessagesAlert.dart';
import 'package:orderista/Widgets/FoodItem.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/main.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var recentOrder = [];
  var listFeedback = [];
  var listFeedbackOrders = [];
  var serverMsg = [];
  var suggestions = [];
  var most = [];
  var _menuList = [];
  var searchList = [];

  String query = "";

  TextEditingController _searchController = new TextEditingController();

  double rating = 5.0;

  bool _isFetching = false;
  bool isDarkMode = false;
  bool _isEmailVerified = false;
  bool isNewServerMsg = false;

  @override
  void initState() {
    super.initState();
    getPrefs();
    checkInternet();
    getTheme();
  }

  void getPrefs() async {
    if (this.mounted) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getString("email") != null) {
        setState(() {
          _isEmailVerified = true;
        });
      } else {
        setState(() {
          _isEmailVerified = false;
        });
      }

      if (prefs.getString("serverMessageID") == null) {
        prefs.setString("serverMessageID", "");
      }
    }
  }

  void checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (Provider.of<Menu>(context, listen: false).foodItems.length == 0) {
          retrieveMenu();
        }

        getServerMsg();
        if (this.mounted) {
          if (prefs.getBool('shouldCheckFeedbackStatus') != null &&
              prefs.getBool('shouldCheckFeedbackStatus'))
            checkForFeebackPopUp();
        }
      }
    } on SocketException catch (_) {
      Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => NoInternet()));
    }
  }

  void getServerMsg() async {
    var msg = await httpGet('api/v1/message/get-message');
    serverMsg = msg["data"];
    if (serverMsg[0]["msg_id"] == prefs.getString("serverMessageID")) {
      if (this.mounted) {
        setState(() {
          isNewServerMsg = false;
        });
      }
    } else {
      if (this.mounted) {
        setState(() {
          isNewServerMsg = true;
          prefs.setString("serverMessageID", serverMsg[0]["msg_id"]);
        });
      }
    }
    if (isNewServerMsg) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => ServerMessagesAlert(
                msgAuthor: serverMsg[0]["msg_author"],
                msgBody: serverMsg[0]["msg_body"],
                msgID: serverMsg[0]["msg_id"],
                msgLink: serverMsg[0]["msg_link"],
                msgTitle: serverMsg[0]["msg_title"],
              )));
    }
  }

  void getTheme() async {
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    if (this.mounted) {
      setState(() {
        isDarkMode = prefs.getBool("isDarkMode");
      });
    }
  }

  void retrieveMenu() async {
    if (this.mounted) {
      setState(() {
        _isFetching = true;
      });
      var menu = await httpGet("api/v1/menu/food");
      _menuList = menu["menu"];
      for (var u in _menuList) {
        Food food = Food(
            id: u["dishid"],
            category: u["dishtag"],
            name: u["dishname"],
            price: u["dishcost"],
            imagePath: u["dishimage"]);

        Provider.of<Menu>(context, listen: false).addFoodItemsToProvider(food);
      }

      setState(() {
        _isFetching = false;
      });

      prefs.setBool("shouldFetchMenu", false);
    }
  }

  void checkForFeebackPopUp() async {
    int userid = int.parse(prefs.getString('userID'));
    var data = {"userid": userid};
    var result = await httpPost('api/v1/feedback/get-feedback-status', data);
    listFeedback = result["data"];
    if (listFeedback == null) return;
    if (listFeedback != null) listFeedbackOrders = result["data"][0]["orders"];
    if (listFeedback[0]["feedback_status"] == false) {
      prefs.setBool('shouldCheckFeedbackStatus', true);
    }

    if (!listFeedback[0]["feedback_status"]) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16, color: Colors.redAccent),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () async {
                    var orderid = listFeedback[0]["orderid"];
                    var data = {
                      'orderid': orderid,
                      'rating': rating,
                    };
                    await httpPost('api/v1/feedback/rating', data);
                    Navigator.of(context).pop();
                  },
                ),
              ],
              content: Builder(
                builder: (context) {
                  return Flexible(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: listFeedbackOrders.length <= 2
                          ? 200
                          : MediaQuery.of(context).size.height * 0.35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderText(
                            headerTitle: 'Feedback',
                            color: isDarkMode ? textColorDark : textColorLight,
                          ),
                          Divider(
                            color: isDarkMode ? iconColorDark : iconColorLight,
                          ),
                          LimitedBox(
                            maxHeight: 210,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: listFeedbackOrders.length,
                                  itemBuilder: (context, index) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          json.decode(listFeedback[0]["orders"]
                                              [index])["name"],
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? textColorDark
                                                : textColorLight,
                                            fontSize: textBodySize,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          width: 40,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: isDarkMode
                                                  ? Colors.black.withOpacity(.2)
                                                  : Colors.blueGrey
                                                      .withOpacity(.2),
                                              borderRadius:
                                                  BorderRadius.circular(9)),
                                          child: Text(
                                            "x" +
                                                json
                                                    .decode(listFeedback[0]
                                                            ["orders"]
                                                        [index])["quantity"]
                                                    .toString(),
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: isDarkMode
                                                    ? textColorDark
                                                    : textColorLight),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SmoothStarRating(
                                allowHalfRating: false,
                                onRated: (v) {
                                  this.rating = v;
                                  setState(() {
                                    rating = v;
                                  });
                                },
                                starCount: 5,
                                rating: rating,
                                size: 35.0,
                                filledIconData: SFSymbols.star_fill,
                                color: Colors.orange,
                                borderColor: Colors.grey,
                                spacing: 2.0),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              backgroundColor: isDarkMode ? cardColorDark : cardColorLight,
            );
          });
    }

    prefs.setBool('shouldCheckFeedbackStatus', false);
  }

  void onSearch(String text) {
    this.setState(() {
      query = text;
    });
    List food = Provider.of<Menu>(context, listen: false).foodItems;
    List foodItems = [];
    for (int i = 0; i < food.length; i++) {
      Food foods = food[i];
      var data = {
        "name": foods.name,
        "imagePath": foods.imagePath,
        "cost": foods.price,
        "tag": foods.category,
        "id": foods.id,
      };
      foodItems.add(data);
    }
    searchList = foodItems.where((foodItem) {
      var foodInSearch = foodItem["name"].toLowerCase();
      return foodInSearch.contains(query.toLowerCase());
    }).toList();
  }

  Future _refresh() async {
    Provider.of<Menu>(context, listen: false).foodItems.clear();
    retrieveMenu();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: isDarkMode ? cardColorDark : cardColorLight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: size.width * 0.8,
                      child: TextFormField(
                        controller: _searchController,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search here!",
                          hintStyle: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          contentPadding: EdgeInsets.all(10),
                          border: new OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (text) {
                          onSearch(text);
                        },
                      ),
                    ),
                    query != ""
                        ? IconButton(
                            icon: Icon(
                              SFSymbols.multiply,
                              color:
                                  isDarkMode ? iconColorDark : iconColorLight,
                            ),
                            onPressed: () {
                              setState(() {
                                query = "";
                                _searchController.clear();
                              });
                            })
                        : Container()
                  ],
                ),
              ),
            ),
            !_isEmailVerified
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 20.0),
                    child: BannerAlert(
                        size: size,
                        isDarkMode: isDarkMode,
                        bannerText:
                            "Please Add / Verify your Email from Profile Page."),
                  )
                : Container(),
            RefreshIndicator(
              backgroundColor: cardColorDark,
              color: iconColorDark,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: _refresh,
              child: Container(
                height:
                    _isEmailVerified ? size.height * 0.7 : size.height * 0.62,
                child: ListView(
                    scrollDirection: Axis.vertical,
                    physics: BouncingScrollPhysics(),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              "Fooood For Everyone!",
                              style: TextStyle(
                                fontSize: textBodySize,
                                color:
                                    isDarkMode ? textColorDark : textColorLight,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          !_isFetching
                              ? Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: query == ""
                                      ? Consumer<Menu>(
                                          builder: (context, menu, child) {
                                            return Column(
                                                children: menu.foodItems
                                                    .map(_buildList)
                                                    .toList());
                                          },
                                        )
                                      : LimitedBox(
                                          maxHeight: size.height * 0.65,
                                          child: ListView.builder(
                                              physics: BouncingScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: searchList.length,
                                              itemBuilder: (context, index) {
                                                return FoodItem(
                                                  name: searchList[index]
                                                      ["name"],
                                                  id: searchList[index]["id"],
                                                  imagePath: searchList[index]
                                                      ["imagePath"],
                                                  cost: searchList[index]
                                                      ["cost"],
                                                  tag: searchList[index]["tag"],
                                                );
                                              }),
                                        ),
                                )
                              : Center(
                                  child: Lottie.asset(
                                    isDarkMode
                                        ? 'images/loading-dark.json'
                                        : 'images/loading.json',
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                        ],
                      )
                    ]),
              ),
            ),
          ],
        ));
  }
}

Widget _buildList(Food food) {
  return FoodItem(
    name: food.name,
    id: food.id,
    cost: food.price,
    tag: food.category,
    imagePath: food.imagePath,
  );
}
