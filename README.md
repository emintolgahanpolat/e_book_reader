# E-Book Reader

## Overview
The e_book_reader package provides a versatile and customizable e-book reading interface for Flutter applications. It supports features such as page scrolling, content loading, pull-to-refresh, and extensive customization options for the reading experience.

## Features
* Customizable text styles (font size, font weight, font style, etc.)
* Adjustable reading modes (light/dark)
* Scroll position tracking
* Horizontal and vertical reading layouts
* Integrated pull-to-refresh functionality

## Installation
To use this package, add e_book_reader as a dependency in your pubspec.yaml file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  e_book_reader: ^1.0.0
```
Then, run flutter pub get to install the package.

### Usage
Here is a step-by-step guide to using the e_book_reader package in your Flutter application.

```dart
import 'package:e_book_reader/e_book_reader.dart';
import 'package:e_book_reader/reader_controller.dart';
import 'package:e_book_reader/reader_pull_to_refresh.dart';
```
###  Basic Setup
Create a ReaderController and configure it in your widget:

```dart
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ReaderController _readerController = ReaderController();

  @override
  void initState() {
    _readerController.load(longText);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("E-Book Reader"),
      ),
      body: ReaderContent(
        controller: _readerController,
      ),
    );
  }
}
```


## Add Scroll Listener
```dart
@override
void initState() {
  _readerController.load(longText);
  _readerController.addScrollListener(() {
    print("Scroll Position: ${_readerController.scrollPosition}");
  });
  super.initState();
}

```

## Customizing the Reader
You can customize various aspects of the reader using the ReaderController:

```dart
_readerController.setFontSize(18);
_readerController.setFontWeight(FontWeight.bold);
_readerController.setFontStyle(FontStyle.italic);
_readerController.setTextAlign(TextAlign.justify);
_readerController.setColor(Colors.black, Colors.white);
_readerController.setAxis(Axis.horizontal);
_readerController.setLineHeight(1.8);
_readerController.setPadding(EdgeInsets.all(16));
_readerController.setFontFamily("serif");

```

## Pull-to-Refresh
To enable pull-to-refresh functionality, wrap the ReaderContent widget with ReaderPullToRefresh:

```dart
ReaderPullToRefresh(
  onRefreshTop: () async {
    // Handle top refresh
  },
  onRefreshBottom: () async {
    // Handle bottom refresh
  },
  child: ReaderContent(
    controller: _readerController,
  ),
)
```


## API Summary


|Method|	Description|
|--|--|
|load(String text)|	Loads the e-book text content|
|setFontSize(int size)	|Sets the font size|
|setFontWeight(FontWeight weight)|	Sets the font weight
|setFontStyle(FontStyle style)	|Sets the font style
|setTextAlign(TextAlign align)	|Sets the text alignment
|setColor(Color bgColor, Color fgColor)	|Sets the background and foreground colors
|setAxis(Axis axis)	|Sets the reading direction (vertical/horizontal)
|setLineHeight(double height)	|Sets the line height
|setPadding(EdgeInsets padding)|Sets the padding around the text
|setFontFamily(String family)|	Sets the font family
|scrollToRate(double rate)|	Scrolls to a specific position based on rate
|scrollToPosition(double position)|	Scrolls to a specific position|
|scrollToPage(int page)|	Scrolls to a specific page|