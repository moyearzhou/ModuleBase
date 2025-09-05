import 'package:flutter/material.dart';

final class SizedLoading extends StatelessWidget {
  final double size;

  const SizedLoading({
    super.key,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static const small = SizedLoading(size: 20);
  static const medium = SizedLoading(size: 50);
  static const large = SizedLoading(size: 70);
}
