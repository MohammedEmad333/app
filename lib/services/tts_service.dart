import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks English words/sentences aloud for audio-listening questions and
/// pronunciation playback, using the device's built-in TTS engine.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42); // slower, clearer for kids
      await _tts.setPitch(1.1);
      await _tts.setVolume(1.0);
      _configured = true;
    } catch (e) {
      debugPrint('TtsService: configure failed ($e)');
    }
  }

  Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _ensureConfigured();
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TtsService: speak failed ($e)');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}
