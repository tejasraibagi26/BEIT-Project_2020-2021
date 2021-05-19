import 'package:orderista/constants.dart';
import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  const HeaderText({
    Key key,
    @required this.headerTitle,
    this.color,
  }) : super(key: key);

  final String headerTitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      headerTitle,
      style: TextStyle(
          color: color, fontSize: textHeaderSize, fontWeight: FontWeight.w500),
    );
  }
}
