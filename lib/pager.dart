import 'package:flutter/material.dart';

class TextPaginator {
  final String text;
  final TextStyle textStyle;
  final Size pageSize;

  TextPaginator({
    required this.text,
    required this.textStyle,
    required this.pageSize,
  });

  List<String> paginate() {
    final List<String> pages = [];
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    String remainingText = text;
    while (remainingText.isNotEmpty) {
      textPainter.text = TextSpan(text: remainingText, style: textStyle);
      textPainter.layout(maxWidth: pageSize.width);

      int endIndex = textPainter
          .getPositionForOffset(
            Offset(pageSize.width, pageSize.height),
          )
          .offset;

      // Kelimeyi yarıda kesmemek için bir önceki boşluğa kadar geri git
      while (endIndex > 0 && remainingText[endIndex - 1] != ' ') {
        endIndex--;
      }

      if (endIndex == 0) {
        break;
      }

      pages.add(remainingText.substring(0, endIndex).trim());
      remainingText = remainingText.substring(endIndex).trim();
    }

    return pages;
  }
}
