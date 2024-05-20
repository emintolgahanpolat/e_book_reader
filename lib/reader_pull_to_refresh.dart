import 'package:e_book_reader/reader_content.dart';
import 'package:e_book_reader/reader_controller.dart';
import 'package:flutter/material.dart';

class ReaderPullToRefresh extends StatefulWidget {
  final Future<void> Function()? onRefreshTop;
  final Future<void> Function()? onRefreshBottom;
  final ReaderContent child;
  final Widget? loading;
  const ReaderPullToRefresh(
      {super.key,
      required this.child,
      this.onRefreshTop,
      this.onRefreshBottom,
      this.loading});

  @override
  State<ReaderPullToRefresh> createState() => _ReaderPullToRefreshState();
}

class _ReaderPullToRefreshState extends State<ReaderPullToRefresh> {
  ReaderController get _readerController => (widget.child).controller;
  bool _isRefreshingTop = false;
  bool _isRefreshingBottom = false;
  late ReaderPositionListener listener;
  @override
  void initState() {
    listener = () {
      setState(() {});
      if (!_isRefreshingTop &&
          widget.onRefreshTop != null &&
          _readerController.scrollPosition < -50) {
        _triggerRefreshTop();
      }
      if (!_isRefreshingBottom &&
          widget.onRefreshBottom != null &&
          _readerController.scrollPosition >
              _readerController.scrollHeight -
                  _readerController.contentHeight +
                  50) {
        _triggerRefreshBottom();
      }
    };
    _readerController.addScrollListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    _readerController.removeScrollListener(listener);
    super.dispose();
  }

  Future<void> _triggerRefreshTop() async {
    setState(() {
      _isRefreshingTop = true;
    });

    _readerController.scrollToPosition(-50);
    await widget.onRefreshTop?.call();
    setState(() {
      _isRefreshingTop = false;
    });
    _readerController.scrollToPosition(0);
  }

  Future<void> _triggerRefreshBottom() async {
    setState(() {
      _isRefreshingBottom = true;
    });
    await widget.onRefreshBottom?.call();
    setState(() {
      _isRefreshingBottom = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isRefreshingTop)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.loading ?? const CircularProgressIndicator(),
            ),
          ),
        if (_isRefreshingBottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.loading ?? const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
