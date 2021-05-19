import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

//Base color constants
const primaryColor = Color(0xff0093E9);
const secondaryColor = Color(0xff80D0C7);

//Text Sizes
const double textHeaderSize = 28;
const double textBodySize = 20;

//Light Mode
const textColorLight = Colors.black;
const headerColorLight = Colors.black;
const iconColorLight = Colors.black;
const bgColorLight = Color(0xfffafafa);
const cardColorLight = Colors.white;
const buttonColorLight = Colors.black;
const subTitleLight = Colors.black38;
const warningBgColorLight = Colors.redAccent;

//Dark Mode
const textColorDark = Colors.white;
const headerColorDark = Colors.white;
const iconColorDark = Colors.white;
const bgColorDark = Color(0xff111111);
const cardColorDark = Color(0xff262626);
const buttonColorDark = Color(0xff262626);
const subTitleDark = Colors.white54;
const waringBgColorDark = Colors.red;

//Loading Animatoin
const spinkit = SpinKitThreeBounce(
  color: Colors.white,
  size: 26.0,
);

const spinkitDark = SpinKitThreeBounce(
  color: Colors.black,
  size: 26.0,
);
