import 'package:e_book_reader/pager.dart';
import 'package:e_book_reader/reader_controller.dart';
import 'package:flutter/material.dart';

class ReaderContent extends StatefulWidget {
  final ReaderController controller;
  final Widget? loadingWidget;
  const ReaderContent(
      {super.key, required this.controller, this.loadingWidget});

  @override
  State<ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends State<ReaderContent> {
  ReaderController get controller => widget.controller;
  @override
  Widget build(BuildContext context) {
    if (controller.text == null) {
      return widget.loadingWidget ?? const CircularProgressIndicator();
    }

    if (controller.config.axis == Axis.horizontal) {
      return LayoutBuilder(builder: (_, box) {
        var pages = TextPaginator(
          text: controller.text!,
          textStyle: TextStyle(
            fontSize: controller.config.fontSize,
            color: controller.config.foregroundColor,
          ),
          pageSize: Size(
            box.maxWidth - controller.config.padding.horizontal,
            box.maxHeight - controller.config.padding.vertical - 8,
          ),
        ).paginate();
        return PageView.builder(
          controller: controller.pageController,
          itemCount: pages.length,
          physics: const ScrollPhysics(),
          itemBuilder: (context, index) {
            return Padding(
              padding: controller.config.padding,
              child: Text(
                pages[index],
                style: TextStyle(
                  fontSize: controller.config.fontSize,
                  color: controller.config.foregroundColor,
                ),
              ),
            );
          },
        );
      });
    } else {
      return SingleChildScrollView(
        padding: controller.config.padding,
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        child: Text(
          controller.text!,
          style: TextStyle(
            fontSize: controller.config.fontSize,
            color: controller.config.foregroundColor,
          ),
        ),
      );
    }
  }
}
