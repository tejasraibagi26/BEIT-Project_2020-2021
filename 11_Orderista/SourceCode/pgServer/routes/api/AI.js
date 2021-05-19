const express = require("express");
const router = express.Router();
const pdb = require("../../db_init/dbConn").pdb;

router.post("/ai", async (req, res, next) => {
  var userOrderHistory = [];
  var dailyOrderHistory = [];
  var maxUserCommonOrders = [];
  var topUserOrders = [];
  var maxDailyCommonOrders = [];
  var topDailyOrders = [];
  var orders = [];
  var totalOrders = [];
  try {
    const query = "SELECT * FROM orders WHERE userid = ${userid}";
    pdb
      .any(query, { userid: req.body.userid })
      .then((result) => {
        // console.log(result.length);
        for (var i = 0; i < result.length; i++) {
          orders.push(result[i]["orders"]);
        }
        // console.log(result["orders"]);
        for (var i = 0; i <= orders.length - 1; i++) {
          var item = orders[i];
          //   console.log(item);
          for (var j = 0; j <= item.length - 1; j++) {
            userOrderHistory.push({
              name: JSON.parse(item[j])["name"],
              quantity: JSON.parse(item[j])["quantity"],
            });
          }
        }

        const query2 = "SELECT * FROM orders";
        pdb
          .any(query2)
          .then((result) => {
            for (var i = 0; i < result.length; i++) {
              totalOrders.push(result[i]["orders"]);
            }
            // console.log(result["orders"]);
            for (var i = 0; i <= totalOrders.length - 1; i++) {
              var item = totalOrders[i];
              //   console.log(item);
              for (var j = 0; j <= item.length - 1; j++) {
                dailyOrderHistory.push({
                  name: JSON.parse(item[j])["name"],
                  quantity: JSON.parse(item[j])["quantity"],
                });
              }
            }

            for (var i = 0; i <= dailyOrderHistory.length - 1; i++) {
              for (var j = 1; j < dailyOrderHistory.length; j++) {
                if (
                  dailyOrderHistory[i]["name"] == dailyOrderHistory[j]["name"]
                ) {
                  maxDailyCommonOrders.push(dailyOrderHistory[i]["name"]);
                  dailyOrderHistory.splice(j, 1);
                }
              }
            }

            for (var i = 0; i < 3; i++) {
              var name = maxDailyCommonOrders
                .sort(
                  (a, b) =>
                    maxDailyCommonOrders.filter((v) => v === a).length -
                    maxDailyCommonOrders.filter((v) => v === b).length
                )
                .pop();

              maxDailyCommonOrders = maxDailyCommonOrders.filter(
                (item) => item != name
              );

              topDailyOrders.push(name);
            }
            console.log(topDailyOrders);

            recommend(topUserOrders, topDailyOrders, res);
          })
          .catch((err) => {
            console.log(err);
          });

        for (var i = 0; i <= userOrderHistory.length - 1; i++) {
          for (var j = 1; j < userOrderHistory.length; j++) {
            if (userOrderHistory[i]["name"] == userOrderHistory[j]["name"]) {
              maxUserCommonOrders.push(userOrderHistory[i]["name"]);
              userOrderHistory.splice(j, 1);
            }
          }
        }

        for (var i = 0; i < 3; i++) {
          var name = maxUserCommonOrders
            .sort(
              (a, b) =>
                maxUserCommonOrders.filter((v) => v === a).length -
                maxUserCommonOrders.filter((v) => v === b).length
            )
            .pop();

          maxUserCommonOrders = maxUserCommonOrders.filter(
            (item) => item != name
          );

          topUserOrders.push(name);
        }

        console.log(topUserOrders);
      })
      .catch((err) => {
        console.log(err);
      });
  } catch (error) {
    console.log(error);
  }
});

function recommend(user, daily, res) {
  var recommendedItem = "";
  var sameItemCount = 0;
  var list = [];

  for (var i = 0; i < user.length; i++) {
    for (var j = 0; j < daily.length; j++) {
      if (user[i] == daily[j]) {
        sameItemCount++;
      } else {
        list.push(daily[i]);
      }
    }
  }

  if (sameItemCount == 0) {
    var random = Math.floor(Math.random() * daily.length);
    recommendedItem = daily[random];
    console.log(recommendedItem);
    const query = 'SELECT * FROM "Menu" where dishname = ${dishname}';
    pdb
      .any(query, { dishname: recommendedItem })
      .then((result) => {
        res.status(200).json({
          status: 200,
          item: result,
          message: "AI",
        });
      })
      .catch((err) => console.log(err));
  }

  if (sameItemCount == 1) {
    var random = Math.floor(Math.random() * list.length);
    recommendedItem = list[random];
    console.log(recommendedItem);
    const query = 'SELECT * FROM "Menu" where dishname = ${dishname}';
    pdb
      .any(query, { dishname: recommendedItem })
      .then((result) => {
        res.status(200).json({
          status: 200,
          item: result,
          message: "AI",
        });
      })
      .catch((err) => console.log(err));
  }

  if (sameItemCount == 3) {
    const query = 'SELECT * FROM "Menu"';
    pdb
      .any(query)
      .then((result) => {
        var items = result;
        var random = Math.floor(Math.random() * result.length);
        recommendedItem = items[random];
        console.log(recommendedItem);
        res.status(200).json({
          status: 200,
          item: [recommendedItem],
          message: "AI",
        });
      })
      .catch((err) => console.log(err));
  }

  console.log(sameItemCount);
}

module.exports = router;
