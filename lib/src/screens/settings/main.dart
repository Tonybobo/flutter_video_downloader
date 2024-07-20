import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
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
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50), color: Colors.green),
            onTap: (value) {
              FocusScope.of(context).unfocus();
            },
            tabs: const [
              Tab(
                text: "Cross-Platform",
                icon: SizedBox(
                  width: double.infinity,
                  child: Icon(MaterialCommunityIcons.cellphone_cog),
                ),
              ),
              Tab(
                text: "Android",
                icon: SizedBox(
                  width: double.infinity,
                  child: Icon(Icons.android),
                ),
              ),
            ],
          ),
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
        ),
        body: const TabBarView(
          children: [
            Center(
              child: const Text("Cross Platform"),
            ),
            Center(
              child: const Text("Android Platform"),
            )
          ],
        ),
      ),
    );
  }

  void _popupMenuChoiceAction(String value) {}
}
