import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speakGreeting(bool isFrench) async {
    String language = isFrench ? "fr-FR" : "en-US";
    await _flutterTts.setLanguage(language);
  }

  Future<void> speakRfidCode(String rfidCode, bool isFrench) async {
    String language = isFrench ? "fr-FR" : "en-US";
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak("Le code RFID scanné est $rfidCode");
  }

  Future<void> speakAttendance(String text, bool isFrench) async {
    String language = isFrench ? "fr-FR" : "en-US";
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }
}