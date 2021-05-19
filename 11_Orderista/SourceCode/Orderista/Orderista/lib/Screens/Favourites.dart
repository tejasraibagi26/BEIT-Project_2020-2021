import 'package:lottie/lottie.dart';
import 'package:orderista/Common/FoodConstructor.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Widgets/FoodItem.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Favourites extends StatefulWidget {
  Favourites({Key key}) : super(key: key);

  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  List<Food> _foods = [];
  String userID;
  bool isDarkMode = false;
  bool isFavsChanged = false;

  @override
  void initState() {
    super.initState();
    if (Provider.of<Menu>(context, listen: false).favItems.length == 0) {
      retrieveFavs();
    }
    getTheme();
  }

  void getTheme() async {
    if (!this.mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void refresh() {
    retrieveFavs();
  }

  void retrieveFavs() async {
    if (!this.mounted) return;
    setState(() {
      isFavsChanged = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");
    var data = {"userid": int.parse(userID)};
    var favs = await httpPost('api/v1/fav/get-all-favs', data);
    var _favs = favs["favourite"];
    for (var u in _favs) {
      Food food = Food(
          id: u["id"],
          category: u["tag"],
          name: u["itemname"],
          price: u["cost"],
          imagePath: u["itemurl"]);

      Provider.of<Menu>(context, listen: false).favItems.add(food);

      // _foods.add(food);
    }

    setState(() {
      isFavsChanged = false;
    });
  }

  Future _refresh() async {
    Provider.of<Menu>(context, listen: false).favItems.clear();
    retrieveFavs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: RefreshIndicator(
        backgroundColor: cardColorDark,
        color: iconColorDark,
        onRefresh: _refresh,
        child: ListView(scrollDirection: Axis.vertical, children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderText(
                  headerTitle: "Favourites",
                  color: isDarkMode ? textColorDark : textColorLight,
                ),
                Divider(),
                isFavsChanged
                    ? Center(
                        child: Lottie.asset(
                          isDarkMode
                              ? 'images/loading-dark.json'
                              : 'images/loading.json',
                          height: 100,
                          width: 100,
                        ),
                      )
                    : Provider.of<Menu>(context, listen: false)
                                .favItems
                                .length !=
                            0
                        ? Consumer<Menu>(
                            builder: (context, favs, child) {
                              return Column(
                                  children:
                                      favs.favItems.map(_buildList).toList());
                            },
                          )
                        : Center(
                            child: Text(
                              'No Favourites Found',
                              style: TextStyle(
                                color:
                                    isDarkMode ? textColorDark : textColorLight,
                                fontSize: textBodySize,
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ]),
      ),
    );
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
