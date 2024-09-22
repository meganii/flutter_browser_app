import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:sbmoby/webview_tab.dart';

import 'models/browser_model.dart';
import 'models/webview_model.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({Key? key}) : super(key: key);

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var browserModel = Provider.of<BrowserModel>(context, listen: true);
    var settings = browserModel.getSettings();

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: RichText(
        text: TextSpan(
          text: 'Go To ',
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: 'Scrapbox',
              style: const TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  openNewTab('https://scrapbox.io/');
                },
            ),
          ],
        ),
      ),
    ));
  }

  void openNewTab(value) {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();

    browserModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(
          url: WebUri(value.startsWith("http")
              ? value
              : settings.searchEngine.searchUrl + value)),
    ));
  }
}
