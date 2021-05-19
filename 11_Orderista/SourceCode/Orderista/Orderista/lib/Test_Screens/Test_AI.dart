import 'package:flutter/material.dart';
import 'package:orderista/Common/Banner.dart';
import 'package:orderista/Module/http.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/Widgets/FoodItem.dart';
import 'package:orderista/constants.dart';
import 'package:orderista/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class TestAIRecco extends StatefulWidget {
  @override
  _TestAIReccoState createState() => _TestAIReccoState();
}

class _TestAIReccoState extends State<TestAIRecco> {
  bool isDarkMode = false;
  var recommendation;
  bool isFetching = true;
  var itemInfo;

  @override
  void initState() {
    super.initState();
    getTheme();
    recommendations();
  }

  void getTheme() async {
    if (!this.mounted) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool("isDarkMode") == null) {
      prefs.setBool("isDarkMode", false);
    }
    setState(() {
      isDarkMode = prefs.getBool("isDarkMode");
    });
  }

  void recommendations() async {
    if (!this.mounted) return;
    setState(() {
      isFetching = true;
    });
    var data = {"userid": prefs.getString("userID")};
    var res = await httpPost("api/v1/ai/recommend", data);
    recommendation = res["data"];
    //fetch item data from menu
    var items = {
      "dish1": recommendation[0],
      "dish2": recommendation[1],
      "dish3": recommendation[2]
    };
    itemInfo = await httpPost("api/v1/ai/getItemDetails", items);
    itemInfo = itemInfo["data"];
    this.setState(() {
      isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderText(
                headerTitle: "Our Recommendation!",
                color: isDarkMode ? textColorDark : textColorLight,
              ),
              Divider(),
              SizedBox(height: 10),
              !isFetching
                  ? LimitedBox(
                      maxHeight: size.height,
                      child: ListView.builder(
                          // physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: itemInfo.length,
                          itemBuilder: (context, index) {
                            return FoodItem(
                              name: itemInfo[index]["dishname"],
                              imagePath: itemInfo[index]["dishimage"],
                              cost: itemInfo[index]["dishcost"],
                              id: itemInfo[index]["dishid"],
                              tag: itemInfo[index]["dishtag"],
                            );
                          }),
                    )
                  : Center(
                      child: Lottie.asset('images/search.json'),
                    ),
              Spacer(),
              Column(
                children: [
                  BannerAlert(
                      size: size,
                      isDarkMode: isDarkMode,
                      bannerText:
                          "Recommendation System is still under development."),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )
            ],
          )),
        ),
      ),
    );
  }
}
