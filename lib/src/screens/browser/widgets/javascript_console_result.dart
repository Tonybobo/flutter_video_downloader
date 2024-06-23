import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JavascriptConsoleResult extends StatefulWidget {
  final String data;
  final Color textColor;
  final Color backgroundColor;
  final IconData? iconData;
  final Color? iconColor;

  const JavascriptConsoleResult(
      {super.key,
      required this.data,
      required this.textColor,
      required this.backgroundColor,
      this.iconData,
      this.iconColor});

  @override
  State<JavascriptConsoleResult> createState() =>
      _JavascriptConsoleResultState();
}

class _JavascriptConsoleResultState extends State<JavascriptConsoleResult> {
  @override
  Widget build(BuildContext context) {
    var textSpanChildrens = <InlineSpan>[];
    if (widget.iconData != null) {
      textSpanChildrens.add(
        WidgetSpan(
          child: Container(
            padding: const EdgeInsets.only(right: 5.0),
            child: Icon(
              widget.iconData,
              color: widget.iconColor,
              size: 14,
            ),
          ),
          alignment: PlaceholderAlignment.middle,
        ),
      );
    }
    textSpanChildrens.add(
      TextSpan(
        text: widget.data,
        style: TextStyle(color: widget.textColor),
      ),
    );
    return Material(
      color: widget.backgroundColor,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: widget.data));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          color: Colors.transparent,
          child: RichText(
            text: TextSpan(children: textSpanChildrens),
          ),
        ),
      ),
    );
  }
}
