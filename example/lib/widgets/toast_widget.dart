import 'package:flutter/material.dart';

OverlayEntry _overlayEntry;

class Toast {
  static Toast of(BuildContext context) {
    return Toast._(context);
  }

  void show(String message, {Duration duration}) {
    _showWidget(Builder(
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: 300, maxWidth: 300),
          decoration: BoxDecoration(
            color: Color.fromRGBO(12, 12, 12, 0.9),
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 7,
            bottom: 7,
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w300,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        );
      },
    ), duration);
  }

  void showCustom(Widget widget, {Duration duration}) {
    _showWidget(Builder(
      builder: (context) {
        return widget;
      },
    ), duration);
  }

  hidden() {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  _showWidget(
    Widget widget,
    Duration duration,
  ) {
    if (_overlayEntry != null) {
      _overlayEntry.remove();
      _overlayEntry = null;
    }
    OverlayState overlayState = Overlay.of(context);
    _overlayEntry = OverlayEntry(builder: (context) {
      return Center(
        child: widget,
      );
    });
    overlayState.insert(_overlayEntry);

    if (duration != null) {
      Future.delayed(duration).then((_) {
        if (_overlayEntry != null) {
          _overlayEntry.remove();
          _overlayEntry = null;
        }
      });
    }
  }

  final BuildContext context;
  Toast._(this.context);
}
