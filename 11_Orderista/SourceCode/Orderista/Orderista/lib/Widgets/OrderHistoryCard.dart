// import 'package:flutter/material.dart';
// import 'package:orderista/constants.dart';

// class OrderHistoryCard extends StatelessWidget {
//   OrderHistoryCard(
//       {this.size,
//       this.isDarkMode,
//       this.orderName,
//       this.orderQuantity,
//       this.orderCost,
//       this.orderStatus});

//   final Size size;
//   final bool isDarkMode;
//   final String orderName;
//   final int orderQuantity;
//   final int orderCost;
//   final String orderStatus;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12.0),
//       margin: EdgeInsets.symmetric(vertical: 10.0),
//       width: size.width,
//       decoration: BoxDecoration(
//           color: isDarkMode ? cardColorDark : cardColorLight,
//           borderRadius: BorderRadius.circular(9)),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(
//           "Order ID: " +
//               completedOrders[index]["orderid"].split("_")[1].toString(),
//           style: TextStyle(
//               fontSize: textBodySize,
//               color: isDarkMode ? textColorDark : textColorLight),
//         ),
//         SizedBox(
//           height: 20,
//         ),
//         LimitedBox(
//           maxHeight: 500.0,
//           child: ListView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             itemCount: completedOrders[index]["orders"].length,
//             itemBuilder: (context, i) {
//               return Container(
//                 margin: EdgeInsets.symmetric(vertical: 5),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       json.decode(completedOrders[index]["orders"][i])["name"],
//                       style: TextStyle(
//                           fontSize: 22,
//                           color: isDarkMode ? textColorDark : textColorLight),
//                     ),
//                     Container(
//                       width: 40,
//                       height: 30,
//                       decoration: BoxDecoration(
//                           color: isDarkMode
//                               ? Colors.black.withOpacity(.2)
//                               : Colors.blueGrey.withOpacity(.2),
//                           borderRadius: BorderRadius.circular(6)),
//                       child: Center(
//                         child: Text(
//                           "x" +
//                               json
//                                   .decode(completedOrders[index]["orders"][i])[
//                                       "quantity"]
//                                   .toString(),
//                           style: TextStyle(
//                               fontSize: 18,
//                               color:
//                                   isDarkMode ? textColorDark : textColorLight),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Cost",
//               style: TextStyle(
//                   fontSize: 22,
//                   color: isDarkMode ? textColorDark : textColorLight),
//             ),
//             Container(
//               padding: EdgeInsets.all(2.5),
//               decoration: BoxDecoration(
//                   color: isDarkMode
//                       ? Colors.black.withOpacity(.2)
//                       : Colors.blueGrey.withOpacity(.2),
//                   borderRadius: BorderRadius.circular(9)),
//               child: Text(
//                 "\u20B9" + completedOrders[index]["cost"].toString(),
//                 style: TextStyle(
//                     fontSize: 18,
//                     color: isDarkMode ? textColorDark : textColorLight),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(
//           height: 10,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               "Status",
//               style: TextStyle(
//                   fontSize: 22,
//                   color: isDarkMode ? textColorDark : textColorLight),
//             ),
//             Container(
//               padding: EdgeInsets.all(2.5),
//               decoration: BoxDecoration(
//                   color: completedOrders[index]["completed"]
//                       ? Colors.green
//                       : Colors.redAccent,
//                   borderRadius: BorderRadius.circular(9)),
//               child: Text(
//                 completedOrders[index]["completed"] ? "Completed" : "Pending",
//                 style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.white,
//                     fontWeight: FontWeight.normal),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ],
//         ),
//       ]),
//     );
//   }
// }
