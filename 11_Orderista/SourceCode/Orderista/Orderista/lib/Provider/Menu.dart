import 'package:flutter/material.dart';
import 'package:orderista/Common/FoodConstructor.dart';

//The Menu Provider holds all data related to the menu and favs.
//This helps us to reduce the api load levels as the data is stored across the state
//and does not require a reload to fetch all data again.

class Menu extends ChangeNotifier {
  List<Food> foodItems = [];
  List<Food> favItems = [];
  var suggested = [];

  void addFoodItemsToProvider(Food item) {
    foodItems.add(item);

    notifyListeners();
  }

  void addFavsToProviders(Food item) {
    favItems.add(item);

    notifyListeners();
  }

  void addSuggestedToProviders(Food item) {
    suggested.add(item);

    notifyListeners();
  }
}
