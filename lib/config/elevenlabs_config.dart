/// ElevenLabs credentials — pass at build/run time:
/// `flutter run --dart-define=ELEVENLABS_API_KEY=sk_... --dart-define=ELEVENLABS_VOICE_ID=...`
class ElevenLabsConfig {
  ElevenLabsConfig._();

  static const apiKey = String.fromEnvironment('ELEVENLABS_API_KEY');

  /// Default multilingual voice (override with ELEVENLABS_VOICE_ID).
  /// Pick a Japanese-friendly voice in the [ElevenLabs dashboard](https://elevenlabs.io/app/home).
  static const voiceId = String.fromEnvironment(
    'ELEVENLABS_VOICE_ID',
    defaultValue: 'pNInz6obpgDQGcFmaJgB',
  );

  static const modelId = 'eleven_multilingual_v2';
  /// Lower bitrate reduces first-response latency on mobile networks.
  static const outputFormat = 'mp3_22050_32';

  /// Speech-to-text (Scribe) model used by the speaking games.
  static const sttModelId = 'scribe_v1';

  static bool get isConfigured => apiKey.isNotEmpty;
}
