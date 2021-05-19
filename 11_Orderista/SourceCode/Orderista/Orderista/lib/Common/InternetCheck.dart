import 'dart:io';
import 'package:orderista/Common/404.dart';
import 'package:flutter/cupertino.dart';

void checkInternet(BuildContext context) async {
  try {
    final result = await InternetAddress.lookup('google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      print('connected');
    }
  } on SocketException catch (_) {
    Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (context) => NoInternet()));
  }
}
