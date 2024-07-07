import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/custom_popup_dialog.dart';

class UrlInfoPopup extends StatefulWidget {
  const UrlInfoPopup(
      {super.key,
      required this.route,
      required this.transitionDuration,
      this.onWebViewTabSettingsClicked});

  final CustomPopupDialogPageRoute route;
  final Duration transitionDuration;
  final Function()? onWebViewTabSettingsClicked;

  @override
  State<UrlInfoPopup> createState() => _UrlInfoPopupState();
}

class _UrlInfoPopupState extends State<UrlInfoPopup> {
  var text1 = "Your connection to this website is not protected";
  var text2 =
      "You should not enter sensitive data on this site (e.g. passwords or credit cards)";

  var showFullInfoUrl = false;
  var defaultTextSpanStyle =
      const TextStyle(color: Colors.black54, fontSize: 12.5);

  @override
  Widget build(BuildContext context) {
    var webViewProvider = Provider.of<WebViewProvider>(context, listen: true);
    if (webViewProvider.isSSL) {
      text1 = "Your connection is protected";
      text2 =
          "Your sensitive data (e.g. passwords or credit card numbers) remains private when it is sent to this site.";
    }
    var url = webViewProvider.url;
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatefulBuilder(
            builder: (context, setState) {
              return GestureDetector(
                onTap: () {
                  setState(() => showFullInfoUrl = !showFullInfoUrl);
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  constraints: const BoxConstraints(maxHeight: 100.0),
                  child: RichText(
                    maxLines: showFullInfoUrl ? null : 2,
                    overflow: showFullInfoUrl
                        ? TextOverflow.clip
                        : TextOverflow.ellipsis,
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: url?.scheme,
                            style: defaultTextSpanStyle.copyWith(
                              color: webViewProvider.isSSL
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            )),
                        TextSpan(
                          text: url?.toString() == "about:blank" ? ":" : "://",
                          style: defaultTextSpanStyle,
                        ),
                        TextSpan(
                          text: url?.host,
                          style: defaultTextSpanStyle.copyWith(
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: url?.path,
                          style: defaultTextSpanStyle,
                        ),
                        TextSpan(
                          text: url?.query,
                          style: defaultTextSpanStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Text(
              text1,
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
          RichText(
            text: TextSpan(
                style: const TextStyle(fontSize: 12.0, color: Colors.black87),
                children: [
                  TextSpan(text: "$text2 "),
                  TextSpan(
                      text: "Details",
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          Navigator.maybePop(context);

                          await widget.route.popped;

                          await Future.delayed(Duration(
                              milliseconds:
                                  widget.transitionDuration.inMilliseconds -
                                      200));

                          //# TODO: Add dialog page

                          showDialog(
                            context: context,
                            builder: (context) {
                              return const Placeholder();
                            },
                          );
                        }),
                ]),
          ),
          const SizedBox(height: 30.0),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              child: const Text("WebView Tab Settings"),
              onPressed: () async {
                Navigator.maybePop(context);
                await widget.route.popped;
                Future.delayed(widget.transitionDuration, () {
                  if (widget.onWebViewTabSettingsClicked != null) {
                    widget.onWebViewTabSettingsClicked!();
                  }
                });
              },
            ),
          )
        ],
      ),
    );
  }
}
