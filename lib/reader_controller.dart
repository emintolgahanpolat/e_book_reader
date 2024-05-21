import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

typedef ReaderPositionListener = void Function();
typedef LoadingListener = Function(bool isLoading);

class ReaderController {
  ReaderController() {
    final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel("ScrollPosition", onMessageReceived: (value) {
        List<double> mData = [1, 1];
        try {
          mData = (jsonDecode(value.message) as List)
              .map<String>((item) => item.toString())
              .map((e) => double.tryParse(e) ?? 0)
              .toList();
        } catch (e) {
          // print(e);
        }
        _scrollPosition = mData.first.toInt();
        _contentHeight = mData[1];
        _scrollHeight = mData[2] + (padding.vertical);
        for (var element in _positionListener) {
          element.call();
        }
      })
      ..setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
        setLoading(true);
      }, onPageFinished: (url) {
        if (axis == Axis.horizontal) {
          _webViewController.runJavaScript("""
function initialize(){
				    var d = document.getElementById('content');
            var ourH = window.innerHeight;
            var ourW = window.innerWidth;
            var fullH = d.offsetHeight;
            var pageCount = Math.floor(fullH / ourH);

            var currentPage = 0;
            var newW = pageCount * ourW;
            d.style.height = ourH + 'px';
            d.style.width = newW + 'px';
            d.style.margin = '0';
            d.style.overflowX = 'scroll';
            d.style.overflowY = 'hidden';
            d.style.webkitColumnCount = pageCount;
            d.style.columnGap = '10px';
				  }
initialize();""");
        }
        _injectCss([
          "* { padding: 0px !important; letter-spacing: normal !important; max-width: none !important; }"
        ]);
        _injectCss(["::selection { background: #ffb7b7; }"]);
        _injectCss(["* { font-family: $fontFamily!important; }"]);
        _injectCss(["* { font-size: $_fontSize !important; }"]);
        _injectCss(["* { font-weight: ${_fontWeight.value} !important; }"]);
        _injectCss(["* { line-height:  $_lineHeight  !important; }"]);
        _injectCss([
          "* { font-style: ${_fontStyle.name.split(".").last} !important; }"
        ]);
        _injectCss([
          "* { text-align: ${_textAlign.name.split(".").last} !important; }"
        ]);
        _injectCss([
          "body { margin: ${_padding.top}px ${_padding.right}px ${_padding.bottom}px ${_padding.left}px !important; }"
        ]);

        _injectCss([
          "body { background: rgb(${_backgroundColor.red} ${_backgroundColor.green} ${_backgroundColor.blue}) !important; }"
        ]);
        _injectCss([
          "* { color: rgb(${_foregroundColor.red} ${_foregroundColor.green} ${_foregroundColor.blue}) !important; }"
        ]);

        _injectCss([
          "img { display: block !important; width: 100% !important; height: auto !important; }"
        ]);
        setLoading(false);
      }))
      ..setBackgroundColor(Colors.transparent)
      ..enableZoom(false);

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }
  final List<ReaderPositionListener> _positionListener = [];
  void addScrollListener(ReaderPositionListener listerner) {
    _positionListener.add(listerner);
  }

  void removeScrollListener(ReaderPositionListener listerner) {
    _positionListener.remove(listerner);
  }

  bool _loading = false;
  bool get loading => _loading;
  void setLoading(bool value) {
    _loading = value;
  }

  double _scrollHeight = 0;
  double get scrollHeight => _scrollHeight;
  int _scrollPosition = 0;
  int get scrollPosition => _scrollPosition;
  double _contentHeight = 0;
  double get contentHeight => _contentHeight;

  int get totalPage {
    if (contentHeight == 0) {
      return 0;
    }
    return ((scrollHeight - contentHeight) / contentHeight).ceil();
  }

  int get currentPage {
    if (contentHeight == 0) {
      return 0;
    }
    return (scrollPosition / contentHeight).ceil();
  }

  double get rate =>
      (scrollPosition / (scrollHeight - contentHeight)).clamp(0, 1);
  late WebViewController _webViewController;
  WebViewController get webViewController => _webViewController;

  FontWeight _fontWeight = FontWeight.normal;
  FontWeight get fontWeight => _fontWeight;
  void setFontWeight(FontWeight weight) {
    _fontWeight = weight;
    _reload();
  }

  TextAlign _textAlign = TextAlign.left;
  TextAlign get textAlign => _textAlign;
  void setTextAlign(TextAlign align) {
    _textAlign = align;
    _reload();
  }

  int _fontSize = 16;
  int get fontSize => _fontSize;
  void setFontSize(int size) {
    _fontSize = size;
    _reload();
  }

  FontStyle _fontStyle = FontStyle.normal;
  FontStyle get fontStyle => _fontStyle;
  void setFontStyle(FontStyle value) {
    _fontStyle = value;

    _reload();
  }

  List<String> get fonts =>
      ["default", "cursive", "monospace", "serif", "sans-serif"];
  String _fontFamily = "default";
  String get fontFamily => _fontFamily;
  void setFontFamily(String value) {
    _fontFamily = value;
    _reload();
  }

  double _lineHeight = 1.6;
  double get lineHeight => _lineHeight;
  void setLineHeight(double size) {
    _lineHeight = size;
    _reload();
  }

  EdgeInsets _padding = const EdgeInsets.all(8);
  EdgeInsets get padding => _padding;
  void setPadding(EdgeInsets padding) {
    _padding = padding;
    _reload();
  }

  Axis _axis = Axis.vertical;
  Axis get axis => _axis;
  void setAxis(Axis axis) {
    _axis = axis;

    _reload();
  }

  Color _foregroundColor = Colors.black;
  Color get foregroundColor => _foregroundColor;
  Color _backgroundColor = Colors.white;
  Color get backgroundColor => _backgroundColor;
  void setColor(Color backgroundColor, Color foregroundColor) {
    _backgroundColor = backgroundColor;
    _foregroundColor = foregroundColor;
    _reload();
  }

  Future<void> scrollToRate(double rate) {
    var y = rate * (_scrollHeight - contentHeight);
    return _webViewController.scrollTo(0, y.toInt());
  }

  Future<void> scrollToPosition(double position) {
    return _webViewController.scrollTo(0, position.toInt());
  }

  Future<void> scrollToPage(int page) {
    var y = page * contentHeight;
    return _webViewController.scrollTo(0, y.toInt());
  }

  final debouncer = Debouncer(milliseconds: 100);
  void _reload() {
    debouncer.run(_webViewController.reload);
  }

  String? _text;
  Future<void> load(String text) async {
    _text = text;
    String html = """
    <html>
      <head>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
      </head>
   
      <body>
        <div id="content" >
        $_text
        </div>

         <script>
          function updatePageInfo(){
            var scrollPosition = window.scrollY;
            var scrollHeight = document.getElementById('content').scrollHeight;
            ScrollPosition.postMessage([scrollPosition,window.innerHeight,scrollHeight]);
          }

          window.addEventListener('scroll', updatePageInfo);
          window.addEventListener('load', updatePageInfo);
          window.addEventListener('resize', updatePageInfo);
     

     
          
    </script>
      </body>
    </html>
    """;
    //  String fileHtmlContents = await rootBundle.loadString('assets/index.html');

    return _webViewController.loadRequest(
        Uri.dataFromString(html, mimeType: 'text/html', encoding: utf8));
  }

  final String _createCustomSheet =
      "if (typeof(document.head) != 'undefined' && typeof(customSheet) == 'undefined') {var customSheet = (function() {var style = document.createElement(\"style\");style.appendChild(document.createTextNode(\"\"));document.head.appendChild(style);return style.sheet;})();}";
  void _injectCss(List<String> cssRules) {
    var jsUrl = StringBuffer("javascript:");
    jsUrl
      ..write(_createCustomSheet)
      ..write("if (typeof(customSheet) != 'undefined') {");
    var cnt = 0;
    for (var cssRule in cssRules) {
      jsUrl.write("customSheet.insertRule('$cssRule', $cnt);");
      cnt++;
    }
    jsUrl.write("}");
    _webViewController.runJavaScript(jsUrl.toString());
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
