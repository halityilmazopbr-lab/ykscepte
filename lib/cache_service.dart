import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Soru-Cevap Önbellekleme Servisi
/// 
/// Aynı soruların tekrar tekrar AI'ya sorulmasını önler.
/// Zamanla devasa bir "Soru-Cevap Kütüphanesi" oluşur.
class CacheService {
  static late SharedPreferences _prefs;
  static const String _cacheKey = 'ai_cache';
  static const int _maxCacheSize = 500; // Maksimum cache boyutu
  
  static Map<String, CacheEntry> _memoryCache = {};
  static bool _initialized = false;

  /// Servisi başlat
  static Future<void> init() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    await _loadFromDisk();
    _initialized = true;
    debugPrint('CacheService: Initialized with ${_memoryCache.length} entries');
  }

  /// Soru için cache'de cevap var mı?
  static String? get(String soru) {
    final key = _generateKey(soru);
    final entry = _memoryCache[key];
    
    if (entry != null) {
      // 7 günden eski cache'leri geçersiz say
      if (DateTime.now().difference(entry.timestamp).inDays < 7) {
        entry.hitCount++;
        debugPrint('CacheService: HIT for "${soru.substring(0, soru.length.clamp(0, 30))}..."');
        return entry.cevap;
      } else {
        // Eski entry'yi sil
        _memoryCache.remove(key);
      }
    }
    
    debugPrint('CacheService: MISS for "${soru.substring(0, soru.length.clamp(0, 30))}..."');
    return null;
  }

  /// Yeni soru-cevap çiftini cache'e ekle
  static Future<void> set(String soru, String cevap) async {
    // Çok kısa cevapları cache'leme (hata olabilir)
    if (cevap.length < 20) return;
    
    final key = _generateKey(soru);
    
    // Cache doluysa en az kullanılanı sil
    if (_memoryCache.length >= _maxCacheSize) {
      _evictLeastUsed();
    }
    
    _memoryCache[key] = CacheEntry(
      soru: soru,
      cevap: cevap,
      timestamp: DateTime.now(),
      hitCount: 0,
    );
    
    await _saveToDisk();
    debugPrint('CacheService: SAVED "${soru.substring(0, soru.length.clamp(0, 30))}..."');
  }

  /// Soru metninden benzersiz key oluştur
  static String _generateKey(String soru) {
    // Küçük harf, trim, hash
    final normalized = soru.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    return normalized.hashCode.toString();
  }

  /// En az kullanılan cache entry'sini sil
  static void _evictLeastUsed() {
    if (_memoryCache.isEmpty) return;
    
    String? leastUsedKey;
    int minHits = 999999;
    
    _memoryCache.forEach((key, entry) {
      if (entry.hitCount < minHits) {
        minHits = entry.hitCount;
        leastUsedKey = key;
      }
    });
    
    if (leastUsedKey != null) {
      _memoryCache.remove(leastUsedKey);
      debugPrint('CacheService: Evicted least used entry');
    }
  }

  /// Disk'ten cache yükle
  static Future<void> _loadFromDisk() async {
    try {
      final jsonStr = _prefs.getString(_cacheKey);
      if (jsonStr != null) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        data.forEach((key, value) {
          _memoryCache[key] = CacheEntry.fromJson(value);
        });
      }
    } catch (e) {
      debugPrint('CacheService: Load error - $e');
      _memoryCache = {};
    }
  }

  /// Cache'i diske kaydet
  static Future<void> _saveToDisk() async {
    try {
      final Map<String, dynamic> data = {};
      _memoryCache.forEach((key, entry) {
        data[key] = entry.toJson();
      });
      await _prefs.setString(_cacheKey, jsonEncode(data));
    } catch (e) {
      debugPrint('CacheService: Save error - $e');
    }
  }

  /// Cache'i temizle
  static Future<void> clear() async {
    _memoryCache.clear();
    await _prefs.remove(_cacheKey);
    debugPrint('CacheService: Cleared');
  }

  /// Cache istatistikleri
  static Map<String, dynamic> getStats() {
    return {
      'totalEntries': _memoryCache.length,
      'maxSize': _maxCacheSize,
    };
  }
}

/// Cache girdisi
class CacheEntry {
  final String soru;
  final String cevap;
  final DateTime timestamp;
  int hitCount;

  CacheEntry({
    required this.soru,
    required this.cevap,
    required this.timestamp,
    this.hitCount = 0,
  });

  Map<String, dynamic> toJson() => {
    'soru': soru,
    'cevap': cevap,
    'timestamp': timestamp.toIso8601String(),
    'hitCount': hitCount,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    soru: json['soru'],
    cevap: json['cevap'],
    timestamp: DateTime.parse(json['timestamp']),
    hitCount: json['hitCount'] ?? 0,
  );
}
