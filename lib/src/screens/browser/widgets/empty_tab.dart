import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:video_downloader/src/database/histories/histories_db_helper.dart';
import 'package:video_downloader/src/database/histories/histories_model.dart';
import 'package:video_downloader/src/database/queries/query_conditions.dart';
import 'package:video_downloader/src/database/recents/recents_db_helper.dart';
import 'package:video_downloader/src/database/recents/recents_model.dart';
import 'package:video_downloader/src/providers/broswer_provider.dart';
import 'package:video_downloader/src/providers/web_view_provider.dart';
import 'package:video_downloader/src/screens/browser/widgets/custom_image.dart';
import 'package:video_downloader/src/screens/browser/widgets/webview_tab.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({super.key});

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  final _controller = TextEditingController();
  final histories = <HistoriesModel>[];
  final recents = <RecentsModel>[];

  @override
  void initState(){
    super.initState();
    fetchTopRecentsAndHistories();
  }

  Future<void> fetchTopRecentsAndHistories() async {
    final recentsResult =  await RecentsDbHelper().read(QueryConditions(
      limit: 10,
      offset: 0,
      orderBy: "counts DESC"
    ));
    final historiesResult =  await HistoriesDbHelper().read(QueryConditions());
    if(mounted){
      setState(() {
        recents.addAll(recentsResult);
        histories.addAll(historiesResult);
      });
    }
  }

  void openNewTab(String value) {
    var browserProvider = Provider.of<BrowserProvider>(context, listen: false);
    var settings = browserProvider.getSettings();

    browserProvider.addTab(WebViewTab(
      key: GlobalKey(),
      webViewProvider: WebViewProvider(
        url: WebUri(value.startsWith("http")
            ? value
            : settings.searchEngine.searchUrl + value),
      ),
    ));
  }

  Widget _buildRecentsListView(List<RecentsModel> recents){
    return SizedBox(
      height: 100,
      width: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: recents.length,
        shrinkWrap: true,
        itemBuilder: (_ , index){
          var recent = recents[index];
          return
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: SizedBox(
                    height: 100,
                    width: 70,
                    child:GestureDetector(
                        onTap: () {
                          openNewTab("https://${recent.url.host.toString()}");
                        },
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomImage(
                              url: WebUri("https://www.google.com/s2/favicons?sz=64&domain_url=${recent.url.origin}"),
                              width: 50,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              recent.url.host.split(".")[recent.url.host.split('.').length-2],
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              textAlign: TextAlign.center,
                              style:const TextStyle(
                                  fontSize: 13.0,
                                  fontWeight:FontWeight.w200,
                                  wordSpacing: 8
                              ),
                            )
                          ],
                        )
                    )
                )
            );
        },
      ) ,
    );
  }

  Widget _buildHistoriesListView(List<HistoriesModel> histories){
     return SizedBox(
       height: 100,
       width: 70,
       child: ListView.builder(
         scrollDirection: Axis.horizontal,
         itemCount: histories.length,
         shrinkWrap: true,
         itemBuilder: (_ , index){
           var history = histories[index];
           return
           Padding(
             padding: const EdgeInsets.only(right: 20.0),
             child: SizedBox(
                 height: 100,
                 width: 70,
                 child:GestureDetector(
                   onTap: () {
                     openNewTab(history.url.toString());
                   },
                   child:Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       CustomImage(
                         url: WebUri("https://www.google.com/s2/favicons?sz=64&domain_url=${history.url.origin}"),
                         width: 50,
                       ),
                       const SizedBox(
                         height: 10,
                       ),
                       Text(
                         history.title!,
                         overflow: TextOverflow.fade,
                         maxLines: 1,
                         softWrap: false,
                         style:const TextStyle(
                           fontSize: 13.0,
                           fontWeight:FontWeight.w200,
                           wordSpacing: 8
                         ),
                       )
                     ],
                   )
                 )
               )
           );
         },
       ) ,
     );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => openNewTab(value),
                    textInputAction: TextInputAction.go,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      contentPadding: const EdgeInsets.all(20.0),
                      hintText: "Search",
                      hintStyle: const TextStyle(
                        fontSize: 25.0,
                      ),
                    ),
                    style: const TextStyle(fontSize: 25.0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  Text("Histories",textAlign: TextAlign.start)
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildHistoriesListView(histories),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Most Used Websites",textAlign: TextAlign.start)
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildRecentsListView(recents),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
