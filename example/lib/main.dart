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
                  bottomSheet: buildSheet(config),
                );
              });
        });
  }

  Widget? buildSheet(ReaderConfig config) {
    if (!_isShow) {
      return null;
    }
    return Theme(
      data: Theme.of(context).copyWith(
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
              backgroundColor: config.backgroundColor,
              foregroundColor: config.foregroundColor),
        ),
      ),
      child: Container(
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
                const Color(0xFF000000)
              ]
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        if (e == const Color(0xFF000000)) {
                          _readerController.setColor(
                            e,
                            Colors.white,
                          );
                        } else {
                          _readerController.setColor(
                            e,
                            Colors.black,
                          );
                        }
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
                    color: _readerController.config.backgroundColor,
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
                                    color: _readerController
                                        .config.textStyle.color,
                                  ),
                                )))
                            .toList()),
                PopupMenuButton<String>(
                    style: TextButton.styleFrom(
                      backgroundColor: config.backgroundColor,
                      foregroundColor: config.foregroundColor,
                    ),
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
                                child:
                                    Text(e?.replaceAll("_regular", "") ?? "")))
                            .toList()),
                PopupMenuButton<int>(
                    style: TextButton.styleFrom(
                      backgroundColor: config.backgroundColor,
                      foregroundColor: config.foregroundColor,
                    ),
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
          ],
        ),
      ),
    );
  }
}
