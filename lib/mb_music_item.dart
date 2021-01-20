
class MBMusicItem {
  String identifier;
  String title;
  String artist;
  String url;

  MBMusicItem({
    this.identifier,
    this.title,
    this.artist,
    this.url
  });

  MBMusicItem.fromCupertinoMap(Map map) {
    identifier = map["identifier"];
    title = map['title'];
    artist = map['artist'];
    url = map['asset_url'];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is MBMusicItem &&
              runtimeType == other.runtimeType &&
              identifier == other.identifier;
}