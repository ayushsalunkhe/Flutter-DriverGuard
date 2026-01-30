import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // Cache the player
  AudioService() {
    _player.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> playAlert() async {
    print("AudioService: Requesting Play");
    if (_player.state == PlayerState.playing) return;
    try {
      print("AudioService: Playing assets/sounds/alarm.mp3");
      await _player.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      print("Audio Error: $e");
    }
  }

  Future<void> stopAlert() async {
    print("AudioService: Stopping");
    await _player.stop();
  }
}
