const express = require("express");
const router = express.Router();
const pdb = require("../../db_init/dbConn").pdb;

//Send Server Message to all users
router.post("/send-message", async (req, res, next) => {
  try {
    const query =
      "insert into server_msg(msg_id, msg_title, msg_body, msg_author, msg_time, msg_link) values(${msg_id}, ${msg_title}, ${msg_body} ,${msg_author}, ${msg_time}, ${msg_link})";
    pdb
      .any(query, {
        msg_id: req.body.msg_id,
        msg_title: req.body.msg_title,
        msg_body: req.body.msg_body,
        msg_author: req.body.msg_author,
        msg_time: req.body.msg_time,
        msg_link: req.body.msg_link,
      })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Server Message sent",
        });
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

//Get route to fetch message
router.get("/get-message", async (req, res, next) => {
  const query = "select * from server_msg order by msg_time DESC LIMIT 1";
  try {
    pdb
      .any(query)
      .then((result) => {
        if (result.length == 0) {
          throw {
            status: 400,
            message: "No Message Found",
          };
        } else {
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
  } catch (error) {
    next(error);
  }
});

//Fetch all messages sent till date.
router.get("/get-all-message", async (req, res, next) => {
  const query = "select * from server_msg order by msg_time DESC";
  try {
    pdb
      .any(query)
      .then((result) => {
        if (result.length == 0) {
          throw {
            status: 400,
            message: "No Message Found",
          };
        } else {
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
  } catch (error) {
    next(error);
  }
});

module.exports = router;
