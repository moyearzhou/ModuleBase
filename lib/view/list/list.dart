import 'package:flutter/material.dart';
import 'package:module_base/ext/common.dart';
final class MultiList extends StatefulWidget {
  final List<List<Widget>> children;
  final double horizonPadding;
  final double bottomPadding;
  final double betweenPadding;
  final double widthDivider;
  final bool? thumbVisibility;
  final bool? trackVisibility;

  const MultiList({
    super.key,
    required this.children,
    this.bottomPadding = 17,
    this.horizonPadding = 17,
    this.widthDivider = 2,
    this.thumbVisibility,
    this.trackVisibility,
    this.betweenPadding = 10,
  });

  @override
  State<MultiList> createState() => _MultiListState();
}

final class _MultiListState extends State<MultiList> {
  var _isWide = false;
  final _wideScroll = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isWide = context.isWide;
  }

  @override
  Widget build(BuildContext context) {
    final childrenLen = widget.children.length;
    if (_isWide) {
      final width = (context.windowSize.width - 2 * widget.horizonPadding) /
          widget.widthDivider;
      return Scrollbar(
        controller: _wideScroll,
        thumbVisibility: widget.thumbVisibility,
        trackVisibility: widget.trackVisibility,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: widget.horizonPadding),
          controller: _wideScroll,
          scrollDirection: Axis.horizontal,
          itemCount: childrenLen,
          itemBuilder: (_, i) {
            final children = widget.children[i];
            return SizedBox(
              width: width,
              child: ListView(
                padding: EdgeInsets.only(
                  right: i == childrenLen - 1 ? 0 : widget.betweenPadding,
                  bottom: widget.bottomPadding,
                ),
                children: children,
              ),
            );
          },
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.only(
        left: widget.horizonPadding,
        right: widget.horizonPadding,
        bottom: widget.bottomPadding,
      ),
      children: widget.children.fold([], (acc, e) {
        acc.addAll(e);
        return acc;
      }),
    );
  }
}
