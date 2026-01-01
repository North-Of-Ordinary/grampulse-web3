import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double? size;
  final Color? color;
  
  const LoadingIndicator({
    super.key, 
    this.size, 
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 32.0,
        height: size ?? 32.0,
        child: CircularProgressIndicator(
          strokeWidth: 3.0,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
