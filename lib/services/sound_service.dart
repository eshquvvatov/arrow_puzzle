import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'storage.dart';

/// Qisqa o'yin tovushlari. 3 pleyerlik pool — tez ketma-ket tap'larda
/// tovushlar bir-birini kesib yubormasligi uchun.
class SoundService extends ChangeNotifier {
  final List<AudioPlayer> _pool = [];
  int _next = 0;
  bool _enabled = true;

  bool get enabled => _enabled;

  Future<void> init() async {
    _enabled = Storage.soundOn;
    for (var i = 0; i < 3; i++) {
      final p = AudioPlayer();
      await p.setPlayerMode(PlayerMode.lowLatency);
      _pool.add(p);
    }
  }

  void setEnabled(bool v) {
    _enabled = v;
    Storage.setSoundOn(v);
    notifyListeners();
  }

  void _play(String asset) {
    if (!_enabled || _pool.isEmpty) return;
    final p = _pool[_next];
    _next = (_next + 1) % _pool.length;
    // Simulyator/veb'da audio xatolari o'yinni to'xtatmasin.
    p.play(AssetSource('audio/$asset')).catchError((_) {});
  }

  void tap() => _play('tap.wav');
  void whoosh() => _play('whoosh.wav');
  void thud() => _play('thud.wav');
  void win() => _play('win.wav');
}

final soundService = SoundService();
