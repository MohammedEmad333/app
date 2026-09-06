import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Wraps speech_to_text for the speech-recognition question type. Handles
/// permission/availability gracefully so unsupported platforms (e.g. web
/// without mic access) degrade instead of crashing.
class SpeechService {
  SpeechService._();
  static final SpeechService instance = SpeechService._();

  final SpeechToText _speech = SpeechToText();
  bool _available = false;
  bool _initialised = false;

  bool get isListening => _speech.isListening;

  Future<bool> init() async {
    if (_initialised) return _available;
    try {
      _available = await _speech.initialize(
        onError: (e) => debugPrint('SpeechService error: ${e.errorMsg}'),
        onStatus: (s) => debugPrint('SpeechService status: $s'),
      );
    } catch (e) {
      debugPrint('SpeechService: init failed ($e)');
      _available = false;
    }
    _initialised = true;
    return _available;
  }

  /// Starts listening and streams partial + final results to [onResult].
  Future<bool> listen({
    required void Function(String words, bool isFinal) onResult,
  }) async {
    final ready = await init();
    if (!ready) return false;
    try {
      await _speech.listen(
        listenFor: const Duration(seconds: 6),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_US',
        onResult: (r) => onResult(r.recognizedWords, r.finalResult),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('SpeechService: listen failed ($e)');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }

  /// Loose match: case-insensitive, ignores punctuation/extra spaces so kids'
  /// pronunciation passes even if the recognizer is imperfect.
  static bool matches(String spoken, String expected) {
    String norm(String s) => s
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final a = norm(spoken);
    final b = norm(expected);
    if (a.isEmpty) return false;
    return a == b || a.contains(b) || b.contains(a);
  }
}
