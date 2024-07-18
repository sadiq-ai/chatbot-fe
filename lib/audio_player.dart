import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils.dart';

// import 'constants.dart';

class VoiceMessagePlayer extends StatefulWidget {
  const VoiceMessagePlayer({
    super.key,
    required this.base64Audio,
    this.timestamp,
  });
  final String base64Audio;
  final DateTime? timestamp;

  @override
  State<VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<VoiceMessagePlayer> {
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  AudioPlayer? _player;
  Uint8List? _data;
  Source? _source;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    initPlayer();
  }

  @override
  void dispose() {
    // _player?.dispose();
    super.dispose();
  }

  void initPlayer() async {
    _player = AudioPlayer();
    _data = Uint8List.fromList(base64Decode(widget.base64Audio));
    await _player!.setSourceBytes(_data!, mimeType: 'audio/wav');
    _source = _player!.source;
    _duration = await _player?.getDuration() ?? Duration.zero;

    _player!.onDurationChanged.listen((Duration newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });

    _player!.onPositionChanged.listen((Duration newPosition) {
      _position = newPosition;
      if (_position >= _duration) _isPlaying = false;
      setState(() {});
    });
  }

  void play() async {
    print('source: $_source');
    if (_isPlaying) {
      await _player!.pause();
    } else {
      await _player!.play(_source!);
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final String hours = twoDigits(duration.inHours);
    final String minutes = twoDigits(duration.inMinutes % 60);
    final String seconds = twoDigits(duration.inSeconds % 60);
    return "${hours != '00' ? '$hours:' : ''}$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(right: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: play,
              ),
              Text(formatDuration(_position)),
              // Controller line for audio
              Expanded(
                child: Slider(
                  value: _position.inMilliseconds.toDouble(),
                  min: 0.0,
                  max: _duration.inMilliseconds.toDouble(),
                  onChanged: (double value) {
                    _player!.seek(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
              Text(formatDuration(_duration)),
            ],
          ),
          Text(
            Compute.dateFormat(widget.timestamp ?? DateTime.now()),
            style: const TextStyle(
              color: Colors.grey,
              height: 0,
            ),
          ),
        ],
      ),
    );
  }
}
