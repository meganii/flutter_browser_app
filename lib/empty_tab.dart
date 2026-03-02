import 'package:comoreby/models/browser_model.dart';
import 'package:comoreby/models/webview_model.dart';
import 'package:comoreby/webview_tab.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({super.key});

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  @override
  Widget build(BuildContext context) {
    // var browserModel = Provider.of<BrowserModel>(context, listen: true);
    // var settings = browserModel.getSettings();

    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: RichText(
        text: TextSpan(
          text: 'Go To ',
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: 'Cosense',
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
