import 'package:flutter_tts/flutter_tts.dart';

/// 🎧 Uyku Modu - Audio Study Service
/// 
/// Bu servis sayesinde öğrenci otobüste, yatağında veya yürürken
/// ekrana bakmadan ders çalışabilir.
/// 
/// Özellikler:
/// - Türkçe TTS (Text-to-Speech)
/// - Soru okur → 3 saniye düşünme → Cevap okur
/// - Playlist modu (tüm destenin sırayla okunması)
/// - Arka planda çalışma (ekran kapalı)

class AudioStudyService {
  static final AudioStudyService _instance = AudioStudyService._internal();
  factory AudioStudyService() => _instance;
  AudioStudyService._internal();
  
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentIndex = 0;
  
  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentIndex => _currentIndex;
  
  // Callback'ler
  Function(int)? onIndexChanged;
  Function(AudioState)? onStateChanged;
  
  /// Ses motorunu başlat ve ayarla
  Future<void> init() async {
    await _flutterTts.setLanguage("tr-TR"); // Türkçe konuşsun
    await _flutterTts.setSpeechRate(0.45);  // Tane tane okusun (0.4-0.5 ideal)
    await _flutterTts.setVolume(1.0);       // Maksimum ses
    await _flutterTts.setPitch(1.0);        // Normal ton
    
    // iOS özel ayarlar (arka planda çalışma)
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
    
    // Completion callback
    _flutterTts.setCompletionHandler(() {
      // Konuşma tamamlandı
    });
  }
  
  /// 🎵 Playlist Başlat (Tüm Desteri Sırayla Oku)
  /// 
  /// [cards] - Soru-cevap listesi (Map<String, String> { 'soru': '...', 'cevap': '...' })
  /// [onIndexChanged] - Her kart değiştiğinde çağrılır
  Future<void> startPlaylist(
    List<Map<String, String>> cards, {
    Function(int)? onIndexChanged,
    Function(AudioState)? onStateChanged,
    int dusunmeSuresiSaniye = 3,
    int kartArasiSaniye = 1,
  }) async {
    if (cards.isEmpty) return;
    
    _isPlaying = true;
    _isPaused = false;
    this.onIndexChanged = onIndexChanged;
    this.onStateChanged = onStateChanged;
    
    _notifyState(AudioState.playing);
    
    for (int i = 0; i < cards.length; i++) {
      if (!_isPlaying) break;
      
      // Pause durumunda bekle
      while (_isPaused && _isPlaying) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (!_isPlaying) break;
      
      _currentIndex = i;
      onIndexChanged?.call(i);
      
      final card = cards[i];
      final soru = card['soru'] ?? card['front'] ?? '';
      final cevap = card['cevap'] ?? card['back'] ?? '';
      
      // 1️⃣ SORUYU OKU
      _notifyState(AudioState.readingQuestion);
      await _speak("Soru ${i + 1}: $soru");
      
      if (!_isPlaying) break;
      
      // 2️⃣ DÜŞÜNME PAYI (SESSİZLİK)
      _notifyState(AudioState.thinking);
      await Future.delayed(Duration(seconds: dusunmeSuresiSaniye));
      
      if (!_isPlaying) break;
      
      // 3️⃣ CEVABI OKU
      _notifyState(AudioState.readingAnswer);
      await _speak("Cevap: $cevap");
      
      if (!_isPlaying) break;
      
      // 4️⃣ SONRAKİ KARTA GEÇMEDEN KISA ES
      await Future.delayed(Duration(seconds: kartArasiSaniye));
    }
    
    // Playlist bitti
    _isPlaying = false;
    _isPaused = false;
    _notifyState(AudioState.stopped);
  }
  
  /// Tek bir kartı oku (soru + düşünme + cevap)
  Future<void> readSingleCard(String soru, String cevap, {int dusunmeSuresi = 3}) async {
    _isPlaying = true;
    _notifyState(AudioState.readingQuestion);
    
    await _speak("Soru: $soru");
    
    if (!_isPlaying) return;
    
    _notifyState(AudioState.thinking);
    await Future.delayed(Duration(seconds: dusunmeSuresi));
    
    if (!_isPlaying) return;
    
    _notifyState(AudioState.readingAnswer);
    await _speak("Cevap: $cevap");
    
    _isPlaying = false;
    _notifyState(AudioState.stopped);
  }
  
  /// Sadece metni oku (tek cümle)
  Future<void> speakText(String text) async {
    if (text.isEmpty) return;
    await _speak(text);
  }
  
  /// TTS ile konuşma (internal)
  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await _flutterTts.speak(text);
    await _flutterTts.awaitSpeakCompletion(true); // Bitene kadar bekle
  }
  
  /// ⏸️ Duraklat
  void pause() {
    _isPaused = true;
    _flutterTts.pause();
    _notifyState(AudioState.paused);
  }
  
  /// ▶️ Devam Et
  void resume() {
    _isPaused = false;
    _notifyState(AudioState.playing);
  }
  
  /// ⏹️ Durdur
  Future<void> stop() async {
    _isPlaying = false;
    _isPaused = false;
    await _flutterTts.stop();
    _notifyState(AudioState.stopped);
  }
  
  /// ⏭️ Sonraki Karta Atla
  void skipToNext() {
    _flutterTts.stop();
    // Playlist döngüsü otomatik sonrakine geçecek
  }
  
  /// State bildirimi
  void _notifyState(AudioState state) {
    onStateChanged?.call(state);
  }
  
  /// Dispose
  Future<void> dispose() async {
    await stop();
  }
}

/// Audio durumları
enum AudioState {
  stopped,        // Çalmıyor
  playing,        // Oynatılıyor
  paused,         // Duraklatıldı
  readingQuestion, // Soru okunuyor
  thinking,       // Düşünme süresi
  readingAnswer,  // Cevap okunuyor
}

/// Audio durum uzantıları
extension AudioStateExtension on AudioState {
  String get label {
    switch (this) {
      case AudioState.stopped: return "Durduruldu";
      case AudioState.playing: return "Oynatılıyor";
      case AudioState.paused: return "Duraklatıldı";
      case AudioState.readingQuestion: return "Soru okunuyor...";
      case AudioState.thinking: return "Düşünme süresi...";
      case AudioState.readingAnswer: return "Cevap okunuyor...";
    }
  }
  
  String get emoji {
    switch (this) {
      case AudioState.stopped: return "⏹️";
      case AudioState.playing: return "▶️";
      case AudioState.paused: return "⏸️";
      case AudioState.readingQuestion: return "❓";
      case AudioState.thinking: return "🤔";
      case AudioState.readingAnswer: return "✅";
    }
  }
}
