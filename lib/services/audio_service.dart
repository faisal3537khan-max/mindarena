import 'package:audioplayers/audioplayers.dart';

import '../models/models.dart';

class AudioService {
  AudioService();

  final AudioPlayer _sfx = AudioPlayer();
  final AudioPlayer _music = AudioPlayer();
  bool music = true;
  bool sfx = true;
  double musicVol = 0.16;
  double sfxVol = 0.7;

  Future<void> init() async {
    try {
      await _sfx.setPlayerMode(PlayerMode.lowLatency);
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(musicVol);
    } catch (_) {}
  }

  void apply(PlayerProfile p) {
    music = p.music;
    sfx = p.sfx;
    musicVol = (p.musicVol.clamp(0, 100) / 100) * 0.22;
    sfxVol = p.sfxVol.clamp(0, 100) / 100;
    _music.setVolume(music ? musicVol : 0);
    if (!music) {
      _music.stop();
    }
  }

  Future<void> playSfx(String name) async {
    if (!sfx) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('sfx/$name.wav'), volume: sfxVol);
    } catch (_) {}
  }

  Future<void> startMusic() async {
    if (!music) return;
    try {
      await _music.play(AssetSource('sfx/music.wav'), volume: musicVol);
    } catch (_) {}
  }

  Future<void> stopMusic() => _music.stop();

  Future<void> dispose() async {
    await _sfx.dispose();
    await _music.dispose();
  }
}
