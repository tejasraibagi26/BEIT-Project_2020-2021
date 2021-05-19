import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReusableButton extends StatelessWidget {
  const ReusableButton({
    Key key,
    @required this.height,
    this.width,
    this.buttonTitle,
    this.onTap,
  }) : super(key: key);

  final double height, width;
  final String buttonTitle;
  final Widget onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => onTap,
        ));
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
                color: Colors.black12.withOpacity(.2),
                blurRadius: 20,
                offset: Offset(0, 10)),
          ],
        ),
        child: Center(
          child: Text(
            buttonTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
            ),
          ),
        ),
      ),
    );
  }
}
