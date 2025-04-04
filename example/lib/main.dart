import 'package:e_book_reader/e_book_reader.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var pref = await SharedPreferences.getInstance();
  runApp(MyApp(pref: pref));
}

class MyApp extends StatelessWidget {
  final SharedPreferences pref;
  const MyApp({super.key, required this.pref});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SampleWebView(),
    );
  }
}

class SampleWebView extends StatefulWidget {
  const SampleWebView({super.key});

  @override
  State<SampleWebView> createState() => _SampleWebViewState();
}

class _SampleWebViewState extends State<SampleWebView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: ReaderContent()));
  }
}

// enum ScreenMode { full, more, settings }

// class HomePage extends StatefulWidget {
//   final SharedPreferences pref;
//   const HomePage({super.key, required this.pref});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late ReaderController _readerController;

//   ScreenMode _screenMode = ScreenMode.full;
//   Color color = Colors.white;

//   @override
//   void initState() {
//     _readerController = ReaderController();
//     _readerController.load(longText);

//     _readerController.addScrollListener(() {
//       setState(() {});
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: color,
//       child: SafeArea(
//         child: Scaffold(
//           backgroundColor: Colors.transparent,
//           appBar: AppBar(
//             title: const Text("Title"),
//             backgroundColor: color,
//             actions: [
//               Text("${(_readerController.rate * 100).toStringAsFixed(0)}%"),
//               const SizedBox(
//                 width: 16,
//               ),
//               Text(
//                   "${_readerController.currentPage} / ${_readerController.totalPage}")
//             ],
//           ),
//           extendBody: true,
//           body: Stack(
//             children: [
//               ReaderPullToRefresh(
//                 onRefreshTop: () async {
//                   await Future.delayed(const Duration(seconds: 4));
//                   return;
//                 },
//                 loading: (progress) {
//                   if (progress == 1) {
//                     return const Text("Loading");
//                   }
//                   return const Text("Pull To refresh");
//                 },
//                 onRefreshBottom: () async {
//                   await Future.delayed(const Duration(seconds: 4));

//                   return;
//                 },
//                 child: ReaderContent(
//                   controller: _readerController,
//                 ),
//               ),
//               GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onTap: () {
//                   if (ScreenMode.full == _screenMode) {
//                     _screenMode = ScreenMode.settings;
//                   } else if (ScreenMode.settings == _screenMode) {
//                     _screenMode = ScreenMode.full;
//                   } else if (ScreenMode.more == _screenMode) {
//                     _screenMode = ScreenMode.settings;
//                   }

//                   setState(() {});
//                 },
//                 child: Container(),
//               ),
//             ],
//           ),
//           bottomNavigationBar: buildSheet(),
//         ),
//       ),
//     );
//   }

//   Widget? buildSheet() {
//     switch (_screenMode) {
//       case ScreenMode.full:
//         return null;

//       case ScreenMode.settings:
//         return IntrinsicHeight(
//           child: Container(
//               color: color,
//               child: SafeArea(
//                 child: Column(
//                   children: [
//                     const Divider(
//                       height: 1,
//                     ),
//                     Slider(
//                       value: _readerController.rate,
//                       min: 0,
//                       max: 1,
//                       onChanged: (value) {
//                         _readerController.scrollToRate(value);
//                       },
//                     ),
//                     if (_readerController.totalPage > 0)
//                       Slider(
//                         divisions: _readerController.totalPage - 1,
//                         label: _readerController.currentPage.toString(),
//                         value: _readerController.currentPage
//                             .toDouble()
//                             .clamp(0, _readerController.totalPage.toDouble()),
//                         min: 1,
//                         max: _readerController.totalPage.toDouble(),
//                         onChanged: (value) {
//                           _readerController.scrollToPage(value.toInt());
//                         },
//                       ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       children: [
//                         IconButton(
//                             onPressed: () {},
//                             icon: const Column(
//                               children: [
//                                 Icon(Icons.list),
//                                 Text("Bölümler"),
//                               ],
//                             )),
//                         IconButton(
//                             onPressed: () {
//                               if (_readerController.config.backgroundColor ==
//                                   Colors.black) {
//                                 _readerController.setColor(
//                                     Colors.white, Colors.black);
//                               } else {
//                                 _readerController.setColor(
//                                     Colors.black, Colors.white);
//                               }
//                             },
//                             icon: Column(
//                               children: [
//                                 const Icon(Icons.light),
//                                 Text(_readerController.config.backgroundColor ==
//                                         Colors.black
//                                     ? "Light"
//                                     : "Dark"),
//                               ],
//                             )),
//                         IconButton(
//                             onPressed: () {
//                               _screenMode = ScreenMode.more;
//                               setState(() {});
//                             },
//                             icon: const Column(
//                               children: [
//                                 Icon(Icons.more_horiz),
//                                 Text("More"),
//                               ],
//                             )),
//                       ],
//                     )
//                   ],
//                 ),
//               )),
//         );
//       case ScreenMode.more:
//         return Container(
//           color: color,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Divider(
//                 height: 1,
//               ),
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Color(0xFFFFFFFF),
//                     const Color(0xFFC9DDC6),
//                     const Color(0xFFFADED7),
//                     const Color(0xFFEBE8E1),
//                     const Color(0xFFE3EAE9),
//                     const Color(0xFFCBD0EE)
//                   ]
//                       .map(
//                         (e) => InkWell(
//                           onTap: () {
//                             _readerController.setColor(e, Colors.black);
//                           },
//                           child: Container(
//                             width: 32,
//                             height: 32,
//                             decoration: BoxDecoration(
//                                 color: e,
//                                 shape: BoxShape.circle,
//                                 border: Border.all()),
//                           ),
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ),
//               SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 scrollDirection: Axis.horizontal,
//                 child: SegmentedButton(
//                     showSelectedIcon: false,
//                     style: SegmentedButton.styleFrom(
//                       visualDensity:
//                           const VisualDensity(horizontal: -3, vertical: -3),
//                     ),
//                     segments: TextAlign.values
//                         .map(
//                           (e) => ButtonSegment(
//                               value: e, label: FittedBox(child: Text(e.name))),
//                         )
//                         .toList(),
//                     onSelectionChanged: (p) {
//                       _readerController.setTextAlign(p.first);
//                     },
//                     selected: {_readerController.config.textAlign}),
//               ),
//               const SizedBox(
//                 height: 8,
//               ),
//               SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 scrollDirection: Axis.horizontal,
//                 child: SegmentedButton<FontStyle>(
//                     showSelectedIcon: false,
//                     style: SegmentedButton.styleFrom(
//                       visualDensity:
//                           const VisualDensity(horizontal: -3, vertical: -3),
//                     ),
//                     segments: FontStyle.values
//                         .map(
//                           (e) => ButtonSegment(
//                               value: e, label: FittedBox(child: Text(e.name))),
//                         )
//                         .toList(),
//                     onSelectionChanged: (p) {
//                       _readerController.setFontStyle(p.first);
//                     },
//                     selected: {_readerController.config.fontStyle}),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Wrap(
//                   children: [
//                     PopupMenuButton<String>(
//                         onSelected: (v) {
//                           _readerController.setFontFamily(v);
//                         },
//                         icon: const Icon(Icons.font_download),
//                         itemBuilder: (c) => _readerController.fonts
//                             .map((e) => PopupMenuItem(
//                                 value: e, child: Text(e.toString())))
//                             .toList()),
//                     IconButton(
//                         onPressed: () {
//                           _readerController.setAxis(
//                               _readerController.config.axis == Axis.horizontal
//                                   ? Axis.vertical
//                                   : Axis.horizontal);
//                         },
//                         icon: Icon(
//                             _readerController.config.axis == Axis.vertical
//                                 ? Icons.vertical_distribute
//                                 : Icons.horizontal_distribute)),
//                     PopupMenuButton<int>(
//                         onSelected: (v) {
//                           _readerController.setFontWeight(FontWeight.values
//                               .firstWhere((element) => element.value == v));
//                         },
//                         icon: const Icon(Icons.format_bold_rounded),
//                         itemBuilder: (c) => FontWeight.values
//                             .map((e) => PopupMenuItem(
//                                 value: e.value,
//                                 child: Text(e.value.toString())))
//                             .toList()),
//                     IconButton(
//                         onPressed: () {
//                           _readerController.setFontSize(
//                               _readerController.config.fontSize - 1);
//                         },
//                         icon: const Icon(Icons.text_decrease)),
//                     IconButton(
//                         onPressed: () {
//                           _readerController.setFontSize(
//                               _readerController.config.fontSize + 1);
//                         },
//                         icon: const Icon(Icons.text_increase_rounded)),
//                     IconButton(
//                         onPressed: () {
//                           _readerController.setLineHeight(
//                               _readerController.config.lineHeight - 0.1);
//                         },
//                         icon: const Icon(Icons.text_rotate_vertical_rounded)),
//                     IconButton(
//                         onPressed: () {
//                           _readerController.setLineHeight(
//                               _readerController.config.lineHeight + 0.1);
//                         },
//                         icon: const Icon(Icons.text_rotate_up_outlined)),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         );
//     }
//   }
// }

// class SharedConfigPrefrenceImpl extends SharedConfigPreference {
//   final SharedPreferences _pref;
//   SharedConfigPrefrenceImpl(this._pref);
//   @override
//   ReaderConfig? load() {
//     ReaderConfig? config;
//     String? data = _pref.getString("ReaderConfig3");
//     if (data == null) {
//       return null;
//     }
//     try {
//       config = ReaderConfig.fromJson(json.decode(data));
//     } catch (e) {
//       print(e);
//     }
//     return config;
//   }

//   @override
//   void save(ReaderConfig config) {
//     _pref.setString("ReaderConfig3", json.encode(config.toJson()));
//   }
// }
