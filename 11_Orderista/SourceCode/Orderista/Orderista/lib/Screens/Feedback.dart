import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/main.dart';
import 'package:orderista/Module/http.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  //Text controllers
  TextEditingController _feedbackTitle = new TextEditingController();
  TextEditingController _feedbackBody = new TextEditingController();
  bool _isSendingFeedback = false;
  bool isDarkMode = false;
  double rating = 0.0;

  String val;

  @override
  void initState() {
    super.initState();
    getTheme();
  }

  void getTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void sendFeedback() async {
    setState(() {
      _isSendingFeedback = true;
    });
    String _ftitle = _feedbackTitle.text;
    String _fbody = _feedbackBody.text;
    String _fid = UniqueKey().toString();
    String _ufid = _fid.split("[")[1].split("#")[1].split("]")[0].toString();
    int _userid = int.parse(prefs.getString("userID"));
    var data = {
      "feedback_id": _ufid,
      "feedback_title": _ftitle,
      "feedback_body": _fbody,
      "userid": _userid,
      "time_stamp": DateTime.now().toString()
    };
    var _feedback = await httpPost('api/v1/feedback/send', data);
    setState(() {
      _isSendingFeedback = false;
    });
    Fluttertoast.showToast(
        msg: _feedback["customMessage"].toString(),
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 4);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          scrollDirection: Axis.vertical,
          physics: BouncingScrollPhysics(),
          children: [
            //Custom Reusable widget
            HeaderText(
              headerTitle: "Feedback",
              color: isDarkMode ? textColorDark : textColorLight,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: isDarkMode ? cardColorDark : cardColorLight,
                borderRadius: BorderRadius.circular(9),
              ),
              child: TextFormField(
                maxLength: 20,
                style: TextStyle(
                    color: isDarkMode ? textColorDark : textColorLight),
                controller: _feedbackTitle,
                decoration: InputDecoration(
                  counterStyle: TextStyle(
                      color: isDarkMode ? textColorDark : textColorLight),
                  filled: true,
                  fillColor: isDarkMode ? cardColorDark : cardColorLight,
                  hintStyle: TextStyle(
                    fontSize: 17,
                    color: isDarkMode ? textColorDark : textColorLight,
                  ),
                  hintText: 'Feedback Title',
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
              ),
              child: TextFormField(
                style: TextStyle(
                    color: isDarkMode ? textColorDark : textColorLight),
                keyboardType: TextInputType.multiline,
                maxLines: 10,
                controller: _feedbackBody,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkMode ? cardColorDark : cardColorLight,
                  hintStyle: TextStyle(
                      fontSize: 17,
                      color: isDarkMode ? textColorDark : textColorLight),
                  hintText: 'Feedback Body',
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(20),
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () {
                if (_feedbackTitle.text.isNotEmpty &&
                    _feedbackBody.text.isNotEmpty) {
                  sendFeedback();
                } else {
                  Fluttertoast.showToast(
                      msg: "Form Cannot Be Empty",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 4);
                }
              },
              child: Container(
                width: size.width,
                height: 50,
                decoration: BoxDecoration(
                  color: isDarkMode ? buttonColorDark : buttonColorLight,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12.withOpacity(.2),
                        blurRadius: 20,
                        offset: Offset(0, 10)),
                  ],
                ),
                child: Center(
                  child: !_isSendingFeedback
                      ? Text(
                          "Send Feedback",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                          ),
                        )
                      : isDarkMode
                          ? spinkit
                          : spinkitDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
