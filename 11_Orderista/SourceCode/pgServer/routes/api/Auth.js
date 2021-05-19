const express = require("express");
const router = express.Router();
const bcrypt = require("bcryptjs");
const pdb = require("../../db_init/dbConn").pdb;
var CronJob = require("cron").CronJob;
require("dotenv").config();

//Scheduled event to remove all OTPs from the database at 00:00 hrs
var job = new CronJob("0 0 * * * *", function () {
  try {
    const query = "UPDATE USERS SET otp = null where otp IS NOT NULL";
    pdb
      .any(query)
      .then(() => console.log("Reset OTP done."))
      .catch((err) => console.log(err));
  } catch (err) {
    console.log(err);
  }
});
job.start();

//Login Route
// Data Required - UserID (moodle) and Password
router.post("/login", async (req, res, next) => {
  try {
    const query = "select * from users where userid=${moodleid}";
    pdb
      .any(query, { moodleid: req.body.moodleid })
      .then((result) => {
        if (result.length === 0) {
          throw {
            status: 404,
            customMessage: "No user found",
          };
        } else if (!bcrypt.compareSync(req.body.password, result[0].password)) {
          throw {
            status: 404,
            customMessage: "Invalid password",
          };
        } else {
          let data = result[0];
          res.status(200).json({
            status: 200,
            role: data.role,
            email: data.email,
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

//Check Email Route
// Data Required - UserID (moodle) and Email
router.post("/check-email", async (req, res, next) => {
  console.log(req.body.email);
  try {
    const query = "select * from users where email = ${email}";
    pdb
      .any(query, {
        email: req.body.email,
      })
      .then((result) => {
        console.log(result.length);
        if (result.length !== 0) {
          res.status(200).json({
            status: 200,
            message: "Email already present",
            code: 0,
          });
        } else {
          const query =
            "update users set email=${email} where userid = ${userid}";
          pdb
            .any(query, { email: req.body.email, userid: req.body.userid })
            .then((result) => {
              console.log(result);
              res.status(200).json({
                status: 200,
                message: "Email Added and OTP sent",
                code: 1,
              });
            })
            .catch((err) => {
              next(err);
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

//Change Password Route
// Data Required - UserID (moodle) and Password
router.post("/change-password", async (req, res, next) => {
  var password = req.body.password;
  const salt = 10;

  var hashedPassword = bcrypt.hashSync(password, salt);

  console.log("Hashed Password: " + hashedPassword);

  try {
    const query =
      "update users set password=${password} where userid = ${userid}";
    pdb
      .any(query, {
        userid: req.body.userid,
        password: hashedPassword,
      })
      .then(() => {
        res.status(200).json({
          status: 200,
          message: "Password Saved",
        });
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

//Mailer
var nodemailer = require("nodemailer");

var transport = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 465,
  secure: true,
  auth: {
    type: "OAuth2",
    user: process.env.SENDER_EMAIL_ADDRESS,
    clientId: process.env.MAILING_SERVICE_CLIENT_ID,
    clientSecret: process.env.MAILING_SERVICE_CLIENT_SECRET,
    refreshToken: process.env.MAILING_SERVICE_REFRESH_TOKEN,
    accessToken: process.env.ACCESS_TOKEN,
  },
});

//Send OTP Route
// Data Required - OTP, OTP_TIME (Time when OTP was generated) and Email
router.post("/send-otp", async (req, res, next) => {
  //Generate Random OTP
  var otpGen = Math.random();
  otpGen = otpGen * 1000000;
  var otp = parseInt(otpGen);

  //Mail Structure
  var mail = {
    from: "orderista.apsit@gmail.com",
    to: req.body.email,
    subject: "OTP for Orderista",
    html:
      "<h3>Your OTP " +
      req.body.reason +
      " is - </h3><h1 style = font-weight:'bold';>" +
      otp +
      "</h1> <p style = font-weight:'bold'; font-style:'italic'>Valid till midnight</p>",
  };

  const query_email =
    "SELECT * FROM users where userid = ${userid} and email = ${email}";

  pdb
    .any(query_email, {
      userid: req.body.userid,
      email: req.body.email,
    })
    .then((result) => {
      if (result.length == 0) {
        res.status(400).json({
          status: 400,
          msg: "Email not associated with this account.",
        });
      } else {
        transport.sendMail(mail, (err, info) => {
          if (err) {
            throw {
              status: 400,
              message: "Error sending OTP",
              err: err,
            };
          } else {
            try {
              const query =
                "update users set otp=${otp}, otp_time = ${otp_time} where email = ${email}";
              pdb
                .any(query, {
                  otp: otp,
                  email: req.body.email,
                  otp_time: req.body.otp_time,
                })
                .then(() => {
                  res.status(200).json({
                    status: 200,
                    message: "OTP Sent",
                  });
                })
                .catch((err) => {
                  next(err);
                });
            } catch (err) {
              next(err);
            }
          }
        });
      }
    });

  //Send OTP Mail
});

//Verify OTP Route
//Data Required - UserID (moodle), Email and OTP
router.post("/verify-otp", async (req, res, next) => {
  try {
    const query = "select otp from users where email = ${email}";
    pdb
      .any(query, {
        email: req.body.email,
      })
      .then((result) => {
        if (result.length != 0) {
          if (req.body.otp === result[0]["otp"]) {
            res.status(200).json({
              status: 200,
              message: "Verified Saved",
            });

            const query =
              "update users set otp = null, verified = true  where email = ${email}";
            pdb
              .any(query, {
                email: req.body.email,
              })
              .then(() => {
                res
                  .status(200)
                  .json({
                    status: 200,
                    message: "Verified",
                  })
                  .catch((err) => {
                    next(err);
                  });
              });
          } else {
            throw {
              status: 400,
              message: "Incorrect OTP",
            };
          }
        }
      })
      .catch((err) => {
        next(err);
      });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
