import 'dart:async';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sbmoby/models/webview_model.dart';
import 'package:sbmoby/tab_viewer.dart';
import 'package:sbmoby/util.dart';
import 'package:sbmoby/webview_tab.dart';

import 'app_bar/tab_viewer_app_bar.dart';
import 'app_bar/webview_tab_app_bar.dart';
import 'custom_image.dart';
import 'models/browser_model.dart';

class Browser extends StatefulWidget {
  const Browser({Key? key}) : super(key: key);

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> with SingleTickerProviderStateMixin {
  static const platform =
      MethodChannel('com.pichillilorenzo.flutter_browser.intent_data');

  var _isRestored = false;

  @override
  void initState() {
    super.initState();
    getIntentData();
  }

  getIntentData() async {
    if (Util.isAndroid()) {
      String? url = await platform.invokeMethod("getIntentData");
      if (url != null) {
        if (mounted) {
          var browserModel = Provider.of<BrowserModel>(context, listen: false);
          browserModel.addTab(WebViewTab(
            key: GlobalKey(),
            webViewModel: WebViewModel(url: WebUri(url)),
          ));
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  restore() async {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    browserModel.restore();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isRestored) {
      _isRestored = true;
      restore();
    }
    precacheImage(const AssetImage("assets/icon/icon.png"), context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBrowser();
  }

  Widget _buildBrowser() {
    var currentWebViewModel = Provider.of<WebViewModel>(context, listen: true);
    var browserModel = Provider.of<BrowserModel>(context, listen: true);

    browserModel.addListener(() {
      browserModel.save();
    });
    currentWebViewModel.addListener(() {
      browserModel.save();
    });

    var canShowTabScroller =
        browserModel.showTabScroller && browserModel.webViewTabs.isNotEmpty;

    return IndexedStack(
      index: canShowTabScroller ? 1 : 0,
      children: [
        _buildWebViewTabs(),
        canShowTabScroller ? _buildWebViewTabsViewer() : Container()
      ],
    );
  }

  Widget _buildWebViewTabs() {
    return WillPopScope(
        onWillPop: () async {
          var browserModel = Provider.of<BrowserModel>(context, listen: false);
          var webViewModel = browserModel.getCurrentTab()?.webViewModel;
          var webViewController = webViewModel?.webViewController;

          if (webViewController != null) {
            if (await webViewController.canGoBack()) {
              webViewController.goBack();
              return false;
            }
          }

          if (webViewModel != null && webViewModel.tabIndex != null) {
            setState(() {
              browserModel.closeTab(webViewModel.tabIndex!);
            });
            if (mounted) {
              FocusScope.of(context).unfocus();
            }
            return false;
          }

          return browserModel.webViewTabs.isEmpty;
        },
        child: Listener(
          onPointerUp: (_) {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus &&
                currentFocus.focusedChild != null) {
              currentFocus.focusedChild!.unfocus();
            }
          },
          child: SafeArea(
              child: Scaffold(
                  // appBar: const BrowserAppBar(),
                  bottomNavigationBar: const WebViewTabAppBar(),
                  body: _buildWebViewTabsContent())),
        ));
  }

  Widget _buildWebViewTabsContent() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    bool isKeyboardShown = 0 < MediaQuery.of(context).viewInsets.bottom;
    if (browserModel.webViewTabs.isEmpty) {
      // タブを開く前に
      browserModel.addTab(WebViewTab(
          key: GlobalKey(),
          webViewModel: WebViewModel(
            url: WebUri('https://scrapbox.io/'),
          )));
      // return const EmptyTab();
    }

    for (final webViewTab in browserModel.webViewTabs) {
      var isCurrentTab =
          webViewTab.webViewModel.tabIndex == browserModel.getCurrentTabIndex();

      if (isCurrentTab) {
        Future.delayed(const Duration(milliseconds: 100), () {
          webViewTabStateKey.currentState?.onShowTab();
        });
      } else {
        webViewTabStateKey.currentState?.onHideTab();
      }
    }

    var currentTab = browserModel.getCurrentTab();

    Future<String?> fetchPageTitle(String url) async {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parse(response.body);
        final title = document.querySelector('title')?.text;
        return title;
      }
      return null;
    }

    var stackChildren = <Widget>[
      Expanded(child: currentTab ?? Container()),
      _createProgressIndicator(),
      if (isKeyboardShown)
        Container(
            height: 40,
            color: Colors.black12,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: IconButton(
                    onPressed: () async {
                      currentTab?.webViewModel.webViewController
                          ?.evaluateJavascript(source: 'sbmobyOutdent();');
                    },
                    icon: const Icon(
                      Icons.chevron_left,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: IconButton(
                    onPressed: () async {
                      currentTab?.webViewModel.webViewController
                          ?.evaluateJavascript(source: 'sbmobyIndent();');
                    },
                    icon: const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: IconButton(
                    onPressed: () async {
                      currentTab?.webViewModel.webViewController
                          ?.evaluateJavascript(source: 'sbmobyUpLines();');
                    },
                    icon: const Icon(
                      Icons.expand_less,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: IconButton(
                    onPressed: () async {
                      currentTab?.webViewModel.webViewController
                          ?.evaluateJavascript(source: 'sbmobyDownLines();');
                    },
                    icon: const Icon(
                      Icons.expand_more,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            color: Colors.black54,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: IconButton(
                              onPressed: () async {
                                currentTab?.webViewModel.webViewController
                                    ?.evaluateJavascript(
                                        source: 'sbmobyCut();');
                              },
                              icon: const Icon(
                                Icons.content_cut,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: IconButton(
                              onPressed: () async {
                                var clipboardData = await Clipboard.getData(
                                    Clipboard.kTextPlain);
                                var url = clipboardData?.text ?? '';
                                if (url.startsWith('http')) {
                                  var title = await fetchPageTitle(url);
                                  var text = '[$url $title]';
                                  await Clipboard.setData(
                                      ClipboardData(text: text));
                                }
                              },
                              icon: const Icon(
                                Icons.link,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: IconButton(
                              onPressed: () async {
                                currentTab?.webViewModel.webViewController
                                    ?.evaluateJavascript(
                                        source: 'sbmobyUndo();');
                              },
                              icon: const Icon(
                                Icons.replay,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: IconButton(
                              onPressed: () async {
                                currentTab?.webViewModel.webViewController
                                    ?.evaluateJavascript(
                                        source: 'sbmobyAddIcon();');
                              },
                              icon: const Icon(
                                Icons.face,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: GestureDetector(
                              onLongPressEnd: (LongPressEndDetails details) {},
                              onTap: () async {
                                currentTab?.webViewModel.webViewController
                                    ?.evaluateJavascript(
                                        source: 'sbmobyBackspace();');
                              },
                              child: const Icon(
                                Icons.backspace,
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ))
    ];

    return Column(
      children: stackChildren,
    );
  }

  Widget _createProgressIndicator() {
    return Selector<WebViewModel, double>(
        selector: (context, webViewModel) => webViewModel.progress,
        builder: (context, progress, child) {
          if (progress >= 1.0) {
            return Container();
          }
          return PreferredSize(
              preferredSize: const Size(double.infinity, 4.0),
              child: SizedBox(
                  height: 4.0,
                  child: LinearProgressIndicator(
                    value: progress,
                  )));
        });
  }

  Widget _buildWebViewTabsViewer() {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    return WillPopScope(
        onWillPop: () async {
          browserModel.showTabScroller = false;
          return false;
        },
        child: Scaffold(
            appBar: const TabViewerAppBar(),
            body: Column(children: <Widget>[
              Expanded(
                child: TabViewer(
                  currentIndex: browserModel.getCurrentTabIndex(),
                  children: browserModel.webViewTabs.map((webViewTab) {
                    webViewTabStateKey.currentState?.pause();
                    var screenshotData = webViewTab.webViewModel.screenshot;
                    Widget screenshotImage = Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      width: double.infinity,
                      child: screenshotData != null
                          ? Image.memory(screenshotData)
                          : null,
                    );

                    var url = webViewTab.webViewModel.url;
                    var faviconUrl = webViewTab.webViewModel.favicon != null
                        ? webViewTab.webViewModel.favicon!.url
                        : (url != null && ["http", "https"].contains(url.scheme)
                            ? Uri.parse("${url.origin}/favicon.ico")
                            : null);

                    var isCurrentTab = browserModel.getCurrentTabIndex() ==
                        webViewTab.webViewModel.tabIndex;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Material(
                          color: isCurrentTab
                              ? Colors.blue
                              : (webViewTab.webViewModel.isIncognitoMode
                                  ? Colors.black
                                  : Colors.white),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                // CachedNetworkImage(
                                //   placeholder: (context, url) =>
                                //   url == "about:blank"
                                //       ? Container()
                                //       : CircularProgressIndicator(),
                                //   imageUrl: faviconUrl,
                                //   height: 30,
                                // )
                                CustomImage(
                                    url: faviconUrl,
                                    maxWidth: 30.0,
                                    height: 30.0)
                              ],
                            ),
                            title: Text(
                                webViewTab.webViewModel.title ??
                                    webViewTab.webViewModel.url?.toString() ??
                                    "",
                                maxLines: 2,
                                style: TextStyle(
                                  color:
                                      webViewTab.webViewModel.isIncognitoMode ||
                                              isCurrentTab
                                          ? Colors.white
                                          : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis),
                            subtitle: Text(
                                webViewTab.webViewModel.url?.toString() ?? "",
                                style: TextStyle(
                                  color:
                                      webViewTab.webViewModel.isIncognitoMode ||
                                              isCurrentTab
                                          ? Colors.white60
                                          : Colors.black54,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 20.0,
                                    color: webViewTab
                                                .webViewModel.isIncognitoMode ||
                                            isCurrentTab
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (webViewTab.webViewModel.tabIndex !=
                                          null) {
                                        browserModel.closeTab(
                                            webViewTab.webViewModel.tabIndex!);
                                        if (browserModel.webViewTabs.isEmpty) {
                                          browserModel.showTabScroller = false;
                                        }
                                      }
                                    });
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: screenshotImage,
                        )
                      ],
                    );
                  }).toList(),
                  onTap: (index) async {
                    browserModel.showTabScroller = false;
                    browserModel.showTab(index);
                  },
                ),
              ),
            ])));
  }
}
