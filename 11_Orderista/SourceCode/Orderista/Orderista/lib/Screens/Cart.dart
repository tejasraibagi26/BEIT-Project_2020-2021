import 'package:orderista/Common/Banner.dart';
import 'package:orderista/Provider/Cart.dart';
import 'package:orderista/Provider/Menu.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Root/root_app.dart';
import 'package:orderista/Widgets/CartItem.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Razorpay _razorpay;
  var userID = "";
  var order = [];
  bool isDarkMode = false;
  bool isCartEmpty = false;

  void initState() {
    super.initState();
    //Get UserID stored locally
    getPrefs();
    getTheme();

    if (Provider.of<Cart>(context, listen: false).cartItems.length == 0) {
      setState(() {
        isCartEmpty = true;
      });
    } else
      setState(() {
        isCartEmpty = false;
      });

    //Razorpay API
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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

  void getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() async {
    int amount = Provider.of<Cart>(context, listen: false).amount;
    var options = {
      'key': 'rzp_test_i3aeiM0nABKvDz',
      'amount': amount * 100,
      'name': 'A.P Shah Institute of Technology',
      'description': 'Payment for Food',
      'prefill': {'contact': '1234567890', 'email': 'test@razorpay.com'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    int amount = Provider.of<Cart>(context, listen: false).amount;
    Fluttertoast.showToast(
        msg: "ORDER PLACED",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 4);

    String orderid = response.paymentId;
    String payment = "Paid";
    int cost = amount;
    bool completed = false;
    List cart = Provider.of<Cart>(context, listen: false).cartItems;
    for (int i = 0; i <= cart.length - 1; i++) {
      order.add({
        "dishid": cart[i]['itemID'],
        "name": cart[i]['itemName'],
        "itemURL": cart[i]["itemImagePath"],
        "quantity": cart[i]["itemQuantity"]
      });
    }
    addOrder(orderid, int.parse(userID), order, cost, payment, completed);
    cart.clear();
  }

  void addOrder(String orderid, int userid, var order, int cost, String payment,
      bool completed) async {
    var data = {
      "orderid": orderid,
      "userid": int.parse(userID),
      "order": order,
      "cost": cost,
      "payment": payment,
      "completed": completed,
      "time_stamp": DateTime.now().toString(),
      "date": DateTime.now().toString().split(" ")[0]
    };
    var orderFood = await httpPost('api/v1/order/add-order', data);

    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => Cart(),
              ),
              ChangeNotifierProvider(create: (context) => Menu()),
            ],
            child: Root(),
          ),
        ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 4);

    String uniqueOrderID = UniqueKey().toString();
    String orderid = "pay_" +
        uniqueOrderID.split("[")[1].split("]")[0].split("#")[1].toString();
    String payment = "Paid";
    int cost = Provider.of<Cart>(context, listen: false).amount;
    bool completed = false;
    List cart = Provider.of<Cart>(context, listen: false).cartItems;
    for (int i = 0; i <= cart.length - 1; i++) {
      order.add({
        "name": cart[i]['itemName'],
        "itemURL": cart[i]["itemImagePath"],
        "quantity": cart[i]["itemQuantity"]
      });
    }
    addOrder(orderid, int.parse(userID), order, cost, payment, completed);
    cart.clear();
  }

  @override
  Widget build(BuildContext context) {
    int _amount = Provider.of<Cart>(context, listen: false).amount;
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
          child: ListView(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            children: [
              HeaderText(
                headerTitle: "Cart",
                color: isDarkMode ? textColorDark : textColorLight,
              ),
              Divider(),
              Text(
                "Order Details",
                style: TextStyle(
                    color: isDarkMode ? textColorDark : textColorLight,
                    fontSize: 20,
                    fontWeight: FontWeight.w500),
              ),
              LimitedBox(
                  maxHeight: size.height * 0.5,
                  child: Consumer<Cart>(
                    builder: (context, cartItem, child) {
                      return cartItem.cartItems.length != 0
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: cartItem.cartItems.length,
                              itemBuilder: (context, index) {
                                return CartItem(
                                  name: cartItem.cartItems[index]["itemName"],
                                  id: cartItem.cartItems[index]["itemID"]
                                      .toString(),
                                  cost: cartItem.cartItems[index]["itemCost"],
                                  tag: cartItem.cartItems[index]["itemTag"],
                                  imagePath: cartItem.cartItems[index]
                                          ["itemImagePath"]
                                      .toString(),
                                  quantity: cartItem.cartItems[index]
                                      ["itemQuantity"],
                                );
                              })
                          : Center(
                              child: Text(
                                "No Items in Cart",
                                style: TextStyle(
                                    color: isDarkMode
                                        ? textColorDark
                                        : textColorLight,
                                    fontSize: 25),
                              ),
                            );
                    },
                  )),
              SizedBox(
                height: 20,
              ),
              _amount != 0
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Amount",
                          style: TextStyle(
                              color:
                                  isDarkMode ? textColorDark : textColorLight,
                              fontWeight: FontWeight.w500,
                              fontSize: 20),
                        ),
                        Consumer<Cart>(
                          builder: (context, cart, child) {
                            return Text(
                              "₹ " + cart.amount.toString(),
                              style: TextStyle(
                                  color: isDarkMode
                                      ? textColorDark
                                      : textColorLight,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20),
                            );
                          },
                        )
                      ],
                    )
                  : Text(""),
              Divider(),
              SizedBox(
                height: 10,
              ),
              BannerAlert(
                  size: size,
                  isDarkMode: isDarkMode,
                  bannerText:
                      "Order once placed cannot be cancelled NOR refunded."),
              SizedBox(
                height: 10,
              ),
              !isCartEmpty
                  ? GestureDetector(
                      onTap: () {
                        var cartList =
                            Provider.of<Cart>(context, listen: false).cartItems;
                        if (cartList.isEmpty) return;
                        openCheckout();
                      },
                      child: Container(
                        width: size.width,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? buttonColorDark : buttonColorLight,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12.withOpacity(.2),
                                blurRadius: 20,
                                offset: Offset(0, 10)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Place Order",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
