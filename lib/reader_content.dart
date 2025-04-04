import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ReaderContent extends StatefulWidget {
  const ReaderContent({super.key});

  @override
  State<ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends State<ReaderContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialFile: "packages/e_book_reader/assets/build/index.html",
      initialSettings: InAppWebViewSettings(
        mediaPlaybackRequiresUserGesture: false,
        transparentBackground: true,
        disableContextMenu: true,
        supportZoom: false,
        useShouldInterceptRequest: true,
        disableHorizontalScroll: false,
        disableVerticalScroll: false,
        allowsInlineMediaPlayback: true,
        allowFileAccess: true,
        allowUniversalAccessFromFileURLs: true,
        allowsAirPlayForMediaPlayback: true,
        allowsPictureInPictureMediaPlayback: true,
        useWideViewPort: false,
        isInspectable: kDebugMode,
        // webViewAssetLoader: WebViewAssetLoader(
        //   pathHandlers: [
        //     AssetsPathHandler(path: 'packages/e_book_reader/assets/build/')
        //   ],
        // ),
      ),
      onWebViewCreated: (controller) {},
    );
  }
}
