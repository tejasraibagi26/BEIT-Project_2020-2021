import 'package:flutter/material.dart';

class Cart extends ChangeNotifier {
  //Define variables
  String itemName, itemTag, itemImagePath, itemID;
  int itemQuantity, itemCost;
  var cartItems = [];
  int amount = 0;
  bool isAdded = false;

  //Constructor for the class
  Cart(
      {this.itemTag,
      this.itemCost,
      this.itemImagePath,
      this.itemID,
      this.itemName,
      this.itemQuantity});

  //Function to add items into the cart.
  void addToCart(newItem) {
    //If list is empty by default add the item direclty.
    if (cartItems.length == 0) {
      cartItems.add(newItem);
      amount += cartItems[0]["itemCost"];
    }
    //If list not empty by default follow the procedure.
    else {
      //If list !empty then itterate through the entire list,
      //This is to check if the item is already present or not.
      //If present then increment the quantity of the item.
      for (int i = 0; i <= cartItems.length - 1; i++) {
        if (cartItems[i]["itemName"] == newItem["itemName"]) {
          //Increment the quantity rather than adding the item again;
          cartItems[i]["itemQuantity"] += 1;
          //Add up the total amount.
          amount += cartItems[i]["itemCost"];
          return;
        }
      }
      //If no item found in the list, just add it to the list.
      cartItems.add(newItem);
      amount += newItem["itemCost"];
    }

    notifyListeners();
  }

  //Function to increment quantity directly from cart screen.
  void incrementQuantity(itemID) {
    for (int i = 0; i <= cartItems.length - 1; i++) {
      if (cartItems[i]["itemID"].toString() == itemID.toString()) {
        //Increment the quantity
        cartItems[i]["itemQuantity"] += 1;
        //Add up the total amount.
        amount += cartItems[i]["itemCost"];
        notifyListeners();
        return;
      }
    }
  }

  //Function to decrement quantity directly from cart screen.
  void decrementQuantity(itemID) {
    for (int i = 0; i <= cartItems.length - 1; i++) {
      if (cartItems[i]["itemID"].toString() == itemID.toString()) {
        //Check if quantity is 1, if yes then delete instead of decrementing
        if (cartItems[i]["itemQuantity"] == 1) {
          //Decrease the total amount.
          amount -= cartItems[i]["itemCost"];
          //Delete from cartList
          cartItems.removeAt(i);
          notifyListeners();
          return;
        }
        //If quantity > 1 then decrement.
        else {
          //Increment the quantity
          cartItems[i]["itemQuantity"] -= 1;
          //Add up the total amount.
          amount -= cartItems[i]["itemCost"];
          notifyListeners();
          return;
        }
      }
    }
  }

  //Function to delete item directly from cart screen.
  void deleteItem(itemID) {
    for (int i = 0; i <= cartItems.length - 1; i++) {
      if (cartItems[i]["itemID"].toString() == itemID.toString()) {
        amount -= cartItems[i]["itemCost"] * cartItems[i]["itemQuantity"];
        //Delete from cartList
        cartItems.removeAt(i);
      }
      notifyListeners();
    }
  }
}
