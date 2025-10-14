import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mb_music_picker/mb_music_picker.dart';
import 'package:mb_music_picker/mb_music_item.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final MbMusicPicker _musicPicker = new MbMusicPicker();

  AudioPlayer _audioPlayer = AudioPlayer();

  PlayerState? _playerState;

  MBMusicItem? _song;

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _playerState = state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music fetch example app')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('Running on:'),
          CupertinoButton(
            child: Text('music'),
            onPressed: () async {
              await _openMusicPicker();
            },
          ),
          Container(color: Colors.red, height: 40),
          _songAttributes(),
        ],
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
            return _listTile(_song!.title + ' - ' + _song!.artist);
          } else {
            return _audioRow();
          }
        },
      ),
    );
  }

  _listTile(String title) {
    return ListTile(title: Text(title));
  }

  _audioRow() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text('Audio'), flex: 9),
          PlayPauseButton(
            isPlaying: _playerState != null
                ? _playerState == PlayerState.playing
                : false,
            onPlay: () => _playPause(),
          ),
        ],
      ),
    );
  }

  void _playPause() {
    if (_playerState == PlayerState.playing) {
      print('pause');
      _audioPlayer.pause();
    } else if (_playerState == PlayerState.paused) {
      print('resume');
      _audioPlayer.resume();
    } else {
      print('SONG URL: ${_song?.url}');
      _audioPlayer.play(UrlSource(_song!.url));
    }
  }

  Future _openMusicPicker() async {
    PermissionStatus permissionStatus = await _getPermission();

    if (permissionStatus == PermissionStatus.granted) {
      var result = await _musicPicker.openMusicSelection();
      print(result);

      setState(() {
        _song = result;
      });
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) => _alertDialog(context),
      );
    }
  }

  Future<PermissionStatus> _getPermission() async {
    PermissionStatus status;

    if (Platform.isIOS) {
      status = await Permission.mediaLibrary.request();
    } else {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.audio.request();
      } else {
        status = await Permission.storage.request();
      }
    }

    return status;
  }

  Widget _alertDialog(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoAlertDialog(
        title: Text('Permissions error'),
        content: Text(
          'Please enable media access '
          'permission in system settings',
        ),
        actions: [
          CupertinoDialogAction(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text('Permissions error'),
      content: Text(
        'Please enable media access '
        'permission in system settings',
      ),
      actions: <Widget>[
        MaterialButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final Function() onPlay;

  PlayPauseButton({required this.isPlaying, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 1.0),
        color: Colors.green,
        borderRadius: BorderRadius.circular(60 / 2),
      ),
      child: CupertinoButton(
        minimumSize: Size(60, 60),
        child: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 32,
          color: Colors.black,
        ),
        padding: const EdgeInsets.all(10.0),
        onPressed: this.onPlay,
      ),
    );
  }
}
