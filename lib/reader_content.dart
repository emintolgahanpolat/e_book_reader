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

    return LayoutBuilder(builder: (context, box) {
      var pagesTexts = TextPaginator(
        text: controller.text!,
        textStyle: controller.config.textStyle,
        pageSize: Size(
          box.maxWidth - (controller.config.padding.horizontal * 2),
          box.maxHeight - (controller.config.padding.vertical * 2),
        ),
      ).paginate();
      var pages = [
        if (widget.previousPageBuilder != null)
          Container(
            color: controller.config.backgroundColor,
            child: widget.previousPageBuilder!(context),
          ),
        if (widget.previousPageBuilder == null &&
            widget.coverPageBuilder != null)
          Container(
            color: controller.config.backgroundColor,
            child: widget.coverPageBuilder!(context),
          ),
        for (var i = 0; i < pagesTexts.length; i++)
          Container(
            decoration: BoxDecoration(
              color: controller.config.backgroundColor,
              boxShadow: [
                if (controller.config.axis == Axis.horizontal)
                  const BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.0, 1.0), //(x,y)
                    blurRadius: 6.0,
                  ),
              ],
            ),
            padding: controller.config.padding,
            child: Text(
              pagesTexts[i],
              textAlign: controller.config.textAlign,
              style: controller.config.textStyle,
            ),
          ),
        if (widget.nextPageBuilder != null)
          Container(
              color: controller.config.backgroundColor,
              child: widget.nextPageBuilder!(context)),
      ];
      return Stack(
        fit: StackFit.expand,
        children: [
          if (controller.currentPage < pages.length)
            pages[controller.currentPage],
          PageView.builder(
            controller: controller.pageController,
            itemCount: pages.length,
            scrollDirection: controller.config.axis,
            pageSnapping:
                widget.coverPageBuilder != null && controller.currentPage == 1
                    ? true
                    : widget.nextPageBuilder != null &&
                            controller.currentPage - 1 == pagesTexts.length
                        ? true
                        : controller.config.axis == Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              final isCurrentPage = index == controller.currentPage;

              return Opacity(
                opacity: controller.config.axis == Axis.vertical
                    ? 1
                    : isCurrentPage
                        ? 0.0
                        : 1.0,
                child: pages[index],
              );
            },
          ),
        ],
      );
    });
  }
}
