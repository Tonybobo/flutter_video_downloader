import 'package:flutter/material.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/find_on_page_app_bar.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/webview_tab_app_bar.dart';

class BrowserAppBar extends StatefulWidget implements PreferredSizeWidget {
  const BrowserAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<BrowserAppBar> createState() => _BrowserAppBarState();

  @override
  final Size preferredSize;
}

class _BrowserAppBarState extends State<BrowserAppBar> {
  bool _isFindingOnPage = false;

  @override
  Widget build(BuildContext context) {
    return _isFindingOnPage
        ? FindOnPageAppBar(
            hideFindOnPage: () {
              setState(() {
                _isFindingOnPage = false;
              });
            },
          )
        : WebviewTabAppBar(
            showFindOnPage: () {
              setState(() {
                _isFindingOnPage = true;
              });
            },
          );
  }
}
