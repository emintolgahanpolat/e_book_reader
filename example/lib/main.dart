import 'package:e_book_reader/config.dart';
import 'package:e_book_reader/e_book_reader.dart';
import 'package:example/const.dart';
import 'package:example/pref.dart';
import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class HomePage extends StatefulWidget {
  final SharedPreferences pref;
  const HomePage({super.key, required this.pref});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Map<String, String> chapters = {
    "Chapter1": longText,
    "Chapter2": longText,
    "Chapter3": longText,
    "Chapter4": longText,
  };
  MapEntry<String, String>? currentChapter;
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  late ReaderController _readerController;

  bool _isShow = false;

  @override
  void initState() {
    _readerController = ReaderController(
      pref: SharedConfigPrefrenceImpl(widget.pref),
      config: ReaderConfig(
        axis: Axis.horizontal,
      ),
    );
    setCurrentChapter(chapters.entries.first, jumpToPage: 0);
    super.initState();
  }

  void setCurrentChapter(MapEntry<String, String> chapter,
      {int jumpToPage = 1}) {
    currentChapter = chapter;
    _readerController.load(chapter.value);
    _readerController.jumpToPage(jumpToPage);
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
                  key: _globalKey,
                  appBar: AppBar(
                    elevation: 0,
                    centerTitle: false,
                    scrolledUnderElevation: 0,
                    backgroundColor: config.backgroundColor,
                    foregroundColor: config.foregroundColor,
                    title: const Text("Cover Page"),
                    actions: [
                      Row(
                        spacing: 16,
                        children: [
                          Text(
                              "${(_readerController.rate * 100).toStringAsFixed(0)}%"),
                          Text(
                            "${_readerController.currentPage} / ${_readerController.totalPage}",
                          ),
                        ],
                      ),
                    ],
                  ),
                  drawer: Drawer(
                    backgroundColor: config.backgroundColor,
                    child: ListView(
                      children: [
                        ...chapters.entries.map((e) => ListTile(
                              title: Text(e.key),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                setCurrentChapter(e);
                                _globalKey.currentState?.closeDrawer();
                              },
                            )),
                      ],
                    ),
                  ),
                  backgroundColor: config.backgroundColor,
                  body: SafeArea(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          _isShow = !_isShow;
                        });
                      },
                      child: ReaderContent(
                        coverPageBuilder: (context) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Welcome to the Book Reader"),
                              if (_readerController.config.axis ==
                                  Axis.horizontal)
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _readerController.jumpToPage(1);
                                  },
                                  label: const Icon(Icons.arrow_forward),
                                  icon: Text(
                                    "Start Reading",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              if (_readerController.config.axis ==
                                  Axis.vertical)
                                ElevatedButton(
                                  onPressed: () {
                                    _readerController.jumpToPage(1);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.arrow_upward),
                                        Text(
                                          "Start Reading",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                        previousPageBuilder: currentChapter?.key == "Chapter1"
                            ? null
                            : (context) {
                                return Center(
                                    child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Previous Chapter Loading..."),
                                      ),
                                    );
                                    setCurrentChapter(chapters.entries
                                        .elementAt(chapters.keys
                                                .toList()
                                                .indexOf(currentChapter!.key) -
                                            1));
                                  },
                                  child: Text(
                                    "Previous Chapter",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ));
                              },
                        nextPageBuilder: (context) {
                          return Center(
                              child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Next Chapter Loading..."),
                                ),
                              );
                              setCurrentChapter(chapters.entries.elementAt(
                                  chapters.keys
                                          .toList()
                                          .indexOf(currentChapter!.key) +
                                      1));
                            },
                            child: Text(
                              "Next Chapter",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ));
                        },
                        controller: _readerController,
                      ),
                    ),
                  ),
                  bottomSheet: buildSheet(config),
                );
              });
        });
  }

  Widget? buildSheet(ReaderConfig config) {
    if (!_isShow) {
      return null;
    }
    return Container(
      color: config.backgroundColor.darken(),
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
          top: 16,
          left: 16,
          right: 16),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Color(0xFFFFFFFF),
              const Color(0xFFC9DDC6),
              const Color(0xFFFADED7),
              const Color(0xFFEBE8E1),
              const Color(0xFFE3EAE9),
              const Color(0xFFCBD0EE),
            ]
                .map(
                  (e) => InkWell(
                    onTap: () {
                      _readerController.setColor(
                        e,
                        Colors.black,
                      );
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: e,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: config.foregroundColor,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PopupMenuButton<TextAlign>(
                  onSelected: (p) {
                    _readerController.setTextAlign(p);
                  },
                  constraints:
                      const BoxConstraints(minWidth: 42, minHeight: 42),
                  icon: Icon(
                    _readerController.config.textAlign.icon,
                  ),
                  itemBuilder: (c) => [
                        TextAlign.left,
                        TextAlign.right,
                        TextAlign.center,
                        TextAlign.justify
                      ]
                          .map((e) => PopupMenuItem<TextAlign>(
                              value: e,
                              child: Center(
                                child: Icon(
                                  e.icon,
                                ),
                              )))
                          .toList()),
              PopupMenuButton<String>(
                  onSelected: (v) {
                    print(v);
                    _readerController.setFontFamily(v);
                  },
                  icon: const Icon(Icons.font_download),
                  itemBuilder: (c) => [
                        GoogleFonts.openSans().fontFamily,
                        GoogleFonts.robotoSlab().fontFamily,
                        GoogleFonts.lora().fontFamily,
                        GoogleFonts.nunito().fontFamily,
                        GoogleFonts.merriweather().fontFamily,
                      ]
                          .map((e) => PopupMenuItem(
                              value: e,
                              child: Text(e?.replaceAll("_regular", "") ?? "")))
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
                    _readerController.setFontStyle(
                        config.fontStyle == FontStyle.italic
                            ? FontStyle.normal
                            : FontStyle.italic);
                  },
                  icon: const Icon(Icons.format_italic_rounded)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  onPressed: () {
                    _globalKey.currentState?.openDrawer();
                  },
                  icon: const Column(
                    children: [
                      Icon(
                        Icons.list,
                      ),
                      Text(
                        "Chapters",
                      ),
                    ],
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Column(
                    children: [
                      Icon(
                        Icons.light,
                      ),
                      Text(
                        "Brightness",
                      ),
                    ],
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Column(
                    children: [
                      Icon(
                        Icons.more_horiz,
                      ),
                      Text(
                        "More",
                      ),
                    ],
                  )),
            ],
          )
        ],
      ),
    );
  }
}
