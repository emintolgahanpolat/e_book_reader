import 'package:e_book_reader/reader_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReaderContent extends StatelessWidget {
  final ReaderController controller;
  final Widget? loadingWidget;
  const ReaderContent(
      {super.key, required this.controller, this.loadingWidget});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: controller.loadingStream,
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return WebViewWidget(
              controller: controller.webViewController,
            );
          }
          return loadingWidget ?? const SizedBox();
        });
  }
}
