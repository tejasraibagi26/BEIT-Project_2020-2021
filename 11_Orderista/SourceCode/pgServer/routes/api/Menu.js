const express = require("express");
const router = express.Router();
const pdb = require("../../db_init/dbConn").pdb;

//Route to fetch all the menu dishes.
router.get("/food", async (req, res, next) => {
  try {
    const query = 'SELECT * FROM "Menu"';
    pdb
      .any(query)
      .then((result) => {
        if (result.length === 0) {
          throw {
            statusCode: 404,
            customMessage: "No menu details found",
          };
        } else {
          //   let data = result[0];
          res.status(200).json({
            status: 200,
            menu: result,
            message: "Menu retrieved",
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

module.exports = router;
