import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/database/histories/histories_db_helper.dart';
import 'package:video_downloader/src/database/histories/histories_model.dart';
import 'package:video_downloader/src/database/queries/query_conditions.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/custom_image.dart';

class HistoriesScrollList extends StatefulWidget {
  const HistoriesScrollList({super.key});

  @override
  State<HistoriesScrollList> createState() => _HistoriesScrollListState();
}

class _HistoriesScrollListState extends State<HistoriesScrollList> {
  final ScrollController _scrollController = ScrollController();
  final _histories = <HistoriesModel>[];
  final _queryCondition = QueryConditions();
  bool _isLoading = false;

  void _loadMore() {
    if (_scrollController.position.pixels >=
            (_scrollController.position.maxScrollExtent - 200) &&
        !_isLoading) {
      setState(() {
        _queryCondition.offset += 10;
      });
      getHistories(_queryCondition);
    }
  }

  Future<void> getHistories(QueryConditions query) async {
    setState(() {
      _isLoading = true;
    });
    final db = HistoriesDbHelper();
    final result = await db.read(query);
    setState(() {
      _histories.addAll(result);
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getHistories(_queryCondition);
    _scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMore)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var webViewProvider = Provider.of<WebViewProvider>(context, listen: false);
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            var item = _histories[index];
            if (index == _histories.length) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImage(
                    url: WebUri("${item.url.origin}/favicon.ico"),
                    maxWidth: 30.0,
                    height: 30.0,
                  )
                ],
              ),
              title: Text(
                item.title ?? "",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.url.toString(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              onTap: () {
                webViewProvider.webViewController
                    ?.loadUrl(urlRequest: URLRequest(url: item.url));
                Navigator.pop(context);
              },
            );
          }, childCount: _histories.length),
        )
      ],
    );
  }
}
