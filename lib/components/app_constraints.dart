import 'package:flutter/material.dart';

class AppConstraintsContainer extends StatelessWidget {
  final double maxHeight = 650;
  final double maxWidth = 500;
  final double minHeight = 645;
  final double minWidth = 400;
  final EdgeInsetsGeometry? margin;
  final double? removeHeight;
  final Widget child;

  const AppConstraintsContainer(
      {Key? key, required this.child, this.margin, this.removeHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16),
      constraints: BoxConstraints(
          maxHeight: mediaQuery.size.height + 1500,
          maxWidth: maxWidth,
          minHeight:
              mediaQuery.size.height - (kToolbarHeight + (removeHeight ?? 0)),
          minWidth: minWidth),
      child: child,
    );
  }
}
