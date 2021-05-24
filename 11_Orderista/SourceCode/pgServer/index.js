// imports
const express = require("express");
const cors = require("cors");
const config = require("config");
const logger = require("morgan");

// const fs = require("fs");
// const Pool = require("pg").Pool;
// const fastcsv = require("fast-csv");

// middlewares
const auth = require("./middlewares/auth");
const error = require("./middlewares/error");

const Auth = require("./routes/api/Auth");
const Menu = require("./routes/api/Menu");
const Order = require("./routes/api/Order");
const Favourite = require("./routes/api/Favorite");
const Feedback = require("./routes/api/Feedback");
const Message = require("./routes/api/Messages");
const Ai = require("./routes/api/AI");
const Recommeder = require("./routes/api/Recommender");
const Wallet = require("./routes/api/Wallet");
const { pdb } = require("./db_init/dbConn");

// initialize express app
app = express();
// bodyparser
app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// cors
app.use(cors());

// logger
app.use(logger("common"));

// health check route
app.post("/", (req, res, next) => {
  res.status(200).json({
    status: 200,
    message: "Health check successful",
  });
  // let stream = fs.createReadStream("AI_Data.csv");
  // let csvData = [];
  // let csvStream = fastcsv
  //   .parse()
  //   .on("data", function (data) {
  //     csvData.push(data);
  //   })
  //   .on("end", function () {
  //     // remove the first line: header
  //     csvData.shift();
  //     console.log(csvData.length);
  //     // console.log(csvData);
  //     const query =
  //       'INSERT INTO "Menu" (dishname, dishtag, dishid, dishcost, dishimage) VALUES ($1, $2, $3, $4, $5)';

  //     try {
  //       csvData.forEach((row) => {
  //         console.log(row);
  //         pdb
  //           .any(query, row)
  //           .then((result) => {
  //             "Added " + row;
  //           })
  //           .catch((err) => console.log(err));

  // res.status(200).json({
  //   status: 200,
  //   message: "Health check successful",
  // });
  //       });
  //     } catch (err) {
  //       throw err;
  //     }
  //   });
  // stream.pipe(csvStream);
});
// routes
app.use("/api/v1/auth", Auth);
app.use("/api/v1/menu", Menu);
app.use("/api/v1/order", Order);
app.use("/api/v1/fav", Favourite);
app.use("/api/v1/feedback", Feedback);
app.use("/api/v1/message", Message);
// app.use("/api/v1/ai", Ai);
app.use("/api/v1/ai", Recommeder);
app.use("/api/v1/wallet", Wallet);
// app.use("/api/v1/<...>", auth, Media);

// error handling middleware
app.use(error);

// set up port for running server
const port = config.get("PORT");
console.log(process.env.NODE_ENV);

app.listen(port, () =>
  console.log(`Server is listening at http://localhost:${port}`)
);
