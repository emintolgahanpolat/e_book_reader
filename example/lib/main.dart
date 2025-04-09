import 'dart:convert';

import 'package:e_book_reader/config.dart';
import 'package:e_book_reader/e_book_reader.dart';
import 'package:example/const.dart';
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
      home: HomePage(pref: pref),
    );
  }
}

enum ScreenMode { full, more, settings }

class HomePage extends StatefulWidget {
  final SharedPreferences pref;
  const HomePage({super.key, required this.pref});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ReaderController _readerController;

  bool _isShow = false;

  @override
  void initState() {
    _readerController = ReaderController(
      config: ReaderConfig(
        axis: Axis.horizontal,
      ),
    );
    _readerController.load(longText);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ReaderConfig>(
        valueListenable: _readerController,
        builder: (context, config, child) {
          return ListenableBuilder(
              listenable: _readerController.scrollNotifier,
              builder: (context, widget) {
                return Scaffold(
                  backgroundColor: config.backgroundColor,
                  appBar: AppBar(
                    title: const Text("Title"),
                    backgroundColor: config.backgroundColor,
                    foregroundColor: config.foregroundColor,
                    scrolledUnderElevation: 0,
                    actions: [
                      Text(
                          "${(_readerController.rate * 100).toStringAsFixed(0)}%"),
                      const SizedBox(
                        width: 16,
                      ),
                      Text(
                          "${_readerController.currentPage} / ${_readerController.totalPage}")
                    ],
                  ),
                  extendBody: true,
                  body: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      setState(() {
                        _isShow = !_isShow;
                      });
                    },
                    child: ReaderContent(
                      coverPageBuilder: (context) {
                        return Center(
                            child: Text(
                          "Merhaba",
                          style: Theme.of(context).textTheme.titleLarge,
                        ));
                      },
                      previousPageBuilder: (context) {
                        return Center(
                            child: Text(
                          "Önceki Bölüme Dön",
                          style: Theme.of(context).textTheme.titleLarge,
                        ));
                      },
                      nextPageBuilder: (context) {
                        return Center(
                            child: Text(
                          "Devam Et",
                          style: Theme.of(context).textTheme.titleLarge,
                        ));
                      },
                      controller: _readerController,
                    ),
                  ),
                  bottomNavigationBar: buildSheet(config),
                );
              });
        });
  }

  Widget? buildSheet(ReaderConfig config) {
    if (!_isShow) {
      return null;
    }
    return Container(
      color: config.backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Color(0xFFFFFFFF),
                const Color(0xFFC9DDC6),
                const Color(0xFFFADED7),
                const Color(0xFFEBE8E1),
                const Color(0xFFE3EAE9),
                const Color(0xFFCBD0EE)
              ]
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        _readerController.setColor(e, Colors.black);
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                            color: e,
                            shape: BoxShape.circle,
                            border: Border.all()),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            child: SegmentedButton(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity:
                      const VisualDensity(horizontal: -3, vertical: -3),
                ),
                segments: TextAlign.values
                    .map(
                      (e) => ButtonSegment(
                          value: e, label: FittedBox(child: Text(e.name))),
                    )
                    .toList(),
                onSelectionChanged: (p) {
                  _readerController.setTextAlign(p.first);
                },
                selected: {_readerController.config.textAlign}),
          ),
          const SizedBox(
            height: 8,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<FontStyle>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity:
                      const VisualDensity(horizontal: -3, vertical: -3),
                ),
                segments: FontStyle.values
                    .map(
                      (e) => ButtonSegment(
                          value: e, label: FittedBox(child: Text(e.name))),
                    )
                    .toList(),
                onSelectionChanged: (p) {
                  _readerController.setFontStyle(p.first);
                },
                selected: {_readerController.config.fontStyle}),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              children: [
                IconButton(
                    onPressed: () {
                      _readerController.setAxis(
                          _readerController.config.axis == Axis.horizontal
                              ? Axis.vertical
                              : Axis.horizontal);
                    },
                    icon: Icon(_readerController.config.axis == Axis.vertical
                        ? Icons.vertical_distribute
                        : Icons.horizontal_distribute)),
                PopupMenuButton<String>(
                    onSelected: (v) {
                      _readerController.setFontFamily(v);
                    },
                    icon: const Icon(Icons.font_download),
                    itemBuilder: (c) => _readerController.fonts
                        .map((e) =>
                            PopupMenuItem(value: e, child: Text(e.toString())))
                        .toList()),
                PopupMenuButton<int>(
                    onSelected: (v) {
                      _readerController.setFontWeight(FontWeight.values
                          .firstWhere((element) => element.value == v));
                    },
                    icon: const Icon(Icons.format_bold_rounded),
                    itemBuilder: (c) => FontWeight.values
                        .map((e) => PopupMenuItem(
                            value: e.value, child: Text(e.value.toString())))
                        .toList()),
                IconButton(
                    onPressed: () {
                      _readerController
                          .setFontSize(_readerController.config.fontSize - 1);
                    },
                    icon: const Icon(Icons.text_decrease)),
                IconButton(
                    onPressed: () {
                      _readerController
                          .setFontSize(_readerController.config.fontSize + 1);
                    },
                    icon: const Icon(Icons.text_increase_rounded)),
                IconButton(
                    onPressed: () {
                      _readerController.setLineHeight(
                          _readerController.config.lineHeight - 0.1);
                    },
                    icon: const Icon(Icons.text_rotate_vertical_rounded)),
                IconButton(
                    onPressed: () {
                      _readerController.setLineHeight(
                          _readerController.config.lineHeight + 0.1);
                    },
                    icon: const Icon(Icons.text_rotate_up_outlined)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SharedConfigPrefrenceImpl extends SharedConfigPreference {
  final SharedPreferences _pref;
  SharedConfigPrefrenceImpl(this._pref);
  @override
  ReaderConfig? load() {
    ReaderConfig? config;
    String? data = _pref.getString("ReaderConfig3");
    if (data == null) {
      return null;
    }
    try {
      config = ReaderConfig.fromJson(json.decode(data));
    } catch (e) {
      print(e);
    }
    return config;
  }

  @override
  void save(ReaderConfig config) {
    _pref.setString("ReaderConfig3", json.encode(config.toJson()));
  }
}
