import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/custom_popup_menu_item.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/tab_popup_menu_actions.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';
import 'package:video_downloader/src/screens/settings/main.dart';

class TabViewerAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TabViewerAppBar({super.key})
      : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  State<TabViewerAppBar> createState() => _TabViewerAppBar();

  @override
  final Size preferredSize;
}

class _TabViewerAppBar extends State<TabViewerAppBar> {
  GlobalKey tabInkWellKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 10.0,
      leading: _buildAddTabButton(),
      actions: _buildActionsMenu(),
    );
  }

  Widget _buildAddTabButton() {
    return IconButton(
        onPressed: () => addNewOrIncognitoTab(), icon: const Icon(Icons.add));
  }

  addNewOrIncognitoTab({WebUri? url, bool? incognito}) {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);

    var settings = browserProvider.getSettings();

    url ??= settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
        ? WebUri(settings.customUrlHomePage)
        : WebUri(settings.searchEngine.url);

    browserProvider.showTabScroller = false;
    browserProvider.addTab(WebViewTab(
      key: GlobalKey(),
      webViewProvider:
          WebViewProvider(url: url, isIncognitoMode: incognito ?? false),
    ));
  }

  List<Widget> _buildActionsMenu() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();

    return <Widget>[
      InkWell(
        key: tabInkWellKey,
        onTap: () {
          if (browserProvider.webViewTabs.isNotEmpty) {
            browserProvider.showTabScroller = !browserProvider.showTabScroller;
          } else {
            browserProvider.showTabScroller = false;
          }
        },
        child: Padding(
          padding: settings.homePageEnabled
              ? const EdgeInsets.only(
                  left: 20.0, top: 15.0, right: 10.0, bottom: 15.0)
              : const EdgeInsets.only(
                  left: 10.0, top: 15.0, right: 10.0, bottom: 15.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: Colors.white),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(5.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Center(
              child: Text(
                browserProvider.webViewTabs.length.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
      ),
      PopupMenuButton<String>(
        onSelected: _popupMenuChoiceAction,
        itemBuilder: (context) {
          var items = <PopupMenuEntry<String>>[];
          items.addAll(
            TabPopupMenuActions.choices
                .where((element) => element != TabPopupMenuActions.CLOSE_TABS)
                .toList()
                .map(
              (choice) {
                switch (choice) {
                  case TabPopupMenuActions.NEW_TAB:
                    return CustomPopupMenuItem<String>(
                      enabled: true,
                      value: choice,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Text(choice), const Icon(Icons.add)],
                      ),
                    );
                  case TabPopupMenuActions.NEW_INCOGNITO_TAB:
                    return CustomPopupMenuItem<String>(
                      enabled: true,
                      value: choice,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(choice),
                          const Icon(MaterialCommunityIcons.incognito)
                        ],
                      ),
                    );
                  case TabPopupMenuActions.CLOSE_ALL_TABS:
                    return CustomPopupMenuItem<String>(
                      enabled: browserProvider.webViewTabs.isNotEmpty,
                      value: choice,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(choice),
                          const Icon(Icons.close),
                        ],
                      ),
                    );
                  case TabPopupMenuActions.SETTINGS:
                    return CustomPopupMenuItem<String>(
                      enabled: browserProvider.webViewTabs.isNotEmpty,
                      value: choice,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(choice),
                          const Icon(Icons.settings),
                        ],
                      ),
                    );
                  default:
                    return CustomPopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                }
              },
            ).toList(),
          );
          return items;
        },
      )
    ];
  }

  void _popupMenuChoiceAction(String choice) async {
    switch (choice) {
      case TabPopupMenuActions.NEW_TAB:
        Future.delayed(
            const Duration(milliseconds: 300), () => addNewOrIncognitoTab());
        break;
      case TabPopupMenuActions.NEW_INCOGNITO_TAB:
        Future.delayed(const Duration(milliseconds: 300),
            () => addNewOrIncognitoTab(incognito: true));
        break;
      case TabPopupMenuActions.CLOSE_ALL_TABS:
        Future.delayed(const Duration(milliseconds: 300), () => closeAllTab());
        break;
      case TabPopupMenuActions.SETTINGS:
        Future.delayed(
            const Duration(milliseconds: 300), () => goToSettingsPage());
        break;
    }
  }

  void closeAllTab() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);

    browserProvider.showTabScroller = false;
    browserProvider.closeAllTabs();
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }
}
