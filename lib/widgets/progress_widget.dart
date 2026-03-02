import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final double progress; 
  final Color? color;

  const ProgressWidget({super.key, required this.progress, this.color});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: progress.clamp(0.0, 1.0),
      backgroundColor: Colors.grey[300],
      valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
    );
  }
}