const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const pdb = require("../../db_init/dbConn").pdb;

router.post("/get-favs", async (req, res, next) => {
  try {
    const query =
      "select * from favourite where userid=${userid} and itemname=${itemName};";
    pdb
      .any(query, { userid: req.body.userid, itemName: req.body.itemName })
      .then((result) => {
        if (result.length === 0) {
          res.status(200).json({
            status: 200,
            favs: false,
            favourite: result,
            message: "No Favs",
          });
        } else {
          res.status(200).json({
            status: 200,
            favs: true,
            message: "Logged in succcessfully",
            // token: `Bearer ${token}`,
          });
        }
        console.log(result);
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/get-all-favs", async (req, res, next) => {
  try {
    const query = "select * from favourite where userid=${userid}";
    pdb
      .any(query, { userid: req.body.userid })
      .then((result) => {
        if (result.length === 0) {
          res.status(200).json({
            status: 200,
            favs: false,
            favourite: result,
            message: "No Favs",
          });
        } else {
          res.status(200).json({
            status: 200,
            favs: true,
            favourite: result,
            message: "Logged in succcessfully",
          });
        }
        console.log(result);
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/favs", async (req, res, next) => {
  console.log(res.body);
  try {
    const query =
      "insert into favourite(userid, itemname, itemurl, cost, tag, id) values(${userid}, ${itemName}, ${itemurl}, ${cost}, ${tag}, ${id});";
    pdb
      .any(query, {
        userid: req.body.userid,
        itemName: req.body.itemName,
        itemurl: req.body.itemURL,
        cost: req.body.cost,
        tag: req.body.tag,
        id: req.body.id,
      })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Added",
          // token: `Bearer ${token}`,
        });
        console.log(result);
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

router.post("/remove-favs", async (req, res, next) => {
  try {
    const query =
      "delete from favourite where userid=${userid} and itemname=${itemName};";
    pdb
      .any(query, { userid: req.body.userid, itemName: req.body.itemName })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Removed",
        });
        console.log(result);
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
