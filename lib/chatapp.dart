// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_indicators/progress_indicators.dart';
import 'package:record/record.dart';
import 'package:ripple_wave/ripple_wave.dart';

import 'audio_player.dart';
import 'cards.dart';
import 'models/chat_model.dart';
import 'network.dart';
import 'models/product_model.dart';
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
  final ScrollController _scrollController = ScrollController();
  Widget _prefixIcon = const Icon(Icons.emoji_emotions);
  Widget _suffixIcon = const Icon(Icons.mic);
  bool _isRecording = false;
  DateTime? _recordingStart;
  Timer? _timer;
  bool _aiLoading = false;

  List<ChatModel> messages = <ChatModel>[];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
    // Add first message after 1 second
    Future<void>.delayed(const Duration(seconds: 1), addFirstMessage);
  }

  void addFirstMessage() {
    messages.add(
      ChatModel(
        author: 'ai-chatbot',
        message:
            '👋 Hello, I am Shopping Genie, your personal assistant. Ask me for any product recomendations or help you need.',
        timestamp: DateTime.now(),
        type: MessageType.text,
        product: null,
      ),
    );
    setState(() {});
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
    if (_isRecording) return _stopRecording();
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
    _scrollToBottom();
  }

  void sendMessageToAI({String? base64Audio, String? text}) async {
    Object payload = <String, dynamic>{
      'base64': base64Audio,
      'text': text,
    };
    Map<String, dynamic>? response;
    setState(() => _aiLoading = true);
    response = await NetworkCall().post(route: '/talk-to-ai', payload: payload);
    print('Api response: $response');
    setState(() => _aiLoading = false);
    if (response == null) return;
    messages.add(
      ChatModel(
        author: 'user',
        message: response['user'],
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );
    messages.add(
      ChatModel(
        author: 'ai-chatbot',
        message: response['data'],
        timestamp: DateTime.now(),
        type: MessageType.text,
      ),
    );
    List<dynamic> products = response['product_search'];
    if (products.isNotEmpty) {
      for (dynamic product in products) {
        ProductModel prod = ProductModel.fromJson(product);
        messages.add(
          ChatModel(
            author: 'ai-chatbot',
            message: '',
            timestamp: DateTime.now(),
            type: MessageType.product,
            product: prod,
          ),
        );
      }
    }
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
    // Size screen = MediaQuery.of(context).size;

    if (_controller.text.isNotEmpty && !_isRecording) {
      _suffixIcon = const Icon(Icons.send);
    } else {
      _suffixIcon = const Icon(Icons.mic_outlined);
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: ListTile(
          leading: Stack(
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                child: const Icon(Icons.support_agent),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          title: const Text('Shopping Genie'),
          subtitle: const Text('Online'),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 8,
            child: ListView.separated(
              controller: _scrollController,
              itemCount: messages.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 10);
              },
              itemBuilder: (BuildContext context, int index) {
                bool my = messages[index].author == 'user';
                bool isMsgContinuation = index > 0 &&
                    messages[index].author == messages[index - 1].author;
                return Column(
                  children: <Widget>[
                    if (!isMsgContinuation)
                      ListTile(
                        leading: my
                            ? null
                            : CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                                child: const Icon(Icons.support_agent),
                              ),
                        trailing: !my
                            ? null
                            : CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.blue[700],
                                child: const Icon(Icons.person),
                              ),
                        title: Align(
                          alignment:
                              my ? Alignment.centerRight : Alignment.centerLeft,
                          child: Text(my ? 'Customer' : 'Shopping Genie'),
                        ),
                        titleTextStyle:
                            const TextStyle(fontSize: 15, color: Colors.black),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      // alignment: messages[index].author != 'user'
                      //     ? Alignment.centerRight
                      //     : Alignment.centerLeft,
                      child: ChatMessage(message: messages[index]),
                    ),
                  ],
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.only(left: 10),
            alignment: Alignment.centerLeft,
            child: _aiLoading
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Text('AI is thinking '),
                      JumpingDotsProgressIndicator(fontSize: 20),
                    ],
                  )
                : null,
          ),
          // Tap to speak Button, round elevaed
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRecording ? Colors.blue[700] : Colors.blue[100],
                    foregroundColor:
                        _isRecording ? Colors.white : Colors.blue[700],
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: _isRecording
                      ? const RippleWave(
                          color: Colors.blue,
                          repeat: true,
                          child: Icon(
                            Icons.mic,
                            size: 50,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(Icons.mic, size: 48),
                ),
              ],
            ),
          ),
          // TextField(
          //   controller: _controller,
          //   decoration: InputDecoration(
          //     hintText: 'Type a message',
          //     prefixIcon: _prefixIcon,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(50),
          //     ),
          //     suffixIcon: GestureDetector(
          //       onLongPress: _startRecording,
          //       onLongPressUp: _stopRecording,
          //       onTap: onMessageSend,
          //       child: Padding(
          //         padding: const EdgeInsets.all(10),
          //         child: _suffixIcon,
          //       ),
          //     ),
          //   ),
          // ),
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
      _scrollToBottom();
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
              maxLines: 10,
              color: isMyMessage ? Colors.white : Colors.black,
              toggleColor: Colors.grey,
            ),
            TimeWidget(
              timestamp: message.timestamp,
              isMyMessage: isMyMessage,
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

    if (message.type == MessageType.product) {
      messageWidget = NewProductCard(
        product: message.product!,
        elevation: 0,
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isMyMessage ? 20 : 5),
          topRight: Radius.circular(isMyMessage ? 5 : 20),
          bottomLeft: const Radius.circular(20),
          bottomRight: const Radius.circular(20),
        ),
        color: isMyMessage ? Colors.blue[700] : Colors.white,
      ),
      child: messageWidget,
    );
  }
}

class TimeWidget extends StatelessWidget {
  const TimeWidget({
    super.key,
    required this.timestamp,
    required this.isMyMessage,
  });

  final DateTime timestamp;
  final bool isMyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Text(
        Compute.dateFormat(timestamp),
        style: TextStyle(
          color: isMyMessage ? Colors.white : Colors.grey,
          height: 0,
          fontSize: 12,
        ),
      ),
    );
  }
}

class WaveWidget extends StatefulWidget {
  const WaveWidget({super.key, required this.recorder});
  final AudioRecorder recorder;
  @override
  State<WaveWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 100,
      child: StreamBuilder<Amplitude>(
        stream: widget.recorder.getAmplitude().asStream(),
        builder: (BuildContext context, AsyncSnapshot<Amplitude> snapshot) {
          if (snapshot.hasData) {
            print('Amplitude: ${snapshot.data!.current}');
            return LinearProgressIndicator(
              value: snapshot.data!.current.abs() / 100,
              backgroundColor: Colors.grey,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
