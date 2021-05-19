import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orderista/Admin/AdminRoot.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/Module/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServerMessages extends StatefulWidget {
  @override
  _ServerMessagesState createState() => _ServerMessagesState();
}

class _ServerMessagesState extends State<ServerMessages> {
  bool isDarkMode = false;
  bool isSavingMsg = false;

  SharedPreferences prefs;

  String email = "";

  TextEditingController _msgTitle = new TextEditingController();
  TextEditingController _msgBody = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _msgLink = new TextEditingController();

  @override
  void initState() {
    super.initState();

    getTheme();
    getEmail();
  }

  void getTheme() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void getEmail() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _email.text = prefs.getString("email");
    });
  }

  void sendMessage() async {
    setState(() {
      isSavingMsg = true;
    });
    String _fid = UniqueKey().toString();
    String msgId = _fid.split("[")[1].split("#")[1].split("]")[0].toString();
    String msgAuthor = _email.value.text;
    String msgTitle = _msgTitle.value.text;
    String msgBody = _msgBody.value.text;
    String msgTime = DateTime.now().toString();
    String msgLink = _msgLink.value.text;

    var data = {
      "msg_id": msgId,
      "msg_title": msgTitle,
      "msg_body": msgBody,
      "msg_author": msgAuthor,
      "msg_time": msgTime,
      "msg_link": msgLink,
    };

    var result = await httpPost('api/v1/message/send-message', data);
    setState(() {
      isSavingMsg = false;
    });
    if (result["status"] == 200) {
      Fluttertoast.showToast(
          msg: "Message Sent",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 4);
    } else {
      Fluttertoast.showToast(
          msg: "Error Sending Message",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                CupertinoPageRoute(builder: (context) => AdminRoot()));
          },
          icon: Icon(
            SFSymbols.chevron_left,
            color: isDarkMode ? iconColorDark : iconColorLight,
          ),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                headerTitle: "Create Server Message",
                color: isDarkMode ? textColorDark : textColorLight,
              ),
              SizedBox(
                height: 20,
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
                  controller: _msgTitle,
                  decoration: InputDecoration(
                    counterStyle: TextStyle(
                        color: isDarkMode ? textColorDark : textColorLight),
                    filled: true,
                    fillColor: isDarkMode ? cardColorDark : cardColorLight,
                    hintStyle: TextStyle(
                      fontSize: 17,
                      color: isDarkMode ? textColorDark : textColorLight,
                    ),
                    hintText: 'Message Title',
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
                  controller: _msgBody,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkMode ? cardColorDark : cardColorLight,
                    hintStyle: TextStyle(
                        fontSize: 17,
                        color: isDarkMode ? textColorDark : textColorLight),
                    hintText: 'Message Body',
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
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? cardColorDark : cardColorLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: TextFormField(
                  style: TextStyle(
                      color: isDarkMode ? textColorDark : textColorLight),
                  controller: _msgLink,
                  decoration: InputDecoration(
                    counterStyle: TextStyle(
                        color: isDarkMode ? textColorDark : textColorLight),
                    filled: true,
                    fillColor: isDarkMode ? cardColorDark : cardColorLight,
                    hintStyle: TextStyle(
                      fontSize: 17,
                      color: isDarkMode ? textColorDark : textColorLight,
                    ),
                    hintText: 'Link (Optional)',
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
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? cardColorDark : cardColorLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: TextFormField(
                  enabled: false,
                  controller: _email,
                  style: TextStyle(
                      color: isDarkMode ? textColorDark : textColorLight),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDarkMode ? cardColorDark : cardColorLight,
                    hintStyle: TextStyle(
                      fontSize: 17,
                      color: isDarkMode ? textColorDark : textColorLight,
                    ),
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
                  if (_msgTitle.text.isNotEmpty && _msgBody.text.isNotEmpty) {
                    sendMessage();
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
                    child: !isSavingMsg
                        ? Text(
                            "Send Server Message",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: textBodySize,
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
      ),
    );
  }
}
