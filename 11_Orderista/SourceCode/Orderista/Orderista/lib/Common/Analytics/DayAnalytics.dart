import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/Common/Analytics/RatingConstructor.dart';
import 'package:orderista/ReusableComponent/HeaderTitle.dart';
import 'package:orderista/constants.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:orderista/Module/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DayAnalytics extends StatefulWidget {
  DayAnalytics({this.isDarkMode, this.size});

  final Size size;
  final bool isDarkMode;
  @override
  _DayAnalyticsState createState() => _DayAnalyticsState();
}

class _DayAnalyticsState extends State<DayAnalytics> {
  var result;
  var orders = [];
  int cost = 0;
  bool isFetching = false;
  bool isDarkMode = false;
  bool isLoadingChart = true;
  SharedPreferences prefs;

  //Date Picker
  DateTime selectedDate = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  var outputFormat = DateFormat('dd-MM-yyyy');

  bool _allowedDates(DateTime day) {
    if (day.isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  _selectDate(BuildContext context) async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
        selectableDayPredicate: _allowedDates,
        builder: (context, child) {
          return Theme(
              data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
              child: child);
        });

    if (date != null && date != selectedDate) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  _selectDate2(BuildContext context) async {
    final DateTime date = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2025),
        selectableDayPredicate: _allowedDates,
        builder: (context, child) {
          return Theme(
              data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
              child: child);
        });

    if (date != null && date != selectedDate2) {
      setState(() {
        selectedDate2 = date;
      });
    }
  }

  int star1 = 0;
  int star2 = 0;
  int star3 = 0;
  int star4 = 0;
  int star5 = 0;

  List<charts.Series> seriesList;

  List<charts.Series<Ratings, String>> _createRatings() {
    final ratingData = [
      Ratings('5.0', star5),
      Ratings('4.0', star4),
      Ratings('3.0', star3),
      Ratings('2.0', star2),
      Ratings('1.0', star1),
    ];

    return [
      charts.Series<Ratings, String>(
          id: 'Ratings',
          domainFn: (Ratings rating, _) => rating.ratingValue,
          measureFn: (Ratings rating, _) => rating.rating,
          data: ratingData,
          labelAccessorFn: (Ratings rating, _) => '${rating.rating.toString()}',
          fillColorFn: (Ratings rating, _) => isDarkMode
              ? charts.MaterialPalette.white
              : charts.MaterialPalette.black,
          insideLabelStyleAccessorFn: (Ratings rating, _) =>
              charts.TextStyleSpec(
                color: isDarkMode ? charts.Color.black : charts.Color.white,
                fontSize: 16,
              ))
    ];
  }

  @override
  void initState() {
    super.initState();

    getTheme();
    getData();
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

  void getData() async {
    setState(() {
      star1 = 0;
      star2 = 0;
      star3 = 0;
      star4 = 0;
      star5 = 0;
      isFetching = true;
      orders = [];
      cost = 0;
    });
    var data = {
      "day1": (selectedDate.toString()).split(" ")[0],
      "day2": (selectedDate2.toString()).split(" ")[0]
    };
    result = await httpPost('api/v1/order/orders-by-days', data);
    orders = result["order"];

    //Cost
    if (orders != null) {
      for (int i = 0; i <= orders.length - 1; i++) {
        setState(() {
          cost += orders[i]["cost"];
        });
      }
    }

    //Ratings
    if (orders != null) {
      for (int i = 0; i <= orders.length - 1; i++) {
        if (orders[i]["feedback"] == 5.0) {
          setState(() {
            star5 += 1;
          });
        } else if (orders[i]["feedback"] == 4.0) {
          setState(() {
            star4 += 1;
          });
        } else if (orders[i]["feedback"] == 3.0) {
          setState(() {
            star3 += 1;
          });
        } else if (orders[i]["feedback"] == 2.0) {
          setState(() {
            star2 += 1;
          });
        } else if (orders[i]["feedback"] == 1.0) {
          setState(() {
            star1 += 1;
          });
        }
      }
    }

    seriesList = _createRatings();

    setState(() {
      isFetching = false;
    });
  }

  barChart() {
    return charts.BarChart(
      seriesList,
      animate: true,
      vertical: true,
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      domainAxis: new charts.OrdinalAxisSpec(
        renderSpec: new charts.SmallTickRendererSpec(
            // Tick and Label styling here.
            labelStyle: new charts.TextStyleSpec(
                fontSize: 14, // size in Pts.
                color: isDarkMode
                    ? charts.MaterialPalette.white
                    : charts.MaterialPalette.black)),
      ),
      primaryMeasureAxis: new charts.NumericAxisSpec(
        renderSpec: new charts.GridlineRendererSpec(
          // Tick and Label styling here.
          labelStyle: new charts.TextStyleSpec(
              fontSize: 14, // size in Pts.
              color: isDarkMode
                  ? charts.MaterialPalette.white
                  : charts.MaterialPalette.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? bgColorDark : bgColorLight,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeaderText(
                  headerTitle: "Analytics",
                  color: widget.isDarkMode ? headerColorDark : headerColorLight,
                ),
                SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          child: Text(
                            "Starting Date :",
                            style: TextStyle(
                                color:
                                    isDarkMode ? textColorDark : textColorLight,
                                fontSize: textBodySize - 2),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              SFSymbols.calendar,
                              size: textBodySize,
                              color:
                                  isDarkMode ? iconColorDark : iconColorLight,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "${outputFormat.format(selectedDate.toLocal())}"
                                  .split(" ")[0],
                              style: TextStyle(
                                  color:
                                      isDarkMode ? subTitleDark : subTitleLight,
                                  fontSize: textBodySize - 2),
                            ),
                            IconButton(
                              alignment: Alignment.center,
                              icon: Icon(
                                SFSymbols.pencil,
                                color:
                                    isDarkMode ? subTitleDark : subTitleLight,
                                size: textBodySize,
                              ),
                              onPressed: () {
                                _selectDate(context);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 150,
                          child: Text(
                            "Ending Date :",
                            style: TextStyle(
                              color:
                                  isDarkMode ? textColorDark : textColorLight,
                              fontSize: textBodySize - 2,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              SFSymbols.calendar,
                              size: textBodySize,
                              color:
                                  isDarkMode ? iconColorDark : iconColorLight,
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "${outputFormat.format(selectedDate2.toLocal())}"
                                  .split(" ")[0],
                              style: TextStyle(
                                color:
                                    isDarkMode ? subTitleDark : subTitleLight,
                                fontSize: textBodySize - 2,
                              ),
                            ),
                            IconButton(
                              alignment: Alignment.center,
                              icon: Icon(
                                SFSymbols.pencil,
                                color:
                                    isDarkMode ? subTitleDark : subTitleLight,
                                size: textBodySize,
                              ),
                              onPressed: () {
                                _selectDate2(context);
                              },
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    getData();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: isDarkMode ? buttonColorDark : buttonColorLight,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black26.withOpacity(.1),
                              blurRadius: 20,
                              offset: Offset(0, 10))
                        ]),
                    child: Text(
                      "FILTER",
                      style: TextStyle(
                          letterSpacing: 2.0,
                          color: Colors.white,
                          fontSize: textBodySize,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: widget.size.width * .43,
                      height: 115,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26.withOpacity(.1),
                              spreadRadius: 0,
                              blurRadius: 22,
                              offset: Offset(0, 4),
                            )
                          ],
                          borderRadius: BorderRadius.circular(9),
                          color: widget.isDarkMode
                              ? cardColorDark
                              : cardColorLight),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Total Orders",
                            style: TextStyle(
                                fontSize: 16,
                                color: widget.isDarkMode
                                    ? textColorDark
                                    : textColorLight,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: !isFetching
                                ? Text(
                                    orders != null
                                        ? orders.length.toString()
                                        : "NaN",
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: widget.isDarkMode
                                            ? textColorDark
                                            : textColorLight,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  )
                                : widget.isDarkMode
                                    ? spinkit
                                    : spinkitDark,
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: widget.size.width * .43,
                      height: 115,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26.withOpacity(.1),
                            spreadRadius: 0,
                            blurRadius: 22,
                            offset: Offset(0, 4),
                          )
                        ],
                        borderRadius: BorderRadius.circular(9),
                        color:
                            widget.isDarkMode ? cardColorDark : cardColorLight,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Total Revenue",
                            style: TextStyle(
                                fontSize: 16,
                                color: widget.isDarkMode
                                    ? textColorDark
                                    : textColorLight,
                                fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: !isFetching
                                ? Text(
                                    "\u20B9 " + cost.toString(),
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: widget.isDarkMode
                                            ? textColorDark
                                            : textColorLight,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  )
                                : widget.isDarkMode
                                    ? spinkit
                                    : spinkitDark,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    Container(
                      height: widget.size.height * 0.3,
                      width: widget.size.width,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26.withOpacity(.1),
                              spreadRadius: 0,
                              blurRadius: 22,
                              offset: Offset(0, 4),
                            )
                          ],
                          color: widget.isDarkMode
                              ? cardColorDark
                              : cardColorLight,
                          borderRadius: BorderRadius.circular(9)),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 30, left: 20, right: 20, bottom: 10),
                        child: isFetching
                            ? widget.isDarkMode
                                ? spinkit
                                : spinkitDark
                            : seriesList == null
                                ? Center(
                                    child: Text(
                                      "No Data Available",
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? textColorDark
                                            : textColorLight,
                                        fontSize: textBodySize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : barChart(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "Ratings",
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? textColorDark
                              : textColorLight,
                          fontSize: textBodySize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
