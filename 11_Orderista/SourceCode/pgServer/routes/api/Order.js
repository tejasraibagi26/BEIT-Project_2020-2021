const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const pdb = require("../../db_init/dbConn").pdb;
const moment = require("moment");

//Add Order to the database.
router.post("/add-order", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "INSERT INTO orders(orderid,userid,orders,cost,payment, order_date ,time_stamp, completed) VALUES(${orderid}, ${userid},${order},${cost},${payment}, ${order_date},${time_stamp}, ${completed});";
    pdb
      .any(query, {
        orderid: req.body.orderid,
        userid: req.body.userid,
        order: req.body.order,
        cost: req.body.cost,
        payment: req.body.payment,
        order_date: req.body.date,
        time_stamp: req.body.time_stamp,
        completed: req.body.completed,
      })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Order inserted",
        });
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

//Confirm Order via Canteen Owner.
router.post("/confirm-order", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "UPDATE orders SET completed=true where orderid = ${orderid};";
    pdb
      .any(query, {
        orderid: req.body.orderid,
      })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Order updated!",
        });
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

//Get the order - Canteen Module
router.post("/get-order", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "SELECT * FROM orders WHERE userid=${userID} and completed='f' ORDER BY time_stamp DESC ";
    pdb
      .any(query, {
        userID: req.body.userID,
      })
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No active order found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            order: result,
            message: "Order Fetched",
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.get("/all-orders", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "SELECT * FROM orders WHERE completed='f' ORDER BY time_stamp ASC ";
    pdb
      .any(query)
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No active order found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            order: result,
            message: "Order Fetched",
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.get("/get-all-orders", async (req, res, next) => {
  try {
    console.log(req.body);

    const query = "SELECT * FROM orders WHERE completed='t'";
    pdb
      .any(query)
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No active order found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            order: result,
            message: "Order Fetched",
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/completed-orders", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "SELECT * FROM orders WHERE completed='t' and userid=${userID} ORDER BY time_stamp ASC ";
    pdb
      .any(query, {
        userID: req.body.userid,
      })
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No active order found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            order: result,
            message: "Order Fetched",
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/orders-by-days", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "SELECT * FROM orders WHERE completed='t' and order_date between ${day1} and ${day2}";
    pdb
      .any(query, {
        day1: req.body.day1,
        day2: req.body.day2,
      })
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No active order found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            order: result,
            message: "Order Fetched",
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/recent-orders", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "SELECT * FROM orders WHERE completed='t' and userid=${userID} ORDER BY time_stamp DESC LIMIT 5";
    pdb
      .any(query, {
        userID: req.body.userid,
      })
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No recent order found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            order: result,
            message: "Recent Order Fetched",
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/check-barcode", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "select * from orders where orderid = ${orderid} and completed='f'";
    pdb
      .any(query, {
        orderid: req.body.orderid,
      })
      .then((result) => {
        if (result.length == 0) {
          throw {
            status: 404,
            customMessage: "No order found",
          };
        } else {
          res.status(200).json({
            status: 200,
            orders: result,
            message: "Order Found!",
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.get("/suggestions", async (req, res, next) => {
  try {
    const query = "SELECT * FROM orders WHERE completed = 't'";
    pdb
      .any(query)
      .then((result) => {
        if (result.length == 0) {
          throw {
            status: 400,
            message: "Data not found",
          };
        } else {
          res.status(200).json({
            status: 200,
            data: result,
          });
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (error) {
    next(error);
  }
});

module.exports = router;
