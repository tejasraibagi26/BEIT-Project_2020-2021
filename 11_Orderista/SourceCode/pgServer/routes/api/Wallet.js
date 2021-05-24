const express = require("express");
const router = express.Router();
const pdb = require("../../db_init/dbConn").pdb;

router.post("/wallet_info", async (req, res, next) => {
  const query = "SELECT wallet FROM users where userid = ${userid}";
  pdb.any(query, { userid: req.body.userid }).then((result) => {
    if (result.length === 0) {
      throw {
        status: 400,
        message: "Error retrieving data",
      };
    } else {
      res.status(200).json({
        status: 200,
        data: result,
      });
    }
  });
});

module.exports = router;
