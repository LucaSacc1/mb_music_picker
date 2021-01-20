import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mb_music_picker/mb_music_picker.dart';
import 'package:mb_music_picker/mb_music_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MbMusicPicker _musicPicker = new MbMusicPicker();
  AudioPlayer _audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  AudioPlayerState _playerState;

  MBMusicItem _song;

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
    });

    _audioPlayer.onNotificationPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Music fetch example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Running on:'),
            CupertinoButton(
                child: Text('music'),
                onPressed: () async {
                  await _openMusicPicker();
                }
            ),
            Container(
              color: Colors.red,
              height: 40,
            ),
            _songAttributes()
          ]
        ),
      ),
    );
  }

  _songAttributes() {
    if (_song == null) {
      return Container();
    }
    return Expanded(
      child: ListView.builder(
          itemCount: 2,
          itemBuilder: (context, position) {
            if (position == 0) {
              return _listTile(_song.title + ' - ' + _song.artist);
            } else {
              return _audioRow();
            }
          }
      ),
    );
  }

  _listTile(String title) {
    return ListTile(
      title: Text(title),
    );
  }

  _audioRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'Audio',
            ),
            flex: 9,
          ),
          PlayPauseButton(
            isPlaying: _playerState != null
                ? _playerState == AudioPlayerState.PLAYING
                : false,
            onPlay: () => _playPause(),
          ),
        ],
      ),
    );
  }

  void _playPause() {
    if (_playerState == AudioPlayerState.PLAYING) {
      print('pause');
      _audioPlayer.pause();
    } else if (_playerState == AudioPlayerState.PAUSED) {
      print('resume');
      _audioPlayer.resume();
    } else {
      print('SONG URL: ${_song.url}');
      _audioPlayer.play(_song.url);
    }
  }

  Future _openMusicPicker() async {
    final PermissionStatus permissionStatus = await _getPermission();

    if (permissionStatus == PermissionStatus.granted) {
      var result = await _musicPicker.openMusicSelection();
      print(result);

      setState(() {
        _song = result;
      });
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => _alertDialog(context)
      );
    }
  }

  Future<PermissionStatus> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status;
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.mediaLibrary.status;

    if (permission != PermissionStatus.granted && permission != PermissionStatus.denied) {
      final PermissionStatus permissionStatus = await _requestPermission(Permission.mediaLibrary);
      return permissionStatus;
    } else {
      return permission;
    }
  }

  Widget _alertDialog(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text('Permissions error'),
        content: Text(
            'Please enable media access '
            'permission in system settings'
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      );
    }
    return AlertDialog(
      title: Text('Permissions error'),
      content: Text('Please enable media access '
          'permission in system settings'),
      actions: <Widget>[
        MaterialButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop()
        )
      ],
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Function() onPlay;

  PlayPauseButton({
    @required this.isPlaying,
    @required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 1.0),
        color: Colors.green,
        borderRadius: BorderRadius.circular(60 / 2),
      ),
      child: CupertinoButton(
          minSize: 60,
          child: Icon(
            isPlaying ? Icons.pause :Icons.play_arrow,
            size: 32,
            color: Colors.black,
          ),
          padding: const EdgeInsets.all(10.0),
          onPressed: this.onPlay,
        ),
    );
  }
}