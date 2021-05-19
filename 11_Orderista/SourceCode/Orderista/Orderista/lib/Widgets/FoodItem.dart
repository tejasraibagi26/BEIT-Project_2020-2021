import 'dart:async';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodItem extends StatefulWidget {
  const FoodItem(
      {Key key, this.tag, this.cost, this.imagePath, this.id, this.name})
      : super(key: key);

  final String name, tag, imagePath, id;
  final int cost;

  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  bool isAdded = false;
  String userid;
  bool isFav = false;
  bool shouldSetFav = false;
  bool isDarkMode = false;

  Timer timer;

  void initState() {
    super.initState();
    getTheme();
    getFavs(widget.name);

    // timer = Timer.periodic(
    //     Duration(seconds: 15), (Timer t) => getFavs(widget.name));
  }

  // @override
  // void dispose() {
  //   timer?.cancel();
  //   super.dispose();
  // }

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

  void setFav() {
    if (!this.mounted) return;
    setState(() {
      shouldSetFav = true;
    });
  }

  void getFavs(String item) async {
    if (!this.mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userid = prefs.getString("userID");
    String itemName = item;
    int cost = widget.cost;
    String itemURL = widget.imagePath;
    String tag = widget.tag;
    String id = widget.id;

    var data = {"userid": int.parse(userid), "itemName": itemName};
    var favs = await httpPost("api/v1/fav/get-favs", data);
    if (this.mounted) {
      if (favs["favs"]) {
        if (this.mounted) {
          setState(() {
            isFav = true;
          });
        }
      } else if (!favs["favs"] && shouldSetFav) {
        var favData = {
          "userid": userid,
          "itemName": itemName,
          "cost": cost,
          "tag": tag,
          "itemURL": itemURL,
          "id": id
        };
        var favs = await httpPost("api/v1/fav/favs", favData);
        if (favs["status"] == 200) {
          if (this.mounted) {
            setState(() {
              isFav = true;
              shouldSetFav = false;
            });
          }
        }
      }
      if (favs["favs"] && shouldSetFav) {
        var removeData = {"userid": userid, "itemName": itemName};
        var favs = await httpPost("api/v1/fav/remove-favs", removeData);
        if (this.mounted) {
          setState(() {
            isFav = false;
            shouldSetFav = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      key: Key(widget.id),
      margin: EdgeInsets.symmetric(vertical: 10),
      // height: size.height * .15,
      width: size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: isDarkMode ? cardColorDark : cardColorLight,
        boxShadow: [
          BoxShadow(
            color: Colors.black26.withOpacity(.1),
            spreadRadius: 0,
            blurRadius: 42,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: size.width * 0.25,
                height: size.height * 0.13,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: Image.network(
                    widget.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Container(
                width: size.width * .45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 10,
                      style: TextStyle(
                        color: isDarkMode ? textColorDark : textColorLight,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      widget.tag,
                      style: TextStyle(
                          color: isDarkMode ? textColorDark : textColorLight,
                          fontSize: 15),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Text(
                      "\u20B9 " + widget.cost.toString(),
                      style: TextStyle(
                        color: isDarkMode ? textColorDark : textColorLight,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: isFav
                        ? Icon(SFSymbols.heart_fill)
                        : Icon(SFSymbols.heart),
                    color: isFav
                        ? Colors.redAccent
                        : isDarkMode
                            ? Colors.white
                            : Colors.black,
                    onPressed: () {
                      setFav();
                      getFavs(widget.name);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      var cartItem = {
                        "itemID": widget.id,
                        "itemName": widget.name,
                        "itemCost": widget.cost,
                        "itemTag": widget.tag,
                        "itemImagePath": widget.imagePath,
                        "itemQuantity": 1
                      };

                      Provider.of<Cart>(context, listen: false)
                          .addToCart(cartItem);

                      Fluttertoast.showToast(
                          msg: "Added to Cart: " + widget.name,
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 4);
                    },
                    child: Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(
                              SFSymbols.cart_fill,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Add",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white),
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
