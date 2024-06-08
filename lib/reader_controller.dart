import 'dart:async';
import 'dart:convert';

import 'package:e_book_reader/config.dart';
import 'package:e_book_reader/config_preference.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

typedef ReaderPositionListener = void Function();
typedef LoadingListener = Function(bool isLoading);

class ReaderController {
  late WebViewController _webViewController;
  WebViewController get webViewController => _webViewController;
  SharedConfigPreference? _sharedConfigPrefrence;
  late ReaderConfig _config;
  ReaderConfig get config => _config;
  void setConfig(ReaderConfig value) {
    _config = value;
    _sharedConfigPrefrence?.save(_config);
  }

  ReaderController({SharedConfigPreference? pref}) {
    _sharedConfigPrefrence = pref;
    _config = pref?.load() ?? ReaderConfig();
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
        if (Axis.horizontal == config.axis) {
          return;
        }

        List<double> mData = [1, 1, 1];
        try {
          mData = (jsonDecode(value.message) as List)
              .map<String>((item) => item.toString())
              .map((e) => double.tryParse(e) ?? 0)
              .toList();
        } catch (e) {
          // print(e);
        }

        _scrollPosition = mData[0].toInt();
        _contentHeight = mData[1];
        _scrollHeight = mData[2];
        for (var element in _positionListener) {
          element.call();
        }
      })
      ..addJavaScriptChannel("ScrollPositionX", onMessageReceived: (value) {
        if (Axis.vertical == config.axis) {
          return;
        }
        List<double> mData = [1, 1, 1];
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
        _scrollHeight = mData[2];
        for (var element in _positionListener) {
          element.call();
        }
      })
      ..setNavigationDelegate(NavigationDelegate(onPageStarted: (url) {
        setLoading(true);
      }, onPageFinished: (url) {
        if (_config.axis == Axis.horizontal) {
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
            d.style.webkitColumnCount = pageCount;
            d.style.columnGap = '10px';
				  }
initialize();""");
        }
        _injectCss([
          "* { padding: 0px !important; letter-spacing: normal !important; max-width: none !important; }"
        ]);
        _injectCss(["::selection { background: #ffb7b7; }"]);
        _injectCss(["* { font-family: ${config.fontFamily}!important; }"]);
        _injectCss(["* { font-size: ${config.fontSize} !important; }"]);
        _injectCss(
            ["* { font-weight: ${config.fontWeight.value} !important; }"]);
        _injectCss(["* { line-height:  ${config.lineHeight}  !important; }"]);
        _injectCss([
          "* { font-style: ${config.fontStyle.name.split(".").last} !important; }"
        ]);
        _injectCss([
          "* { text-align: ${config.textAlign.name.split(".").last} !important; }"
        ]);
        _injectCss([
          "body { margin: ${config.padding.top}px ${config.padding.right}px ${config.padding.bottom}px ${config.padding.left}px !important; }"
        ]);

        _injectCss([
          "body { background: rgb(${config.backgroundColor.red} ${config.backgroundColor.green} ${config.backgroundColor.blue}) !important; }"
        ]);
        _injectCss([
          "* { color: rgb(${config.foregroundColor.red} ${config.foregroundColor.green} ${config.foregroundColor.blue}) !important; }"
        ]);

        _injectCss([
          "img { display: block !important; width: 100% !important; height: auto !important; }"
        ]);
        setConfig(config);
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
    _loadingListener?.call(value);
  }

  LoadingListener? _loadingListener;
  void setLoadingListener(LoadingListener listener) {
    _loadingListener = listener;
  }

  double _scrollHeight = 0;
  double get scrollHeight => _scrollHeight;
  int _scrollPosition = 0;
  int get scrollPosition => _scrollPosition;
  double _contentHeight = 0;
  double get contentHeight => _contentHeight;

  int get totalPage {
    if (contentHeight == 0) {
      return 1;
    }
    return ((scrollHeight) / contentHeight).ceil();
  }

  int get currentPage {
    if (scrollPosition <= 0) {
      return 1;
    }
    return (scrollPosition ~/ contentHeight) + 1;
  }

  double get rate =>
      (scrollPosition / (scrollHeight - contentHeight)).clamp(0, 1);

  void setFontWeight(FontWeight weight) {
    _config.fontWeight = weight;
    _reload();
  }

  void setTextAlign(TextAlign align) {
    _config.textAlign = align;
    _reload();
  }

  void setFontSize(int size) {
    _config.fontSize = size;
    _reload();
  }

  void setFontStyle(FontStyle value) {
    _config.fontStyle = value;

    _reload();
  }

  List<String> get fonts =>
      ["default", "cursive", "monospace", "serif", "sans-serif"];

  void setFontFamily(String value) {
    _config.fontFamily = value;
    _reload();
  }

  void setLineHeight(double size) {
    _config.lineHeight = size;
    _reload();
  }

  void setPadding(EdgeInsets padding) {
    _config.padding = padding;
    _reload();
  }

  void setAxis(Axis axis) {
    _config.axis = axis;
    _reload();
  }

  void setColor(Color backgroundColor, Color foregroundColor) {
    _config.backgroundColor = backgroundColor;
    _config.foregroundColor = foregroundColor;
    _reload();
  }

  Future<void> scrollToRate(double rate) {
    var y = rate * (_scrollHeight - contentHeight);
    return scrollToPosition(y);
  }

  Future<void> scrollToPosition(double position) {
    if (Axis.horizontal == config.axis) {
      return _webViewController.scrollTo(
        position.toInt(),
        0,
      );
    }
    return _webViewController.scrollTo(0, position.toInt());
  }

  Future<void> scrollToPage(int page) {
    var y = page * contentHeight;
    return scrollToPosition(y);
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
        <div id="content" style="min-height: 100%;" >
        $_text
        </div>

         <script>
         document.getElementById('content').height = window.innerWidth
          function updatePageInfo(){
         
            var scrollPosition = window.scrollY;
            document.getElementById('content').style.height = Math.ceil(document.getElementById('content').scrollHeight / window.innerHeight) * window.innerHeight + 'px';
            var scrollHeight = document.getElementById('content').scrollHeight;

            ScrollPosition.postMessage([scrollPosition,window.innerHeight,scrollHeight]);
            ScrollPositionX.postMessage([window.scrollX,window.innerWidth,document.getElementById('content').scrollWidth]);
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
