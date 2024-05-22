import 'package:e_book_reader/reader_controller.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReaderContent extends StatefulWidget {
  final ReaderController controller;
  final Widget? loadingWidget;
  const ReaderContent(
      {super.key, required this.controller, this.loadingWidget});

  @override
  State<ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends State<ReaderContent> {
  bool _loading = false;
  @override
  void initState() {
    widget.controller.setLoadingListener((v) {
      _loading = v;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.loadingWidget ?? const CircularProgressIndicator();
    }
    return WebViewWidget(
      controller: widget.controller.webViewController,
    );
  }
}
