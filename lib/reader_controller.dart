import 'dart:async';

import 'package:e_book_reader/config.dart';
import 'package:e_book_reader/config_preference.dart';
import 'package:flutter/material.dart';

typedef ReaderPositionListener = void Function();
typedef LoadingListener = Function(bool isLoading);

class ReaderController extends ValueNotifier<ReaderConfig> {
  SharedConfigPreference? _sharedConfigPrefrence;

  ReaderConfig get config => value;
  void setConfig(ReaderConfig config) {
    value = config;
    _sharedConfigPrefrence?.save(config);
  }

  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  ChangeNotifier get scrollNotifier {
    if (value.axis == Axis.horizontal) {
      return _pageController;
    } else {
      return _scrollController;
    }
  }

  final PageController _pageController = PageController();
  PageController get pageController => _pageController;
  ReaderController({SharedConfigPreference? pref, ReaderConfig? config})
      : super(pref?.load() ?? config ?? ReaderConfig()) {
    _sharedConfigPrefrence = pref;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients || _pageController.hasClients) {
        notifyListeners();
      }
    });
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(bool value) {
    _loading = value;
    _loadingListener?.call(value);
  }

  LoadingListener? _loadingListener;
  void setLoadingListener(LoadingListener listener) {
    _loadingListener = listener;
  }

  double get scrollSize {
    if (value.axis == Axis.horizontal) {
      return _pageController.hasClients
          ? _pageController.position.maxScrollExtent
          : .1;
    }
    return _scrollController.hasClients
        ? scrollController.position.maxScrollExtent
        : 0.1;
  }

  double get scrollPosition {
    if (value.axis == Axis.horizontal) {
      return _pageController.hasClients ? _pageController.offset : 0;
    }
    return _scrollController.hasClients ? scrollController.offset : 0;
  }

  double get contentSize {
    if (value.axis == Axis.horizontal) {
      return _pageController.hasClients
          ? _pageController.position.viewportDimension
          : 0;
    }
    return _scrollController.hasClients
        ? scrollController.position.viewportDimension
        : 0;
  }

  int get totalPage {
    if (contentSize <= 0 || scrollSize <= 0) {
      return 1;
    }
    return (scrollSize ~/ contentSize) + 1;
  }

  int get currentPage {
    if (contentSize <= 0 || scrollSize <= 0) {
      return 1;
    }
    return (scrollPosition ~/ contentSize) + 1;
  }

  double get rate {
    return (scrollPosition / (scrollSize)).clamp(0, 1);
  }

  void setFontWeight(FontWeight weight) {
    updateValue(value.copyWith(
      fontWeight: weight,
    ));
  }

  void setTextAlign(TextAlign align) {
    updateValue(value.copyWith(
      textAlign: align,
    ));
  }

  void setFontSize(double size) {
    updateValue(value.copyWith(
      fontSize: size,
    ));
  }

  void setFontStyle(FontStyle style) {
    updateValue(value.copyWith(
      fontStyle: style,
    ));
  }

  List<String> get fonts =>
      ["default", "cursive", "monospace", "serif", "sans-serif"];

  void setFontFamily(String family) {
    updateValue(value.copyWith(
      fontFamily: family,
    ));
  }

  void setLineHeight(double size) {
    updateValue(value.copyWith(
      lineHeight: size,
    ));
  }

  void setPadding(EdgeInsets padding) {
    updateValue(value.copyWith(
      padding: padding,
    ));
  }

  void setAxis(Axis axis) {
    updateValue(value.copyWith(
      axis: axis,
    ));
  }

  void setColor(Color backgroundColor, Color foregroundColor) {
    updateValue(
      value.copyWith(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }

  void scrollToRate(double rate) {
    if (_scrollController.hasClients) {
      var y = rate * (scrollSize - contentSize);
      _scrollController.jumpTo(y);
    } else {
      debugPrint("ScrollController has no clients. Cannot scroll to rate.");
    }
  }

  void scrollToPage(int page) {
    if (value.axis == Axis.horizontal) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(page);
      } else {
        debugPrint("PageController has no clients. Cannot scroll to page.");
      }
    } else {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(page * contentSize - contentSize);
      } else {
        debugPrint("ScrollController has no clients. Cannot scroll to page.");
      }
    }
  }

  final debouncer = Debouncer(milliseconds: 100);
  void updateValue(ReaderConfig newValue) {
    value = newValue;
    setConfig(newValue);
  }

  String? _text;
  String? get text => _text;
  Future<void> load(String text) async {
    _text = text;
    scrollToPage(0);
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
