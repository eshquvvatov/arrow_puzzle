// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// 16-bit PCM, mono, 44100 Hz WAV writer
const int sampleRate = 44100;
const int bitsPerSample = 16;
const int numChannels = 1;
const double maxAmplitude = 0.5;

/// RIFF/WAVE header + PCM data
List<int> buildWav(List<double> samples) {
  final numSamples = samples.length;
  final dataSize = numSamples * 2; // 16-bit = 2 bytes per sample
  final fileSize = 36 + dataSize;

  final bytes = BytesBuilder();

  void writeStr(String s) => bytes.add(s.codeUnits);
  void writeU32LE(int v) {
    bytes.add([v & 0xff, (v >> 8) & 0xff, (v >> 16) & 0xff, (v >> 24) & 0xff]);
  }
  void writeU16LE(int v) {
    bytes.add([v & 0xff, (v >> 8) & 0xff]);
  }

  // RIFF chunk
  writeStr('RIFF');
  writeU32LE(fileSize);
  writeStr('WAVE');

  // fmt sub-chunk
  writeStr('fmt ');
  writeU32LE(16); // sub-chunk size for PCM
  writeU16LE(1);  // PCM format
  writeU16LE(numChannels);
  writeU32LE(sampleRate);
  writeU32LE(sampleRate * numChannels * bitsPerSample ~/ 8); // byte rate
  writeU16LE(numChannels * bitsPerSample ~/ 8); // block align
  writeU16LE(bitsPerSample);

  // data sub-chunk
  writeStr('data');
  writeU32LE(dataSize);

  // PCM samples
  for (final s in samples) {
    final clamped = s.clamp(-1.0, 1.0);
    final v = (clamped * 32767).round().clamp(-32768, 32767);
    writeU16LE(v & 0xffff);
  }

  return bytes.toBytes();
}

/// Linear fade from [start] to [end] over [len] samples.
double fade(int i, int len, double start, double end) {
  if (len <= 0) return end;
  final t = (i / (len - 1)).clamp(0.0, 1.0);
  return start + (end - start) * t;
}

/// tap.wav — 60ms, 880 Hz sine, 5ms attack + exponential decay
List<double> generateTap() {
  final totalSamples = (0.060 * sampleRate).round();
  final attackSamples = (0.005 * sampleRate).round();
  final samples = <double>[];

  for (var i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    double env;
    if (i < attackSamples) {
      env = i / attackSamples;
    } else {
      // exponential decay from attack end to near-zero
      final decayT = (i - attackSamples) / (totalSamples - attackSamples);
      env = exp(-5.0 * decayT);
    }
    samples.add(maxAmplitude * env * sin(2 * pi * 880 * t));
  }
  return samples;
}

/// whoosh.wav — 220ms, freq sweep 400→900 Hz sine
/// envelope: 10ms attack, last 80ms fade-out
List<double> generateWhoosh() {
  final totalSamples = (0.220 * sampleRate).round();
  final attackSamples = (0.010 * sampleRate).round();
  final fadeOutStart = (0.140 * sampleRate).round();
  final samples = <double>[];
  double phase = 0.0;

  for (var i = 0; i < totalSamples; i++) {
    final freqT = i / (totalSamples - 1);
    final freq = 400.0 + (900.0 - 400.0) * freqT;

    double env;
    if (i < attackSamples) {
      env = i / attackSamples;
    } else if (i >= fadeOutStart) {
      final fadeLen = totalSamples - fadeOutStart;
      env = 1.0 - (i - fadeOutStart) / fadeLen;
    } else {
      env = 1.0;
    }

    samples.add(maxAmplitude * env * sin(phase));
    phase += 2 * pi * freq / sampleRate;
    if (phase > 2 * pi) phase -= 2 * pi;
  }
  return samples;
}

/// thud.wav — 150ms, 150 Hz triangle wave + tez decay
List<double> generateThud() {
  final totalSamples = (0.150 * sampleRate).round();
  final samples = <double>[];
  const freq = 150.0;

  for (var i = 0; i < totalSamples; i++) {
    final t = i / sampleRate;
    // triangle wave: period-based
    final period = 1.0 / freq;
    final phase = (t % period) / period; // 0..1
    final triangle = phase < 0.5 ? 4 * phase - 1 : 3 - 4 * phase;
    // exponential decay
    final decayT = i / totalSamples;
    final env = exp(-6.0 * decayT);
    samples.add(maxAmplitude * env * triangle);
  }
  return samples;
}

/// win.wav — 650ms arpejio: C5→E5→G5→C6, each ~160ms, slight overlap
List<double> generateWin() {
  const notes = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
  const noteDuration = 0.160; // seconds per note
  const overlapFactor = 0.20; // 20% overlap

  final totalDuration = noteDuration * notes.length * (1 - overlapFactor) +
      noteDuration * overlapFactor;
  final totalSamples = (totalDuration * sampleRate).ceil();
  final buffer = List<double>.filled(totalSamples, 0.0);

  for (var n = 0; n < notes.length; n++) {
    final freq = notes[n];
    final startSec = n * noteDuration * (1 - overlapFactor);
    final startIdx = (startSec * sampleRate).round();
    final noteSamples = (noteDuration * sampleRate).round();
    final attackLen = (0.010 * sampleRate).round();
    final releaseLen = (0.040 * sampleRate).round();

    for (var i = 0; i < noteSamples; i++) {
      final globalIdx = startIdx + i;
      if (globalIdx >= totalSamples) break;

      double env;
      if (i < attackLen) {
        env = i / attackLen;
      } else if (i >= noteSamples - releaseLen) {
        env = (noteSamples - i) / releaseLen;
      } else {
        env = 1.0;
      }

      final t = i / sampleRate;
      buffer[globalIdx] += maxAmplitude * env * sin(2 * pi * freq * t);
    }
  }

  // Normalize to avoid clipping if overlapping notes exceed 1.0
  double peak = 0;
  for (final v in buffer) {
    if (v.abs() > peak) peak = v.abs();
  }
  if (peak > 1.0) {
    for (var i = 0; i < buffer.length; i++) {
      buffer[i] /= peak;
    }
  }

  return buffer;
}

void writeWav(String path, List<double> samples) {
  final data = buildWav(samples);
  File(path).writeAsBytesSync(data);
  final kb = (data.length / 1024).toStringAsFixed(1);
  print('  Wrote $path ($kb KB, ${samples.length} samples)');
}

void main() {
  final outDir = Directory('assets/audio');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  print('Generating SFX into assets/audio/ ...');
  writeWav('assets/audio/tap.wav', generateTap());
  writeWav('assets/audio/whoosh.wav', generateWhoosh());
  writeWav('assets/audio/thud.wav', generateThud());
  writeWav('assets/audio/win.wav', generateWin());
  print('Done.');
}
