import 'package:e_book_reader/transformer/transformer_page_view.dart';
import 'package:flutter/material.dart';

class DeepthPageTransformer extends PageTransformer {
  DeepthPageTransformer() : super(reverse: true);

  @override
  Widget transform(Widget child, TransformInfo info) {
    double position = info.position ?? 0;

    if (position <= 0) {
      return child;
    } else if (position <= 1) {
      return Transform.translate(
        offset: Offset((info.width ?? 0) * -position, 0.0),
        child: child,
      );
    }

    return child;
  }
}
