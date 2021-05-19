import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:orderista/constants.dart';

class BannerAlert extends StatelessWidget {
  const BannerAlert({
    Key key,
    @required this.size,
    @required this.isDarkMode,
    @required this.bannerText,
  }) : super(key: key);

  final Size size;
  final bool isDarkMode;
  final String bannerText;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 100,
      child: Container(
        padding: EdgeInsets.all(8.0),
        width: size.width,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: isDarkMode
                ? waringBgColorDark.withOpacity(.3)
                : warningBgColorLight.withOpacity(.3)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              SFSymbols.exclamationmark_triangle_fill,
              color: isDarkMode ? iconColorDark : iconColorLight,
            ),
            Container(
              width: size.width * 0.8,
              child: Text(bannerText,
                  style: TextStyle(
                      fontSize: 16,
                      color: isDarkMode ? textColorDark : textColorLight,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start),
            ),
          ],
        ),
      ),
    );
  }
}
