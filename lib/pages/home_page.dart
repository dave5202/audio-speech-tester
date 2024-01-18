import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  double _latency = 0;
  DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {
    });
  }

  void _startListening() async {
    setState(() {
      _startTime = DateTime.now();
    });
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
      _calculateLatency();
    });
  }

  void _calculateLatency() {
    if (_startTime != null) {
      DateTime endTime = DateTime.now();
      Duration latency = endTime.difference(_startTime);
      setState(() {
        _latency = latency.inMilliseconds.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(
      backgroundColor: Colors.blue,
      centerTitle: true,
      title: Text(
        "Speech Recognition Tester",
        style: TextStyle(
          color: Colors.white,
          fontFamily: "Arial",
        ), 
      ),
    ),
    body: Center(
      child: Column(
        children: [
          Container(
            child: Text(_speechToText.isListening ? 
            "Listening..." 
            : _speechEnabled ? 
            "Tap the microphone to start listening..." : "Speech not available",
            style: TextStyle(fontSize: 20.0),
            ) ,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                )
              )
            ),
            if (_speechToText.isNotListening && _confidenceLevel > 0) 
            Padding(
              padding: const EdgeInsets.only(
                bottom: 300,
              ),
              child: Column( 
                children: [
                  Text(
                    "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                ),
                  ),
                  Text(
                    "Latency: ${_latency}ms",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w200,
                ),
                  )
                ]
                
              ),
            )
          ],
          ),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: 
        _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue,
        ),
    );
  }
}
