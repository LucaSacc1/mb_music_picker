class MBMusicItem {
  final String identifier;
  final String title;
  final String artist;
  final String url;

  MBMusicItem({
    required this.identifier,
    required this.title,
    required this.artist,
    required this.url,
  });

  factory MBMusicItem.fromCupertinoMap(Map map) => MBMusicItem(
    identifier: map["identifier"],
    title: map['title'],
    artist: map['artist'],
    url: map['asset_url'],
  );

  factory MBMusicItem.fromAndroidMap(Map map) => MBMusicItem(
    identifier: map["identifier"],
    title: map['title'],
    artist: map['artist'],
    url: map['asset_url'],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MBMusicItem &&
          runtimeType == other.runtimeType &&
          identifier == other.identifier;
}
