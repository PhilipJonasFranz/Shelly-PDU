import 'package:flutter/material.dart';

/// A widget that displays a loading indicator.
class LoadingWidget extends StatelessWidget {
  /// The size of the loading widget.
  final double size;

  /// The stroke width of the circular progress indicator.
  final double stroke;

  /// The padding around the loading widget, nullable.
  final EdgeInsets? padding;
  final Color? color;

  /// Creates a loading widget.
  ///
  /// The [size] parameter specifies the size of the loading widget. The default value is 40.
  /// The [stroke] parameter specifies the stroke width of the circular progress indicator. The default value is 4.
  /// The [padding] parameter specifies the padding around the loading widget. It is nullable.
  const LoadingWidget(
      {super.key, this.size = 40, this.stroke = 4, this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    /// Create the inner content of the loading widget.
    Widget inner = Center(
        child: SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color ?? Theme.of(context).colorScheme.onSurface,
              strokeWidth: stroke,
            )));

    // Check if padding is provided
    if (padding == null) {
      return inner; // Return the inner content without any additional padding
    } else {
      return Container(
          padding: padding ??
              const EdgeInsets.symmetric(
                  vertical:
                      10), // Apply provided padding or use default vertical padding of 10
          child:
              inner // Return the inner content wrapped inside a container with padding
          );
    }
  }
}
