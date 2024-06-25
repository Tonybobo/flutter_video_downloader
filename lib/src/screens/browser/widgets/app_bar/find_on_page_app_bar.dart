import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';

class FindOnPageAppBar extends StatefulWidget {
  final void Function()? hideFindOnPage;

  const FindOnPageAppBar({super.key, this.hideFindOnPage});

  @override
  State<FindOnPageAppBar> createState() => _FindOnPageAppBarState();
}

class _FindOnPageAppBarState extends State<FindOnPageAppBar> {
  final TextEditingController _findOnPageController = TextEditingController();

  OutlineInputBorder outlineInputBorder = const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.transparent,
      width: 0.0,
    ),
    borderRadius: BorderRadius.all(
      Radius.circular(50.0),
    ),
  );

  @override
  void dispose() {
    _findOnPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    var webViewProvider = browserProvider.getCurrentTab()?.webViewProvider;
    var findInteractionController = webViewProvider?.findInteractionController;

    return AppBar(
      titleSpacing: 10.0,
      title: SizedBox(
        height: 40.0,
        child: TextField(
          onSubmitted: (value) {
            findInteractionController?.findAll(find: value);
          },
          controller: _findOnPageController,
          textInputAction: TextInputAction.go,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10.0),
              filled: true,
              fillColor: Colors.white,
              border: outlineInputBorder,
              focusedBorder: outlineInputBorder,
              enabledBorder: outlineInputBorder,
              hintText: "Find On Page...",
              hintStyle:
                  const TextStyle(color: Colors.black54, fontSize: 16.0)),
          style: const TextStyle(color: Colors.black, fontSize: 16.0),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            findInteractionController?.findNext(forward: false);
          },
          icon: const Icon(Icons.keyboard_arrow_up),
        ),
        IconButton(
          onPressed: () {
            findInteractionController?.findNext(forward: true);
          },
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        IconButton(
          onPressed: () {
            findInteractionController?.clearMatches();
            _findOnPageController.text = "";

            if (widget.hideFindOnPage != null) {
              widget.hideFindOnPage!();
            }
          },
          icon: const Icon(Icons.close),
        )
      ],
    );
  }
}
