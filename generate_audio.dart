import 'dart:io';
import 'dart:convert';

void main() {
  final file = File('assets/sounds/alarm.mp3');
  if (!file.existsSync()) {
    print("Generating alarm.mp3...");
    // Minimal valid MP3 frame (silence/blip) is hard to hand-code but a WAV is easier.
    // However, the provider asks for mp3. AudioPlayers plays wav too.
    // Let's rewrite the file extension in code to .wav?
    // Or just write a WAV content to alarm.mp3 (most players handle header-sniffing).

    // This is a base64 of a short "beep" WAV file.
    const base64Wav =
        "UklGRl9vT19XQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YU"; // Truncated... this won't work if invalid.

    // Better idea: Create a valid RIFF WAVE header + some square wave data.

    final header = <int>[
      0x52, 0x49, 0x46, 0x46, // RIFF
      0x24, 0x08, 0x00, 0x00, // Size (dummy)
      0x57, 0x41, 0x56, 0x45, // WAVE
      0x66, 0x6D, 0x74, 0x20, // fmt
      0x10, 0x00, 0x00, 0x00, // Subchunk1Size (16)
      0x01, 0x00, // AudioFormat (1 = PCM)
      0x01, 0x00, // NumChannels (1)
      0x44, 0xAC, 0x00, 0x00, // SampleRate (44100)
      0x44, 0xAC, 0x00, 0x00, // ByteRate
      0x01, 0x00, // BlockAlign
      0x08, 0x00, // BitsPerSample (8)
      0x64, 0x61, 0x74, 0x61, // data
      0x00, 0x08, 0x00, 0x00 // Subchunk2Size (2048 bytes of data)
    ];

    final data = <int>[];
    for (int i = 0; i < 2048; i++) {
      // Square wave
      data.add((i % 100 < 50) ? 0xFF : 0x00);
    }

    final bytes = [...header, ...data];
    file.writeAsBytesSync(bytes);
    print("Created assets/sounds/alarm.mp3 (actually a WAV)");
  }
}
