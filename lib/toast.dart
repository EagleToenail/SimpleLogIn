import 'package:flutter/material.dart';

// Enum to define different types of toast messages
enum ToastType { success, error, info, warn }

class Toast {
  // Modify this method to accept a third argument (ToastType), with a default value
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.success,
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 50.0,
            left: 20.0,
            right: 20.0,
            child: ToastBar(message: message, type: type),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class ToastBar extends StatelessWidget {
  final String message;
  final ToastType type;

  const ToastBar({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    IconData icon;
    Color iconColor;

    // Customize colors and icons based on toast type
    switch (type) {
      case ToastType.success:
        backgroundColor = Colors.green;
        icon = Icons.check;
        iconColor = Colors.white;
        break;
      case ToastType.error:
        backgroundColor = Colors.red;
        icon = Icons.error_outline;
        iconColor = Colors.white;
        break;
      case ToastType.info:
        backgroundColor = Colors.lightBlueAccent;
        icon = Icons.info_outline;
        iconColor = Colors.white;
        break;
      case ToastType.warn:
        backgroundColor = Colors.orange;
        icon = Icons.warning_amber_outlined;
        iconColor = Colors.white;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 12.0),
            Flexible(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
