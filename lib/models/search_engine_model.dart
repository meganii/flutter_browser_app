class SearchEngineModel {
  final String name;
  final String assetIcon;
  final String url;
  final String searchUrl;

  const SearchEngineModel(
      {required this.name,
      required this.url,
      required this.searchUrl,
      required this.assetIcon});

  static SearchEngineModel? fromMap(Map<String, dynamic>? map) {
    return map != null
        ? SearchEngineModel(
            name: map["name"],
            assetIcon: map["assetIcon"],
            url: map["url"],
            searchUrl: map["searchUrl"])
        : null;
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "assetIcon": assetIcon,
      "url": url,
      "searchUrl": searchUrl
    };
  }

  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}

// ignore: constant_identifier_names
const CosenseSearchEngine = SearchEngineModel(
    name: "Cosense",
    url: "https://scrapbox.io/",
    searchUrl: "https://scrapbox.io/",
    assetIcon: "assets/icon/icon.png");

// ignore: constant_identifier_names
const SearchEngines = <SearchEngineModel>[CosenseSearchEngine];
