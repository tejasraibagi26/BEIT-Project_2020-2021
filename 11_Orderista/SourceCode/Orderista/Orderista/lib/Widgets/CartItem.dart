import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem extends StatefulWidget {
  const CartItem(
      {Key key,
      this.tag,
      this.cost,
      this.imagePath,
      this.id,
      this.name,
      this.quantity})
      : super(key: key);

  final String name, tag, imagePath, id;
  final int cost, quantity;

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  bool isDarkMode = false;

  @override
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
            spreadRadius: 1,
            blurRadius: 42,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                    width: 125,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                              color:
                                  isDarkMode ? textColorDark : textColorLight,
                              fontSize: 15),
                        ),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          "Rs " + widget.cost.toString(),
                          style: TextStyle(
                            color: isDarkMode ? textColorDark : textColorLight,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Provider.of<Cart>(context, listen: false)
                                .decrementQuantity(widget.id);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 15),
                            padding: EdgeInsets.all(5),
                            width: 25,
                            alignment: Alignment.topRight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: Text(
                                "-",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            margin: EdgeInsets.only(left: 15),
                            // padding: EdgeInsets.all(10),
                            alignment: Alignment.topRight,
                            // decoration: BoxDecoration(
                            //   color: Colors.white,
                            // ),
                            child: Text(
                              widget.quantity.toString(),
                              style: TextStyle(
                                  fontSize: 25,
                                  color: isDarkMode
                                      ? textColorDark
                                      : textColorLight),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Provider.of<Cart>(context, listen: false)
                                .incrementQuantity(widget.id);
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 15),
                            padding: EdgeInsets.all(5),
                            width: 25,
                            alignment: Alignment.topRight,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: Text(
                                "+",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Provider.of<Cart>(context, listen: false)
                            .deleteItem(widget.id);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 15),
                        padding: EdgeInsets.all(5),
                        alignment: Alignment.center,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              SFSymbols.trash_fill,
                              color: Colors.white,
                            ),
                            Text(
                              " Delete",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Container(
//       margin: EdgeInsets.symmetric(vertical: 10),
//       height: size.height * .13,
//       width: size.width,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(9),
//         // color: Colors.blue,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                 width: size.width * 0.25,
//                 height: size.height * 0.13,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(9),
//                   child: Image.network(
//                     _menuList[index]["dishimage"].toString(),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: 20,
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 125,
//                     child: Text(
//                       _menuList[index]["dishname"].toString(),
//                       maxLines: 10,
//                       style: TextStyle(
//                         color: darkModeButtonTextColor,
//                         fontSize: 15,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     _menuList[index]["dishtag"].toString(),
//                     style: TextStyle(color: Colors.black45, fontSize: 15),
//                   ),
//                   SizedBox(
//                     height: 3,
//                   ),
//                   Text(
//                     "Rs " + _menuList[index]["dishcost"].toString(),
//                     style: TextStyle(
//                       color: darkModeButtonTextColor,
//                       fontSize: 15,
//                     ),
//                   ),
//                 ],
//               ),
//               Container(
//                 margin: EdgeInsets.only(left: 15),
//                 padding: EdgeInsets.all(10),
//                 alignment: Alignment.topRight,
//                 decoration: BoxDecoration(
//                     border: Border.all(color: Colors.greenAccent, width: 2),
//                     borderRadius: BorderRadius.circular(9)),
//                 child: Text(
//                   "Add to cart",
//                   style: TextStyle(fontSize: 10),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     )
