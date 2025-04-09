import 'package:e_book_reader/pager.dart';
import 'package:e_book_reader/reader_controller.dart';
import 'package:flutter/material.dart';

class ReaderContent extends StatefulWidget {
  final ReaderController controller;
  final Widget? loadingWidget;
  final Widget Function(BuildContext context)? coverPageBuilder;
  final Widget Function(BuildContext context)? nextPageBuilder;
  final Widget Function(BuildContext context)? previousPageBuilder;

  const ReaderContent(
      {super.key,
      required this.controller,
      this.loadingWidget,
      this.coverPageBuilder,
      this.previousPageBuilder,
      this.nextPageBuilder});

  @override
  State<ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends State<ReaderContent> {
  ReaderController get controller => widget.controller;

  List<String> pages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        pages = TextPaginator(
          text: controller.text!,
          textStyle: controller.config.textStyle,
          pageSize: Size(
            MediaQuery.of(context).size.width -
                controller.config.padding.horizontal,
            MediaQuery.of(context).size.height -
                controller.config.padding.vertical,
          ),
        ).paginate();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller.text == null) {
      return Center(
        child:
            widget.loadingWidget ?? const CircularProgressIndicator.adaptive(),
      );
    }

    return LayoutBuilder(builder: (_, box) {
      return PageView.builder(
        controller: controller.pageController,
        itemCount: pages.length +
            (widget.coverPageBuilder != null ? 1 : 0) +
            (widget.nextPageBuilder != null ? 1 : 0),
        scrollDirection: controller.config.axis,
        pageSnapping:
            widget.coverPageBuilder != null && controller.currentPage == 1
                ? true
                : widget.nextPageBuilder != null &&
                        controller.currentPage - 1 == pages.length
                    ? true
                    : controller.config.axis == Axis.horizontal,
        physics: const ScrollPhysics(),
        itemBuilder: (context, index) {
          if (widget.coverPageBuilder != null && index == 0) {
            // İlk sayfa için coverBuilder'ı göster
            return widget.coverPageBuilder!(context);
          }
          if (widget.nextPageBuilder != null &&
              index ==
                  pages.length + (widget.coverPageBuilder != null ? 1 : 0)) {
            // Son sayfa için continueBuilder'ı göster
            return widget.nextPageBuilder!(context);
          }
          // Diğer sayfalar için metin göster
          final pageIndex = widget.coverPageBuilder != null ? index - 1 : index;
          return Padding(
            padding: controller.config.padding,
            child: Text(
              pages[pageIndex],
              style: TextStyle(
                fontSize: controller.config.fontSize,
                color: controller.config.foregroundColor,
              ),
            ),
          );
        },
      );
    });
  }
}
