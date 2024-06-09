import 'package:e_book_reader/reader_content.dart';
import 'package:e_book_reader/reader_controller.dart';
import 'package:flutter/material.dart';

class ReaderPullToRefresh extends StatefulWidget {
  final Future<void> Function()? onRefreshTop;
  final Future<void> Function()? onRefreshBottom;
  final ReaderContent child;
  final Widget Function(double progress)? loading;
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
  int get scrollPosition => _readerController.scrollPosition;
  double get scrollHeight => _readerController.scrollHeight;
  double get contentHeight => _readerController.contentHeight;
  Axis get axis => _readerController.config.axis;

  bool _isRefreshingTop = false;
  bool _isRefreshingBottom = false;
  late ReaderPositionListener listener;
  @override
  void initState() {
    listener = () {
      setState(() {});
      if (!_isRefreshingTop &&
          widget.onRefreshTop != null &&
          _readerController.scrollPosition < -100) {
        _triggerRefreshTop();
      }
      if (!_isRefreshingBottom &&
          widget.onRefreshBottom != null &&
          scrollPosition > scrollHeight - contentHeight + 100) {
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
    await widget.onRefreshTop?.call();
    _readerController.scrollToPosition(0);
    setState(() {
      _isRefreshingTop = false;
    });
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

  double calculateIndicatorValue(
      double minScrollPosition, double maxScrollPosition) {
    double normalizedPosition = (scrollPosition - minScrollPosition) /
        (maxScrollPosition - minScrollPosition);

    if (normalizedPosition < 0) {
      return 0;
    }

    if (normalizedPosition > 1) {
      return 1;
    }
    return 1 - normalizedPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.onRefreshTop != null && scrollPosition < 0)
          Align(
            alignment: _readerController.config.axis == Axis.horizontal
                ? Alignment.centerLeft
                : Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.loading?.call(_isRefreshingTop
                      ? 1
                      : calculateIndicatorValue(-100, 0)) ??
                  CircularProgressIndicator(
                    value: _isRefreshingTop
                        ? null
                        : calculateIndicatorValue(-100, 0),
                  ),
            ),
          ),
        if (widget.onRefreshBottom != null &&
            scrollPosition > scrollHeight - contentHeight)
          Align(
            alignment: _readerController.config.axis == Axis.horizontal
                ? Alignment.centerRight
                : Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.loading?.call(_isRefreshingBottom
                      ? 1
                      : calculateIndicatorValue(-100, 0)) ??
                  CircularProgressIndicator(
                    value: _isRefreshingBottom
                        ? null
                        : calculateIndicatorValue(
                            scrollHeight - contentHeight + 100,
                            scrollHeight - contentHeight),
                  ),
            ),
          ),
      ],
    );
  }
}
