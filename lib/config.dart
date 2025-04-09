import 'package:flutter/material.dart';

class ReaderConfig {
  Axis axis;
  FontWeight fontWeight;
  FontStyle fontStyle;
  TextAlign textAlign;
  String fontFamily;
  double fontSize;
  double lineHeight;
  EdgeInsets padding;
  Color backgroundColor;
  Color foregroundColor;

  ReaderConfig({
    this.axis = Axis.vertical,
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
    this.textAlign = TextAlign.left,
    this.fontFamily = "default",
    this.fontSize = 16,
    this.lineHeight = 1.6,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
  });

  factory ReaderConfig.fromJson(Map<String, dynamic> json) {
    return ReaderConfig(
      axis: Axis.values[json["axis"] as int],
      fontWeight: FontWeight.values[json["fontWeight"] as int],
      fontStyle: FontStyle.values[json["fontStyle"] as int],
      textAlign: TextAlign.values[json["textAlign"] as int],
      fontFamily: json["fontFamily"],
      fontSize: json["fontSize"],
      lineHeight: json["lineHeight"],
      padding: EdgeInsets.fromLTRB(
        json["padding"]["left"],
        json["padding"]["top"],
        json["padding"]["right"],
        json["padding"]["bottom"],
      ),
      backgroundColor: Color(json["backgroundColor"]),
      foregroundColor: Color(json["foregroundColor"]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "axis": axis.index,
      "fontWeight": fontWeight.index,
      "fontStyle": fontStyle.index,
      "textAlign": textAlign.index,
      "fontFamily": fontFamily,
      "fontSize": fontSize,
      "lineHeight": lineHeight,
      "padding": {
        "left": padding.left,
        "top": padding.top,
        "right": padding.right,
        "bottom": padding.bottom,
      },
      "backgroundColor": backgroundColor.toARGB32(),
      "foregroundColor": foregroundColor.toARGB32(),
    };
  }

  ReaderConfig copyWith({
    Axis? axis,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    TextAlign? textAlign,
    String? fontFamily,
    double? fontSize,
    double? lineHeight,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ReaderConfig(
      axis: axis ?? this.axis,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      textAlign: textAlign ?? this.textAlign,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      padding: padding ?? this.padding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
    );
  }
}
