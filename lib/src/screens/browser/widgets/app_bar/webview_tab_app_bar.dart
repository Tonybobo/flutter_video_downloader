import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/main.dart';
import 'package:video_downloader/src/models/favourite.dart';
import 'package:video_downloader/src/models/web_archive.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/animated_flutter_browser_logo.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/custom_popup_dialog.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/custom_popup_menu_item.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/popup_menu_actions.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/tab_popup_menu_actions.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/url_info_popup.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';
import 'package:video_downloader/src/utils/util.dart';

class WebviewTabAppBar extends StatefulWidget {
  final Function()? showFindOnPage;
  const WebviewTabAppBar({super.key, this.showFindOnPage});

  @override
  State<WebviewTabAppBar> createState() => _WebviewTabAppBarState();
}

class _WebviewTabAppBarState extends State<WebviewTabAppBar>
    with SingleTickerProviderStateMixin {
  TextEditingController? _searchController = TextEditingController();
  FocusNode? _focusNode;

  GlobalKey tabInkWellKey = GlobalKey();

  Duration customPopupDialogTransitionDuration =
      const Duration(milliseconds: 300);

  CustomPopupDialogPageRoute? route;

  OutlineInputBorder outlineBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    borderRadius: BorderRadius.all(Radius.circular(50.0)),
  );

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode?.addListener(() async {
      if (_focusNode != null &&
          !_focusNode!.hasFocus &&
          _searchController != null &&
          _searchController!.text.isEmpty) {
        var browserProvider =
            Provider.of<BrowserProvider>(context, listen: true);
        var webViewProvider = browserProvider.getCurrentTab()?.webViewProvider;
        var webViewController = webViewProvider?.webViewController;
        _searchController!.text =
            (await webViewController?.getUrl())?.toString() ?? "";
      }
    });
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _focusNode = null;
    _searchController?.dispose();
    _searchController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<WebViewProvider, WebUri?>(
      selector: (context, webViewProvider) => webViewProvider.url,
      builder: (context, url, child) {
        if (url == null) _searchController?.text = "";
        if (url != null && _focusNode != null && !_focusNode!.hasFocus) {
          _searchController?.text = url.toString();
        }

        Widget? leading = _buildAppBarHomePageWidget();

        return Selector<WebViewProvider, bool>(
          selector: (context, webViewProvider) =>
              webViewProvider.isIncognitoMode,
          builder: (context, isIncognitoMode, child) {
            return leading != null
                ? AppBar(
                    backgroundColor:
                        isIncognitoMode ? Colors.black87 : Colors.blue,
                    leading: leading,
                    titleSpacing: 0.0,
                    title: _buildSearchTextField(),
                    actions: _buildActionsMenu(),
                  )
                : AppBar(
                    backgroundColor:
                        isIncognitoMode ? Colors.black87 : Colors.blue,
                    titleSpacing: 0.0,
                    title: _buildSearchTextField(),
                    actions: _buildActionsMenu(),
                  );
          },
        );
      },
    );
  }

  Widget? _buildAppBarHomePageWidget() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();

    var webViewProvider = browserProvider.getCurrentTab()?.webViewProvider;
    var webViewController = webViewProvider?.webViewController;

    if (!settings.homePageEnabled) {
      return null;
    }

    return IconButton(
      onPressed: () {
        if (webViewController != null) {
          var url =
              settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
                  ? WebUri(settings.customUrlHomePage)
                  : WebUri(settings.searchEngine.url);
          webViewController.loadUrl(urlRequest: URLRequest(url: url));
        } else {
          addNewTab();
        }
      },
      icon: const Icon(Icons.home),
    );
  }

  Widget _buildSearchTextField() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();

    var webViewProvider = Provider.of<WebViewProvider>(context, listen: true);
    var webViewController = webViewProvider.webViewController;

    return SizedBox(
      height: 40.0,
      child: Stack(
        children: [
          TextField(
            onSubmitted: (value) {
              var url = WebUri(value.trim());
              if (!url.scheme.startsWith("http") &&
                  !Util.isLocalizedContent(url)) {
                url = WebUri(settings.searchEngine.searchUrl + value);
              }

              if (webViewController != null) {
                webViewController.loadUrl(urlRequest: URLRequest(url: url));
              } else {
                addNewTab(url: url);
                webViewProvider.url = url;
              }
            },
            keyboardType: TextInputType.url,
            focusNode: _focusNode,
            autofocus: false,
            controller: _searchController,
            textInputAction: TextInputAction.go,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                left: 45.0,
                top: 10.0,
                right: 10.0,
                bottom: 10.0,
              ),
              filled: true,
              fillColor: Colors.white,
              border: outlineBorder,
              focusedBorder: outlineBorder,
              enabledBorder: outlineBorder,
              hintText: "Search or type a URL",
              hintStyle: const TextStyle(
                color: Colors.black,
                fontSize: 16.0,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              showUrlInfo();
            },
            icon: Selector<WebViewProvider, bool>(
              selector: (context, webViewProvider) => webViewProvider.isSSL,
              builder: (context, isSSL, child) {
                var icon = Icons.info_outline;
                if (webViewProvider.isIncognitoMode) {
                  icon = MaterialCommunityIcons.incognito;
                } else if (isSSL) {
                  if (webViewProvider.url != null &&
                      webViewProvider.url!.scheme == "file") {
                    icon = Icons.offline_pin;
                  } else {
                    icon = Icons.lock;
                  }
                }
                return Icon(
                  icon,
                  color: isSSL ? Colors.green : Colors.grey,
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void addNewTab({WebUri? url, bool? incognitoMode}) {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    var settings = browserProvider.getSettings();

    url ??= settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
        ? WebUri(settings.customUrlHomePage)
        : WebUri(settings.searchEngine.url);

    browserProvider.addTab(WebViewTab(
      key: GlobalKey(),
      webViewProvider:
          WebViewProvider(url: url, isIncognitoMode: incognitoMode ?? false),
    ));
  }

  List<Widget> _buildActionsMenu() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();

    return <Widget>[
      settings.homePageEnabled
          ? const SizedBox(
              width: 10.0,
            )
          : Container(),
      InkWell(
        key: tabInkWellKey,
        onLongPress: () {
          final RenderBox? box =
              tabInkWellKey.currentContext!.findRenderObject() as RenderBox?;
          if (box == null) return;

          Offset position = box.localToGlobal(Offset.zero);

          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + box.size.height,
              box.size.width,
              0,
            ),
            items: TabPopupMenuActions.choices.map((action) {
              IconData? iconData;
              switch (action) {
                case TabPopupMenuActions.CLOSE_TABS:
                  iconData = Icons.cancel;
                  break;
                case TabPopupMenuActions.NEW_TAB:
                  iconData = Icons.add;
                  break;
                case TabPopupMenuActions.NEW_INCOGNITO_TAB:
                  iconData = MaterialCommunityIcons.incognito;
                  break;
              }

              return PopupMenuItem<String>(
                value: action,
                child: Row(
                  children: [
                    Icon(
                      iconData,
                      color: Colors.black,
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(action),
                    )
                  ],
                ),
              );
            }).toList(),
          ).then((value) {
            switch (value) {
              case TabPopupMenuActions.CLOSE_TABS:
                browserProvider.closeAllTabs();
                break;
              case TabPopupMenuActions.NEW_TAB:
                addNewTab();
                break;
              case TabPopupMenuActions.NEW_INCOGNITO_TAB:
                addNewTab(incognitoMode: true);
                break;
            }
          });
        },
        onTap: () async {
          if (browserProvider.webViewTabs.isNotEmpty) {
            var webViewProvider =
                browserProvider.getCurrentTab()?.webViewProvider;
            var webViewController = webViewProvider?.webViewController;

            if (View.of(context).viewInsets.bottom > 0.0) {
              SystemChannels.textInput.invokeMethod("TextInput.hide");
              if (FocusManager.instance.primaryFocus != null) {
                FocusManager.instance.primaryFocus!.unfocus();
              }

              if (webViewController != null) {
                await webViewController.evaluateJavascript(
                    source: "document.activeElement.blur();");
              }

              await Future.delayed(const Duration(milliseconds: 300));
            }

            if (webViewProvider != null && webViewController != null) {
              webViewProvider.screenshot = await webViewController
                  .takeScreenshot(
                      screenshotConfiguration: ScreenshotConfiguration(
                          compressFormat: CompressFormat.JPEG, quality: 20))
                  .timeout(const Duration(milliseconds: 1500),
                      onTimeout: () => null);
            }

            browserProvider.showTabScroller = true;
          }
        },
        child: Container(
          margin: const EdgeInsets.only(
              left: 10.0, top: 15.0, right: 10.0, bottom: 15.0),
          decoration: BoxDecoration(
            border: Border.all(width: 2.0, color: Colors.white),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(5.0),
          ),
          constraints: const BoxConstraints(minWidth: 25.0),
          child: Center(
            child: Text(
              browserProvider.webViewTabs.length.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
      ),
      PopupMenuButton<String>(
        onSelected: _popupMenuChoiceAction,
        itemBuilder: (context) {
          var items = [
            CustomPopupMenuItem<String>(
              enabled: true,
              isIconButtonRow: true,
              child: StatefulBuilder(
                builder: (statefulContext, setState) {
                  var browserProvider = Provider.of<BrowserProvider>(
                      statefulContext,
                      listen: true);
                  var webViewProvider = Provider.of<WebViewProvider>(
                      statefulContext,
                      listen: true);

                  var webViewController = webViewProvider.webViewController;

                  var isFavourite = false;
                  FavouriteModel? favourite;

                  if (webViewProvider.url != null &&
                      webViewProvider.url.toString().isNotEmpty) {
                    favourite = FavouriteModel(
                        url: webViewProvider.url,
                        title: webViewProvider.title ?? "",
                        favicon: webViewProvider.favicon);
                    isFavourite = browserProvider.containsFavourite(favourite);
                  }

                  var children = <Widget>[];

                  if (Util.isIOS()) {
                    children.add(SizedBox(
                      width: 35.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          webViewController?.goBack();
                          Navigator.pop(statefulContext);
                        },
                      ),
                    ));
                  }

                  children.addAll([
                    SizedBox(
                      width: 35.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          webViewController?.goForward();
                          Navigator.pop(statefulContext);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 35.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: Icon(
                          isFavourite ? Icons.star : Icons.star_outline,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            if (favourite != null) {
                              isFavourite
                                  ? browserProvider.removeFavourite(favourite)
                                  : browserProvider.addFavourite(favourite);
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 35.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: const Icon(
                          Icons.file_download,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          Navigator.pop(statefulContext);
                          if (webViewProvider.url != null &&
                              webViewProvider.url!.scheme.startsWith("http")) {
                            var url = webViewProvider.url;
                            if (url == null) return;

                            String webArchivePath =
                                "$WEB_ARCHIVE_DIR${Platform.pathSeparator}${url.scheme}-${url.host}${url.path.replaceAll("/", "-")}${DateTime.now().microsecondsSinceEpoch}.${Util.isAndroid() ? WebArchiveFormat.MHT.toValue() : WebArchiveFormat.WEBARCHIVE.toValue()}";

                            String? savedPath =
                                (await webViewController?.saveWebArchive(
                                    filePath: webArchivePath, autoname: false));

                            var webArchiveModel = WebArchive(
                                timestamp: DateTime.now(),
                                url: url,
                                path: savedPath,
                                title: webViewProvider.title,
                                favicon: webViewProvider.favicon);

                            if (savedPath != null) {
                              browserProvider.addWebArchive(
                                  url.toString(), webArchiveModel);
                              if (statefulContext.mounted) {
                                ScaffoldMessenger.of(statefulContext)
                                    .showSnackBar(SnackBar(
                                        content: Text(
                                            "${webViewProvider.url} saved offline!")));
                              }
                              await browserProvider.save();
                            } else {
                              if (statefulContext.mounted) {
                                ScaffoldMessenger.of(statefulContext)
                                    .showSnackBar(const SnackBar(
                                        content: Text("Unable to save!")));
                              }
                            }
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 35.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon:
                            const Icon(Icons.info_outline, color: Colors.black),
                        onPressed: () async {
                          Navigator.pop(statefulContext);

                          await route?.completed;
                          showUrlInfo();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 35.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: const Icon(
                            MaterialCommunityIcons.cellphone_screenshot,
                            color: Colors.black),
                        onPressed: () async {
                          Navigator.pop(statefulContext);

                          await route?.completed;

                          takeScreenshotAndShow();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 35.0,
                      child: IconButton(
                        padding: const EdgeInsets.all(0.0),
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        onPressed: () async {
                          Navigator.pop(statefulContext);
                          await webViewController?.reload();
                        },
                      ),
                    ),
                  ]);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisSize: MainAxisSize.max,
                    children: children,
                  );
                },
              ),
            ),
          ];

          items.addAll(PopupMenuActions.choices.map((choice) {
            switch (choice) {
              case PopupMenuActions.NEW_TAB:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.add,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.NEW_INCOGNITO_TAB:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        MaterialCommunityIcons.incognito,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.FAVOURITES:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.star,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.HISTORY:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.history,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.WEB_ARCHIVES:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.offline_pin,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.SHARE:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.share,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.SETTINGS:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.settings,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.DEVELOPERS:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.code,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.FIND_ON_PAGE:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.find_in_page,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.DESKTOP_MODE:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      const Icon(
                        Icons.desktop_windows,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              case PopupMenuActions.INAPPWEBVIEW_PROJECT:
                return CustomPopupMenuItem(
                  enabled: true,
                  value: choice,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(choice),
                      Container(
                        padding: const EdgeInsets.only(right: 6),
                        child: const AnimatedFlutterBrowserLogo(
                          size: 12.5,
                        ),
                      )
                    ],
                  ),
                );
              default:
                return CustomPopupMenuItem(
                  value: choice,
                  child: Text(choice),
                );
            }
          }));

          return items;
        },
      )
    ];
  }

  void showUrlInfo() {
    var webViewProvider = Provider.of<WebViewProvider>(context, listen: false);
    var url = webViewProvider.url;

    if (url == null || url.toString().isEmpty) return;

    route = CustomPopupDialog.show(
      context: context,
      transitionDuration: customPopupDialogTransitionDuration,
      builder: (context) {
        return UrlInfoPopup(
            route: route!,
            transitionDuration: customPopupDialogTransitionDuration);
      },
    );
  }

  Future<void> takeScreenshotAndShow() async {}

  void _popupMenuChoiceAction(String value) {}
}
