const express = require("express");
const router = express.Router();
const pdb = require("../../db_init/dbConn").pdb;
const axios = require("axios").default;

router.post("/recommend", async (req, res, next) => {
  var recoRes, index;
  try {
    const query =
      "select * from orders where userid = ${userid} order by order_date DESC";

    pdb
      .any(query, { userid: req.body.userid })
      .then((result) => {
        console.log(result.length);
        if (result.length == 0) {
          itemId = Math.floor(Math.random() * 50);
        } else if (result[0]["orders"].length > 1) {
          console.log(result[0]["orders"].length);
          index = Math.floor(Math.random() * result[0]["orders"].length);
        } else {
          index = 0;
        }
        if (result.length != 0)
          var itemId = JSON.parse(result[0]["orders"][index])["dishid"];
        let data = { itemId: itemId };
        axios
          .post("https://aiorderista.herokuapp.com/recommend", data)
          .then((result) => {
            recoRes = result.data["recommendation"];
            console.log(recoRes);
            res.status(200).json({
              data: recoRes,
            });
          })
          .catch((err) => {
            console.log(err);
          });
      })
      .catch((err) => console.log(err));
  } catch (error) {
    console.log(error);
  }
});

router.post("/getItemDetails", async (req, res, next) => {
  try {
    const query =
      'SELECT * FROM "Menu" where dishname = ${dish1} or dishname = ${dish2} or dishname = ${dish3}';

    pdb
      .any(query, {
        dish1: req.body.dish1,
        dish2: req.body.dish2,
        dish3: req.body.dish3,
      })
      .then((result) => {
        res.status(200).json({
          status: 200,
          data: result,
        });
      })
      .catch((err) => console.log(err));
  } catch (error) {
    next(error);
    console.log(error);
  }
});

module.exports = router;
