import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/constants/search_engine.dart';
import 'package:video_downloader/src/models/browser_setting.dart';
import 'package:video_downloader/src/models/search_engine.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/app_bar/custom_popup_menu_item.dart';

class PopupSettingsMenuActions {
  // ignore: constant_identifier_names
  static const String RESET_BROWSER_SETTINGS = "Reset Browser Settings";
  // ignore: constant_identifier_names
  static const String RESET_WEBVIEW_SETTINGS = "Reset WebView Settings";

  static const List<String> choices = [
    RESET_BROWSER_SETTINGS,
    RESET_WEBVIEW_SETTINGS
  ];
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _customHomepageController =
      TextEditingController();

  @override
  void dispose() {
    _customHomepageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSettingsAppBar(),
      body: _buildSettingsBody(),
    );
  }

  PreferredSizeWidget _buildSettingsAppBar() {
    return AppBar(
      title: const Text("Settings"),
      actions: [
        PopupMenuButton<String>(
          onSelected: _popupMenuChoiceAction,
          itemBuilder: (context) {
            var items = const [
              CustomPopupMenuItem<String>(
                enabled: true,
                value: PopupSettingsMenuActions.RESET_BROWSER_SETTINGS,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(PopupSettingsMenuActions.RESET_BROWSER_SETTINGS),
                    Icon(
                      Foundation.web,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
              CustomPopupMenuItem<String>(
                enabled: true,
                value: PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS),
                    Icon(
                      MaterialIcons.web,
                      color: Colors.black,
                    )
                  ],
                ),
              ),
            ];

            return items;
          },
        )
      ],
    );
  }

  void _popupMenuChoiceAction(String value) async {
    switch (value) {
      case PopupSettingsMenuActions.RESET_BROWSER_SETTINGS:
        var browserProvider =
            Provider.of<BrowserProvider>(context, listen: false);
        browserProvider.updateSettings(BrowserSettings());
        browserProvider.save();
        break;
      case PopupSettingsMenuActions.RESET_WEBVIEW_SETTINGS:
        var browserProvider =
            Provider.of<BrowserProvider>(context, listen: false);
        var currentWebViewProvider =
            Provider.of<WebViewProvider>(context, listen: false);
        var webViewController = currentWebViewProvider.webViewController;
        await webViewController?.setSettings(
            settings: InAppWebViewSettings(
          incognito: currentWebViewProvider.isIncognitoMode,
          useOnDownloadStart: true,
          useOnLoadResource: true,
          safeBrowsingEnabled: true,
          allowsLinkPreview: false,
          isFraudulentWebsiteWarningEnabled: true,
        ));
        currentWebViewProvider.settings =
            await webViewController?.getSettings();
        browserProvider.save();
        break;
    }
  }

  _buildSettingsBody() {
    return ListView(
        children: [..._buildBaseSettings(), ..._buildSettingsListFields()]);
  }

  List<Widget> _buildBaseSettings() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    var settings = browserProvider.getSettings();

    var widget = <Widget>[
      const ListTile(
        title: Text("General Settings"),
        enabled: false,
      ),
      ListTile(
        title: const Text("Search Engine"),
        subtitle: Text(settings.searchEngine.name),
        trailing: DropdownButton<SearchEngine>(
          hint: const Text("Search Engine"),
          onChanged: (value) {
            if (value != null) {
              settings.searchEngine = value;
              browserProvider.updateSettings(settings);
            }
          },
          value: settings.searchEngine,
          items: SearchEngines.map((searchEngine) {
            return DropdownMenuItem(
              value: searchEngine,
              child: Text(searchEngine.name),
            );
          }).toList(),
        ),
      ),
      const ListTile(title: Text("Custom Homepage Url")),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
            width: double.maxFinite,
            height: 40.0,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: TextField(
                controller: _customHomepageController,
                decoration: InputDecoration(
                    hintText: settings.customUrlHomePage,
                    suffixIcon: IconButton(
                      onPressed: () {
                        settings.customUrlHomePage =
                            _customHomepageController.text;
                        browserProvider.updateSettings(settings);
                      },
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(
                          size: 20.0,
                          MaterialCommunityIcons.content_save_all_outline),
                    )),
              ),
            )),
      )
    ];

    return widget;
  }

  List<Widget> _buildSettingsListFields() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    if (browserProvider.webViewTabs.isEmpty) {
      return [];
    }
    var currentWebViewProvider =
        Provider.of<WebViewProvider>(context, listen: true);
    var webViewController = currentWebViewProvider.webViewController;

    var widgets = <Widget>[
      ListTile(
        title: const Text("Text Zoom"),
        subtitle: const Text("Sets the text zoom of the page in percent"),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue: currentWebViewProvider.settings?.textZoom.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewProvider.settings?.textZoom = int.parse(value);
              webViewController?.setSettings(
                  settings: currentWebViewProvider.settings ??
                      InAppWebViewSettings());
              currentWebViewProvider.settings =
                  await webViewController?.getSettings();
              browserProvider.save();
            },
          ),
        ),
      ),
      ListTile(
        title: const Text("Clear Cache"),
        onTap: () async {
          await webViewController?.platform.clearAllCache();
        },
      ),
      SwitchListTile(
        title: const Text("Built In Zoom Controls"),
        value: currentWebViewProvider.settings?.builtInZoomControls ?? false,
        onChanged: (value) async {
          currentWebViewProvider.settings?.builtInZoomControls = value;
          webViewController?.setSettings(
              settings:
                  currentWebViewProvider.settings ?? InAppWebViewSettings());
          currentWebViewProvider.settings =
              await webViewController?.getSettings();
          log("Log zoom control ${currentWebViewProvider.settings?.builtInZoomControls}");
          browserProvider.save();
        },
      ),
      SwitchListTile(
        title: const Text("Display Zoom Controls"),
        value: currentWebViewProvider.settings?.displayZoomControls ?? false,
        onChanged: (value) async {
          currentWebViewProvider.settings?.displayZoomControls = value;
          webViewController?.setSettings(
              settings:
                  currentWebViewProvider.settings ?? InAppWebViewSettings());
          currentWebViewProvider.settings =
              await webViewController?.getSettings();
          browserProvider.save();
        },
      ),
      ListTile(
        title: const Text("Cursive Font Family"),
        subtitle: const Text("Sets the cursive font family name."),
        trailing: SizedBox(
          width: MediaQuery.of(context).size.width / 3,
          child: TextFormField(
            initialValue: currentWebViewProvider.settings?.cursiveFontFamily,
            keyboardType: TextInputType.text,
            onFieldSubmitted: (value) async {
              currentWebViewProvider.settings?.cursiveFontFamily = value;
              webViewController?.setSettings(
                  settings: currentWebViewProvider.settings ??
                      InAppWebViewSettings());
              currentWebViewProvider.settings =
                  await webViewController?.getSettings();
              browserProvider.save();
            },
          ),
        ),
      ),
      ListTile(
        title: const Text("Default Font Size"),
        subtitle: const Text("Sets the default font size."),
        trailing: SizedBox(
          width: 50.0,
          child: TextFormField(
            initialValue:
                currentWebViewProvider.settings?.defaultFontSize.toString(),
            keyboardType: const TextInputType.numberWithOptions(),
            onFieldSubmitted: (value) async {
              currentWebViewProvider.settings?.defaultFontSize =
                  int.parse(value);
              webViewController?.setSettings(
                  settings: currentWebViewProvider.settings ??
                      InAppWebViewSettings());
              currentWebViewProvider.settings =
                  await webViewController?.getSettings();
              browserProvider.save();
            },
          ),
        ),
      ),
      ListTile(
        title: const Text("Force Dark"),
        subtitle: const Text("Set the force dark mode for this WebView."),
        trailing: DropdownButton<ForceDark>(
          hint: const Text("Force Dark"),
          onChanged: (value) async {
            currentWebViewProvider.settings?.forceDark = value;
            webViewController?.setSettings(
                settings:
                    currentWebViewProvider.settings ?? InAppWebViewSettings());
            currentWebViewProvider.settings =
                await webViewController?.getSettings();
            browserProvider.save();
          },
          value: currentWebViewProvider.settings?.forceDark,
          items: ForceDark.values.map((forceDark) {
            return DropdownMenuItem<ForceDark>(
              value: forceDark,
              child: Text(
                forceDark.toString(),
                style: const TextStyle(fontSize: 12.5),
              ),
            );
          }).toList(),
        ),
      ),
      SwitchListTile(
        title: const Text("Geolocation Enabled"),
        subtitle: const Text("Sets whether Geolocation API is enabled."),
        value: currentWebViewProvider.settings?.geolocationEnabled ?? true,
        onChanged: (value) async {
          currentWebViewProvider.settings?.geolocationEnabled = value;
          webViewController?.setSettings(
              settings:
                  currentWebViewProvider.settings ?? InAppWebViewSettings());
          currentWebViewProvider.settings =
              await webViewController?.getSettings();
          browserProvider.save();
        },
      ),
      SwitchListTile(
        title: const Text("Third Party Cookies Enabled"),
        subtitle: const Text(
            "Sets whether the Webview should enable third party cookies."),
        value:
            currentWebViewProvider.settings?.thirdPartyCookiesEnabled ?? true,
        onChanged: (value) async {
          currentWebViewProvider.settings?.thirdPartyCookiesEnabled = value;
          webViewController?.setSettings(
              settings:
                  currentWebViewProvider.settings ?? InAppWebViewSettings());
          currentWebViewProvider.settings =
              await webViewController?.getSettings();
          browserProvider.save();
        },
      ),
      SwitchListTile(
        title: const Text("Hardware Acceleration"),
        subtitle: const Text(
            "Sets whether the Webview should enable Hardware Acceleration."),
        value: currentWebViewProvider.settings?.hardwareAcceleration ?? true,
        onChanged: (value) async {
          currentWebViewProvider.settings?.hardwareAcceleration = value;
          webViewController?.setSettings(
              settings:
                  currentWebViewProvider.settings ?? InAppWebViewSettings());
          currentWebViewProvider.settings =
              await webViewController?.getSettings();
          browserProvider.save();
        },
      ),
      SwitchListTile(
        title: const Text("Support Multiple Windows"),
        subtitle: const Text(
            "Sets whether the WebView whether supports multiple windows."),
        value: currentWebViewProvider.settings?.supportMultipleWindows ?? false,
        onChanged: (value) async {
          currentWebViewProvider.settings?.supportMultipleWindows = value;
          webViewController?.setSettings(
              settings:
                  currentWebViewProvider.settings ?? InAppWebViewSettings());
          currentWebViewProvider.settings =
              await webViewController?.getSettings();
          browserProvider.save();
        },
      ),
    ];

    return widgets;
  }
}
