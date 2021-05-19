const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const pdb = require("../../db_init/dbConn").pdb;

router.post("/send", async (req, res, next) => {
  try {
    const query =
      "insert into food_feedback(feedback_id, feedback_title, feedback_body, userid, time_stamp) values(${feedback_id}, ${feedback_title}, ${feedback_body}, ${userid}, ${time_stamp})";
    pdb
      .any(query, {
        feedback_id: req.body.feedback_id,
        feedback_title: req.body.feedback_title,
        feedback_body: req.body.feedback_body,
        userid: req.body.userid,
        time_stamp: req.body.time_stamp,
      })
      .then((result) => {
        res.status(200).json({
          status: 200,
          customMessage: "Feedback recorded successfully!",
        });
      })
      .catch((err) => {
        next(err);
        throw {
          status: 404,
          customMessage: "Error recording feedback!",
        };
      });
  } catch (err) {
    next(err);
  }
});

router.get("/get-all-ratings", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "SELECT * FROM orders where feedback_status = 't' order by time_stamp DESC";
    pdb
      .any(query)
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No Feedback Found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            feedback: result,
            message: "Feedback Fetched",
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

router.get("/get-all", async (req, res, next) => {
  try {
    console.log(req.body);

    const query = "SELECT * FROM food_feedback order by time_stamp DESC";
    pdb
      .any(query)
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No Feedback Found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            feedback: result,
            message: "Feedback Fetched",
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

router.post("/get-feedback-status", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "SELECT * FROM orders where userid=${userid} and completed = 't' order by time_stamp DESC limit 1";
    pdb
      .any(query, { userid: req.body.userid })
      .then((result) => {
        console.log(result);
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "Data Not Found Found",
          };
        } else {
          // order = result[0];
          res.status(200).json({
            status: 200,
            data: result,
            message: "Data Fetched",
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

router.post("/send-rating", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "insert into food_feedack(feedback_id, userid, orderid, orders, rating, feedback_title, feedback_body) values(${feedback_id}, ${userid}, ${orderid}, ${orders}, ${rating}, ${feedback_title}, ${feedback_body})";
    pdb
      .any(query, {
        userid: req.body.userid,
        feedback_id: req.body.feedback_id,
        orderid: req.body.orderid,
        orders: req.body.orders,
        rating: req.body.rating,
        feedback_title: req.body.feedback_title,
        feedback_body: req.body.feedback_body,
      })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Data Fetched",
        });
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/rating", async (req, res, next) => {
  try {
    console.log(req.body);

    const query =
      "UPDATE orders set feedback_status = true , feedback = ${rating} where orderid = ${orderid}";
    pdb
      .any(query, { rating: req.body.rating, orderid: req.body.orderid })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Feedback Updated",
        });
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
