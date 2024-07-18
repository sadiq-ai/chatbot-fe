import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'audio_player.dart';
import 'chat_model.dart';
import 'network.dart';
import 'text_widget.dart';
import 'utils.dart';

class Chatapp extends StatefulWidget {
  const Chatapp({super.key});

  @override
  State<Chatapp> createState() => _ChatappState();
}

class _ChatappState extends State<Chatapp> {
  final TextEditingController _controller = TextEditingController();
  final AudioRecorder record = AudioRecorder();
  Widget _prefixIcon = const Icon(Icons.emoji_emotions);
  Widget _suffixIcon = const Icon(Icons.mic);
  bool _isRecording = false;
  DateTime? _recordingStart;
  Timer? _timer;

  List<ChatModel> messages = <ChatModel>[];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  Widget _buildPrefix(Duration? duration) {
    if (duration == null) {
      return const Icon(Icons.emoji_emotions);
    }

    return Row(
      children: <Widget>[
        const SizedBox(width: 8),
        // Animated Icon for Mic flashing in red
        const Icon(
          Icons.mic,
          color: Colors.red,
        ),
        // Time elapsed in format:  00:00
        Text(
          '${duration.inMinutes.remainder(60).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}',
        ),
      ],
    );
  }

  // Start Timer for recording, runs every second
  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        final Duration duration = DateTime.now().difference(_recordingStart!);
        _prefixIcon = _buildPrefix(duration);
        setState(() {});
      },
    );
  }

  void _startRecording() async {
    // Check and request permission if needed
    if (await record.hasPermission()) {
      _recordingStart = DateTime.now();
      setState(() => _isRecording = true);
      _startTimer();
      // Directory path
      Directory? appDocDirectory;
      if (Platform.isIOS) {
        appDocDirectory = await getApplicationDocumentsDirectory();
      } else {
        appDocDirectory = await getExternalStorageDirectory();
      }
      // Start recording to file
      await record.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
        ),
        path: '${appDocDirectory!.path}/test.wav',
      );
      print('recording stream: $_recordingStart');
    }
  }

  void _stopRecording() async {
    // Stop recording
    final String? path = await record.stop();
    _timer?.cancel();
    print('recording path: $path');
    _prefixIcon = const Icon(Icons.emoji_emotions);
    String base64Audio = '';
    if (path != null) {
      final File file = File(path);
      final List<int> bytes = await file.readAsBytes();
      base64Audio = base64Encode(bytes);
    }
    sendMessageToAI(base64Audio: base64Audio);
    messages.add(
      ChatModel(
        author: 'user',
        message: base64Audio,
        timestamp: DateTime.now(),
        type: MessageType.audio,
      ),
    );
    setState(() => _isRecording = false);
  }

  void sendMessageToAI({String? base64Audio, String? text}) async {
    Object payload = <String, dynamic>{
      'base64': base64Audio,
      'text': text,
    };
    Map<String, dynamic>? response;
    response = await NetworkCall().post(route: '/talk-to-ai', payload: payload);
    print('Api response: $response');
    if (response == null) return;
    messages.add(
      ChatModel(
        author: 'ai-chatbot',
        message: response['data'],
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    record.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    print('recording: $_isRecording');

    if (_controller.text.isNotEmpty && !_isRecording) {
      _suffixIcon = const Icon(Icons.send);
    } else {
      _suffixIcon = const Icon(Icons.mic_outlined);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat App'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              itemCount: messages.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: messages[index].author == 'user'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: ChatMessage(message: messages[index]),
                );
              },
            ),
          ),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Type a message',
              prefixIcon: _prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              suffixIcon: GestureDetector(
                onLongPress: _startRecording,
                onLongPressUp: _stopRecording,
                onTap: onMessageSend,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: _suffixIcon,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void onMessageSend() {
    if (_controller.text.isNotEmpty) {
      messages.add(
        ChatModel(
          author: 'user',
          message: _controller.text,
          timestamp: DateTime.now(),
          type: MessageType.text,
        ),
      );
      sendMessageToAI(text: _controller.text);
      _controller.clear();
      setState(() {});
    }
  }
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key, required this.message});
  final ChatModel message;
  @override
  Widget build(BuildContext context) {
    bool isMyMessage = message.author == 'user';

    Widget messageWidget = const SizedBox();
    if (message.type == MessageType.text) {
      messageWidget = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SadiqExpandableText(
              text: message.message,
              maxLines: 5,
              color: Colors.black,
              toggleColor: Colors.grey,
            ),
            Container(
              margin: const EdgeInsets.only(top: 15),
              child: Text(
                Compute.dateFormat(message.timestamp),
                style: const TextStyle(
                  color: Colors.grey,
                  height: 0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (message.type == MessageType.audio) {
      messageWidget = VoiceMessagePlayer(
        base64Audio: message.message,
        timestamp: message.timestamp,
      );
    }
    return Container(
      padding: const EdgeInsets.all(10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
        color: isMyMessage ? Colors.blue[200] : Colors.white,
      ),
      child: messageWidget,
    );
  }
}
