import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_extend/share_extend.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/src/models/favourite.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/custom_popup_dialog.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/custom_popup_menu_item.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/popup_menu_actions.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/tab_popup_menu_actions.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/url_info_popup.dart';
import 'package:video_downloader/src/screens/browser/widgets/custom_image.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';
import 'package:video_downloader/src/screens/settings/main.dart';
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

        return Selector<WebViewProvider,
            ({double progress, bool isIncognitoMode})>(
          selector: (context, webViewProvider) => (
            progress: webViewProvider.progress,
            isIncognitoMode: webViewProvider.isIncognitoMode
          ),
          builder: (context, data, child) {
            return leading != null
                ? AppBar(
                    leading: leading,
                    titleSpacing: 0.0,
                    title: _buildSearchTextField(),
                    actions: _buildActionsMenu(),
                    bottom: PreferredSize(
                      preferredSize: const Size(double.infinity, 1.5),
                      child: SizedBox(
                        height: 1.5,
                        child: LinearProgressIndicator(
                          value: data.progress >= 1.0 ? 0.0 : data.progress,
                        ),
                      ),
                    ),
                  )
                : AppBar(
                    titleSpacing: 0.0,
                    title: _buildSearchTextField(),
                    actions: _buildActionsMenu(),
                    bottom: PreferredSize(
                      preferredSize: const Size(double.infinity, 1.5),
                      child: SizedBox(
                        height: 1.5,
                        child: LinearProgressIndicator(
                          value: data.progress >= 1.0 ? 0.0 : data.progress,
                        ),
                      ),
                    ),
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
              fillColor: Colors.grey[600],
              contentPadding: const EdgeInsets.only(
                top: 10.0,
                left: 45.0,
                right: 10.0,
                bottom: 10.0,
              ),
              border: outlineBorder,
              focusedBorder: outlineBorder,
              enabledBorder: outlineBorder,
              hintText: "Search or Type a URL",
              hintStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.1),
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
                var brightness = MediaQuery.of(context).platformBrightness;
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
                  color: isSSL
                      ? Colors.green
                      : brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                );
              },
            ),
          )
        ],
      ),
    );
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
                        padding: const EdgeInsets.only(bottom: 5.0),
                        icon: const Icon(
                          Icons.arrow_forward,
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
                        padding: const EdgeInsets.only(bottom: 5.0),
                        icon: Icon(
                          isFavourite ? Icons.star : Icons.star_outline,
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
                        padding: const EdgeInsets.only(bottom: 5.0),
                        icon: const Icon(Icons.info_outline),
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
                        padding: const EdgeInsets.only(bottom: 5.0),
                        icon: const Icon(
                          MaterialCommunityIcons.cellphone_screenshot,
                        ),
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
                        padding: const EdgeInsets.only(bottom: 5.0),
                        icon: const Icon(Icons.refresh),
                        onPressed: () async {
                          Navigator.pop(statefulContext);
                          await webViewController?.reload();
                        },
                      ),
                    ),
                  ]);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          transitionDuration: customPopupDialogTransitionDuration,
          onWebViewTabSettingsClicked: () => goToSettingsPage(),
        );
      },
    );
  }

  void goToSettingsPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  Future<void> takeScreenshotAndShow() async {
    var webViewProvider = Provider.of<WebViewProvider>(context, listen: false);
    var screenshot = await webViewProvider.webViewController?.takeScreenshot();

    if (screenshot != null) {
      var dir = await getApplicationCacheDirectory();
      File file = File(
          "${dir.path}/screenshot_${DateTime.now().microsecondsSinceEpoch}.png");
      await file.writeAsBytes(screenshot);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Image.memory(screenshot),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    await ShareExtend.share(file.path, "image");
                  },
                  child: const Text("Share"),
                )
              ],
            );
          },
        );
      }

      file.delete();
    }
  }

  void _popupMenuChoiceAction(String value) async {
    var currentWebViewProvider =
        Provider.of<WebViewProvider>(context, listen: false);

    switch (value) {
      case PopupMenuActions.NEW_TAB:
        addNewTab();
        break;
      case PopupMenuActions.NEW_INCOGNITO_TAB:
        addNewTab(incognitoMode: true);
        break;
      case PopupMenuActions.FAVOURITES:
        showFavourite();
        break;
      case PopupMenuActions.HISTORY:
        showHistory();
        break;
      case PopupMenuActions.FIND_ON_PAGE:
        var isFindInteractionEnabled =
            currentWebViewProvider.settings?.isFindInteractionEnabled ?? false;
        var findInteractionController =
            currentWebViewProvider.findInteractionController;
        if (Util.isIOS() &&
            isFindInteractionEnabled &&
            findInteractionController != null) {
          await findInteractionController.presentFindNavigator();
        } else if (widget.showFindOnPage != null) {
          widget.showFindOnPage!();
        }
        break;
      case PopupMenuActions.SHARE:
        share();
        break;
      case PopupMenuActions.DESKTOP_MODE:
        toggleDesktopMode();
        break;
      case PopupMenuActions.SETTINGS:
        Future.delayed(
            const Duration(milliseconds: 300), () => goToSettingsPage());
        break;
    }
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

  void showFavourite() {
    showDialog(
      context: context,
      builder: (context) {
        var browserProvider =
            Provider.of<BrowserProvider>(context, listen: true);

        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
                children: browserProvider.favourites.map((favourite) {
              var url = favourite.url;
              var faviconUrl = favourite.favicon != null
                  ? favourite.favicon!.url
                  : WebUri("${url?.origin ?? ""}/favicon.ico");

              return ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImage(
                      url: faviconUrl,
                      maxWidth: 30.0,
                      height: 30.0,
                    )
                  ],
                ),
                title: Text(
                  favourite.title ?? favourite.url?.toString() ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  favourite.url?.toString() ?? "",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: true,
                onTap: () {
                  setState(() {
                    addNewTab(url: favourite.url);
                    Navigator.pop(context);
                  });
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          browserProvider.removeFavourite(favourite);
                          if (browserProvider.favourites.isEmpty) {
                            Navigator.pop(context);
                          }
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        size: 20.0,
                      ),
                    )
                  ],
                ),
              );
            }).toList()),
          ),
        );
      },
    );
  }

  void showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        var webViewProvider =
            Provider.of<WebViewProvider>(context, listen: false);

        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          content: FutureBuilder(
            future: webViewProvider.webViewController?.getCopyBackForwardList(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }

              WebHistory history = snapshot.data as WebHistory;
              return SizedBox(
                width: double.maxFinite,
                child: ListView(
                  children: history.list?.reversed.map((item) {
                        var url = item.url;

                        return ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomImage(
                                url: WebUri("${url?.origin ?? ""}/favicon.ico"),
                                maxWidth: 30.0,
                                height: 30.0,
                              )
                            ],
                          ),
                          title: Text(
                            item.title ?? url.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            url?.toString() ?? "",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          onTap: () {
                            webViewProvider.webViewController?.loadUrl(
                                urlRequest: URLRequest(url: item.url));
                            Navigator.pop(context);
                          },
                        );
                      }).toList() ??
                      [],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void share() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    var currentWebViewProvider =
        browserProvider.getCurrentTab()?.webViewProvider;
    var url = currentWebViewProvider?.url;
    if (url != null) {
      Share.share(url.toString(), subject: currentWebViewProvider?.title);
    }
  }

  void toggleDesktopMode() async {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    var webViewProvider = browserProvider.getCurrentTab()?.webViewProvider;
    var webViewController = webViewProvider?.webViewController;
    var currentWebViewProvider =
        Provider.of<WebViewProvider>(context, listen: false);

    if (webViewController != null) {
      webViewProvider?.isDesktopMode = !webViewProvider.isDesktopMode;
      currentWebViewProvider.isDesktopMode =
          webViewProvider?.isDesktopMode ?? false;

      var currentSettings = await webViewController.getSettings();

      if (currentSettings != null) {
        currentSettings.preferredContentMode =
            webViewProvider?.isDesktopMode ?? false
                ? UserPreferredContentMode.DESKTOP
                : UserPreferredContentMode.RECOMMENDED;
        await webViewController.setSettings(settings: currentSettings);
      }
      await webViewController.reload();
    }
  }
}
