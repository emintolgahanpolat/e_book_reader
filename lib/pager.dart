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

      // Eğer tüm text sayfaya sığıyorsa
      if (endIndex >= remainingText.length) {
        pages.add(remainingText.trim());
        break;
      }

      // Kelimeyi ortadan bölmemek için boşluk arıyoruz
      int lastSpace = remainingText.lastIndexOf(' ', endIndex);

      // Eğer boşluk yoksa, ya çok uzun bir kelime var ya da tek kelime kalmış
      if (lastSpace == -1 || lastSpace == 0) {
        lastSpace = endIndex; // Mecburen tam endIndex kullan
      }

      pages.add(remainingText.substring(0, lastSpace).trim());
      remainingText = remainingText.substring(lastSpace).trim();
    }

    return pages;
  }
}
