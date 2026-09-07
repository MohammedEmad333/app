import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around audioplayers for short sound effects (correct / wrong /
/// celebration). Effects are loaded from bundled assets when present and fail
/// silently if an asset is missing, so the demo runs even without audio files.
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _sfxPlayer = AudioPlayer(playerId: 'sfx');

  Future<void> _play(String asset) async {
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('AudioService: could not play $asset ($e)');
    }
  }

  Future<void> correct() => _play('audio/correct.wav');
  Future<void> wrong() => _play('audio/wrong.wav');
  Future<void> celebrate() => _play('audio/celebrate.wav');
  Future<void> tap() => _play('audio/tap.wav');

  Future<void> dispose() async => _sfxPlayer.dispose();
}
