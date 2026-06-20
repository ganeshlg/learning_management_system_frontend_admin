import 'package:flutter/material.dart';

class ScreenStabilizer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final bool isForm;

  const ScreenStabilizer({
    super.key,
    required this.child,
    this.maxWidth,
    this.isForm = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double effectiveMaxWidth;
        
        if (isForm) {
          effectiveMaxWidth = 1200;
        } else if (constraints.maxWidth > 1600) {
          effectiveMaxWidth = 1600;
        } else if (constraints.maxWidth > 1000) {
          effectiveMaxWidth = 1000;
        } else {
          effectiveMaxWidth = constraints.maxWidth;
        }

        if (maxWidth != null) {
          effectiveMaxWidth = maxWidth!;
        }

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: effectiveMaxWidth,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
