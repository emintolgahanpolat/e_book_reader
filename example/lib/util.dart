import 'package:flutter/material.dart';

extension ColorsEx on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

extension TextAlignEx on TextAlign {
  IconData get icon {
    switch (this) {
      case TextAlign.left:
        return Icons.format_align_left;
      case TextAlign.right:
        return Icons.format_align_right;
      case TextAlign.center:
        return Icons.format_align_center;
      case TextAlign.justify:
        return Icons.format_align_justify;
      case TextAlign.start:
        return Icons.format_align_left;
      case TextAlign.end:
        return Icons.format_align_right;
    }
  }
}
