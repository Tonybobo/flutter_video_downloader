import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/custom_image.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';

class LongPressAlertDialog extends StatefulWidget {
  static const List<InAppWebViewHitTestResultType> hitTestResultSupport = [
    InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE,
    InAppWebViewHitTestResultType.IMAGE_TYPE
  ];
  const LongPressAlertDialog(
      {super.key,
      required this.webViewProvider,
      required this.hitTestResult,
      this.requestFocusNodeHrefResult});

  final WebViewProvider webViewProvider;
  final InAppWebViewHitTestResult hitTestResult;
  final RequestFocusNodeHrefResult? requestFocusNodeHrefResult;

  @override
  State<LongPressAlertDialog> createState() => _LongPressAlertDialogState();
}

class _LongPressAlertDialogState extends State<LongPressAlertDialog> {
  var _isLinkPreviewRead = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0.0),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildDialogLongPressHitTestResult(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDialogLongPressHitTestResult() {
    if (widget.hitTestResult.type ==
            InAppWebViewHitTestResultType.SRC_ANCHOR_TYPE ||
        widget.hitTestResult.type ==
            InAppWebViewHitTestResultType.SRC_IMAGE_ANCHOR_TYPE ||
        (widget.hitTestResult.type ==
                InAppWebViewHitTestResultType.IMAGE_TYPE &&
            widget.requestFocusNodeHrefResult != null &&
            widget.requestFocusNodeHrefResult!.url != null &&
            widget.requestFocusNodeHrefResult!.url.toString().isNotEmpty)) {
      return <Widget>[
        _buildLinkTile(),
        const Divider(),
        _buildLinkPreview(),
        const Divider(),
        _buildOpenNewTab(),
        _buildOpenNewIncognitoTab(),
        _buildCopyAddressLink(),
        _buildShareLink(),
      ];
    } else if (widget.hitTestResult.type ==
        InAppWebViewHitTestResultType.IMAGE_TYPE) {
      return <Widget>[
        _buildImageTile(),
        const Divider(),
        _buildOpenImageNewTab(),
        _buildSearchImageOnGoogle(),
        _buildShareImage(),
      ];
    }
    return [];
  }

  Widget _buildLinkTile() {
    var url =
        widget.requestFocusNodeHrefResult?.url ?? Uri.parse("about:blank");
    var faviconUrl = Uri.parse("${url.origin}/favicon.ico");

    var title = widget.requestFocusNodeHrefResult?.title ?? "";

    if (title.isEmpty) title = "Link";

    return ListTile(
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomImage(
            url: widget.requestFocusNodeHrefResult?.src != null
                ? Uri.parse(widget.requestFocusNodeHrefResult!.src!)
                : faviconUrl,
            maxWidth: 30.0,
            height: 30.0,
          )
        ],
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.requestFocusNodeHrefResult?.url?.toString() ?? "",
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
    );
  }

  Widget _buildLinkPreview() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    browserProvider.getSettings();

    return ListTile(
      title: const Center(
        child: Text(
          "Link Preview",
        ),
      ),
      subtitle: Container(
        padding: const EdgeInsets.only(top: 15.0),
        height: 250,
        child: IndexedStack(
          index: _isLinkPreviewRead ? 1 : 0,
          children: [
            const Center(child: CircularProgressIndicator()),
            InAppWebView(
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                )
              },
              initialUrlRequest:
                  URLRequest(url: widget.requestFocusNodeHrefResult?.url),
              initialSettings: InAppWebViewSettings(
                verticalScrollbarThumbColor: const Color.fromRGBO(0, 0, 0, 0.5),
                horizontalScrollbarThumbColor:
                    const Color.fromRGBO(0, 0, 0, 0.5),
              ),
              onProgressChanged: (controller, progress) {
                if (progress > 50) {
                  setState(() {
                    _isLinkPreviewRead = true;
                  });
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOpenNewTab() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    return ListTile(
      title: const Text("Open in a new tab"),
      onTap: () {
        browserProvider.addTab(
          WebViewTab(
            key: GlobalKey(),
            webViewProvider:
                WebViewProvider(url: widget.requestFocusNodeHrefResult?.url),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  Widget _buildOpenNewIncognitoTab() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: true);
    return ListTile(
      title: const Text("Open in a new incognito tab"),
      onTap: () {
        browserProvider.addTab(
          WebViewTab(
            key: GlobalKey(),
            webViewProvider: WebViewProvider(
              url: widget.requestFocusNodeHrefResult?.url,
              isIncognitoMode: true,
            ),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  Widget _buildCopyAddressLink() {
    return ListTile(
      title: const Text("Copy address link"),
      onTap: () {
        Clipboard.setData(ClipboardData(
            text: widget.requestFocusNodeHrefResult?.url.toString() ??
                widget.hitTestResult.extra ??
                ''));
        Navigator.pop(context);
      },
    );
  }

  Widget _buildShareLink() {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Share Link"),
          Padding(
            padding: EdgeInsets.only(right: 12.5),
            child: Icon(
              Icons.share,
              color: Colors.black54,
              size: 20.0,
            ),
          ),
        ],
      ),
      onTap: () {
        if (widget.hitTestResult.extra != null) {
          Share.share(widget.requestFocusNodeHrefResult?.url.toString() ??
              widget.hitTestResult.extra!);
        }
      },
    );
  }

  Widget _buildImageTile() {
    return ListTile(
      contentPadding: const EdgeInsets.only(
          left: 15.0, top: 15.0, right: 15.0, bottom: 5.0),
      leading: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CustomImage(
            url: Uri.parse(widget.hitTestResult.extra!),
            maxWidth: 50.0,
            height: 50.0,
          )
        ],
      ),
      title: Text(widget.webViewProvider.title ?? ""),
    );
  }

  Widget _buildOpenImageNewTab() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    return ListTile(
      title: const Text("Open Image in new tab"),
      onTap: () {
        browserProvider.addTab(
          WebViewTab(
            key: GlobalKey(),
            webViewProvider: WebViewProvider(
              url: WebUri(widget.hitTestResult.extra ?? "about:blank"),
            ),
          ),
        );
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSearchImageOnGoogle() {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    return ListTile(
      title: const Text("Search this image on Google"),
      onTap: () {
        if (widget.hitTestResult.extra != null) {
          var url =
              "http://images.google.com/searchbyimage?image_url=${widget.hitTestResult.extra!}";
          browserProvider.addTab(WebViewTab(
            key: GlobalKey(),
            webViewProvider: WebViewProvider(url: WebUri(url)),
          ));
        }
      },
    );
  }

  Widget _buildShareImage() {
    return ListTile(
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Share image"),
          Padding(
            padding: EdgeInsets.only(right: 12.5),
            child: Icon(
              Icons.share,
              color: Colors.black54,
              size: 20.0,
            ),
          )
        ],
      ),
      onTap: () {
        if (widget.hitTestResult.extra != null) {
          Share.share(widget.hitTestResult.extra!);
        }
        Navigator.pop(context);
      },
    );
  }
}
