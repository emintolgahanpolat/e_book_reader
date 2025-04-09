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

  @override
  Widget build(BuildContext context) {
    if (controller.text == null) {
      return Center(
        child:
            widget.loadingWidget ?? const CircularProgressIndicator.adaptive(),
      );
    }

    return LayoutBuilder(builder: (_, box) {
      var pages = TextPaginator(
        text: controller.text!,
        textStyle: controller.config.textStyle,
        pageSize: Size(
          box.maxWidth - controller.config.padding.horizontal,
          box.maxHeight - (controller.config.padding.vertical * 4),
        ),
      ).paginate();
      return PageView.builder(
        controller: controller.pageController,
        itemCount: pages.length +
            (widget.previousPageBuilder != null
                ? 1
                : (widget.coverPageBuilder != null ? 1 : 0)) +
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
          if (widget.previousPageBuilder != null && index == 0) {
            // İlk sayfa için previousPageBuilder'ı göster
            return widget.previousPageBuilder!(context);
          }
          if (widget.coverPageBuilder != null &&
              widget.previousPageBuilder == null &&
              index == 0) {
            // İlk sayfa için coverPageBuilder'ı göster (previousPageBuilder yoksa)
            return widget.coverPageBuilder!(context);
          }
          if (widget.nextPageBuilder != null &&
              index ==
                  pages.length +
                      (widget.previousPageBuilder != null
                          ? 1
                          : (widget.coverPageBuilder != null ? 1 : 0))) {
            // Son sayfa için nextPageBuilder'ı göster
            return widget.nextPageBuilder!(context);
          }
          // Diğer sayfalar için metin göster
          final pageIndex = (widget.previousPageBuilder != null ||
                  widget.coverPageBuilder != null)
              ? index - 1
              : index;
          return Padding(
            padding: controller.config.padding,
            child: Text(
              pages[pageIndex],
              style: controller.config.textStyle,
            ),
          );
        },
      );
    });
  }
}
