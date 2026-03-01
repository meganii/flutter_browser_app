import 'package:comoreby/models/browser_model.dart';
import 'package:comoreby/models/search_engine_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BrowserSettings defaults are Cosense-first', () {
    final settings = BrowserSettings();

    expect(settings.searchEngine, CosenseSearchEngine);
    expect(settings.homePageEnabled, isTrue);
    expect(settings.customUrlHomePage, 'https://scrapbox.io/');
    expect(settings.debuggingEnabled, isFalse);
  });

  test('BrowserSettings.fromMap falls back to Cosense on invalid index', () {
    final restored = BrowserSettings.fromMap({
      'searchEngineIndex': 999,
      'homePageEnabled': true,
      'customUrlHomePage': '',
      'debuggingEnabled': false,
    });

    expect(restored, isNotNull);
    expect(restored!.searchEngine, CosenseSearchEngine);
    expect(restored.customUrlHomePage, 'https://scrapbox.io/');
  });

  test('Search engine list is restricted to Cosense', () {
    expect(SearchEngines, hasLength(1));
    expect(SearchEngines.first, CosenseSearchEngine);
    expect(SearchEngines.first.url, 'https://scrapbox.io/');
  });
}
