import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final String? fontFamily;
  final TextDecoration? decoration;
  final bool? isItalize;
  final bool? isBold;
  final int? maxLines; // Add maxLines property

  const TextWidget({
    super.key,
    this.decoration,
    this.isItalize = false,
    this.isBold = false,
    required this.text,
    required this.fontSize,
    this.color = Colors.black,
    this.fontFamily = 'Regular',
    this.maxLines, // Initialize maxLines property
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontStyle: isItalize! ? FontStyle.italic : null,
        decoration: decoration,
        fontWeight: isBold! ? FontWeight.bold : FontWeight.normal,
        fontSize: fontSize,
        fontFamily: fontFamily,
      ),
      maxLines: maxLines, // Set maxLines property
      overflow: TextOverflow.ellipsis, // Add an ellipsis when text overflows
    );
  }
}
