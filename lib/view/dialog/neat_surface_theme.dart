import 'package:flutter/material.dart';
import 'package:neatly/neatly.dart';

/// Keeps a route's local appearance while inheriting live root layout metrics.
class NeatSurfaceTheme extends StatelessWidget {
  const NeatSurfaceTheme({
    super.key,
    required this.appearance,
    required this.child,
  });

  final NeatlyThemeData appearance;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final root = NeatlyTheme.of(context);
    final theme = appearance.copyWith(
      density: root.density,
      screenClass: root.screenClass,
    );
    // Dialog/sheet routes capture Material Theme at opening. Override only its
    // density so that capture cannot freeze controls or discard local styling.
    return Theme(
      data: Theme.of(context).copyWith(
        visualDensity: root.toMaterialTheme().visualDensity,
      ),
      child: NeatlyTheme(data: theme, child: child),
    );
  }
}
