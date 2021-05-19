import 'package:flutter/material.dart';
import '../constants.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      elevation: 0,
      currentIndex: 0,
      selectedItemColor: primaryColor,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.black,
            ),
            label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.favorite, color: Colors.black), label: "Favorite"),
        BottomNavigationBarItem(
            icon: Icon(Icons.list, color: Colors.black), label: "Orders"),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart, color: Colors.black),
            label: "Cart"),
      ],
    );
  }
}
