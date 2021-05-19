import 'package:orderista/constants.dart';
import 'package:flutter/material.dart';

class TagWidgetGenerator extends StatefulWidget {
  const TagWidgetGenerator({
    Key key,
    @required this.size,
    @required List<String> tagName,
    this.selectedIndex,
  })  : _tagName = tagName,
        super(key: key);

  final Size size;
  final List<String> _tagName;
  final int selectedIndex;

  @override
  _TagWidgetGenerator createState() => _TagWidgetGenerator();
}

class _TagWidgetGenerator extends State<TagWidgetGenerator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.height * 0.07,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: widget._tagName.length,
          itemBuilder: (context, index) {
            return TagDishes(
              size: widget.size,
              tagName: widget._tagName[index],
              index: index,
              selectedIndex: widget.selectedIndex,
            );
          }),
    );
  }
}

// ignore: must_be_immutable
class TagDishes extends StatefulWidget {
  TagDishes({
    Key key,
    @required this.size,
    this.tagName,
    this.index,
    this.selectedIndex,
  }) : super(key: key);

  final Size size;
  final String tagName;
  final int index;
  int selectedIndex;

  @override
  _TagDishes createState() => _TagDishes();
}

class _TagDishes extends State<TagDishes> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Change the _selectedIndex to the new selectedIndex
        setState(() {
          widget.selectedIndex = widget.index;
        });
        print(
            widget.selectedIndex.toString() + " : " + widget.index.toString());
        print("Index: " +
            widget.index.toString() +
            ", Tag Name: " +
            widget.tagName);
      },
      child: Container(
        margin: EdgeInsets.only(right: 40, top: 5, bottom: 5),
        height: widget.size.height * 0.05,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(widget.tagName,
                  style: TextStyle(
                      color: widget.index.toString() !=
                              widget.selectedIndex.toString()
                          ? Colors.black45
                          : Colors.black,
                      fontSize: 20)),
            ),
            widget.selectedIndex == widget.index
                ? Container(
                    height: 2,
                    width: 30,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [primaryColor, secondaryColor],
                        )),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
