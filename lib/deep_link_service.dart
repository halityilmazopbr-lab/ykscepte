/// Deep Link Servisi
/// Viral Growth Loop için gelen linkleri dinler ve işler
/// 
/// Link formatları:
/// - ykscepte://soru/{soruId} - Custom scheme
/// - https://ykscepte.web.app/soru.html?id={soruId} - Universal link

import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Global deep link servisi
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  
  /// Bekleyen soru ID (uygulama açılırken gelen link için)
  String? pendingSoruId;
  
  /// Link geldiğinde çağrılacak callback
  Function(String soruId)? onSoruLinkReceived;

  /// Deep link dinleyicisini başlat
  Future<void> initialize() async {
    debugPrint('🔗 DeepLinkService: Başlatılıyor...');
    
    // Başlangıç linkini kontrol et (uygulama kapalıyken tıklanan link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 Başlangıç linki: $initialUri');
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('🔗 Başlangıç linki hatası: $e');
    }

    // Gelen linkleri dinle (uygulama açıkken)
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        debugPrint('🔗 Gelen link: $uri');
        _handleUri(uri);
      },
      onError: (e) {
        debugPrint('🔗 Link stream hatası: $e');
      },
    );
  }

  /// Gelen URI'yi işle
  void _handleUri(Uri uri) {
    String? soruId;

    // Custom scheme: ykscepte://soru/ABC123
    if (uri.scheme == 'ykscepte') {
      if (uri.pathSegments.isNotEmpty) {
        if (uri.pathSegments.first == 'soru' && uri.pathSegments.length > 1) {
          soruId = uri.pathSegments[1];
        } else {
          soruId = uri.pathSegments.first;
        }
      }
    }
    // HTTPS link: https://ykscepte.web.app/soru.html?id=ABC123
    else if (uri.host.contains('ykscepte')) {
      soruId = uri.queryParameters['id'];
    }

    if (soruId != null && soruId.isNotEmpty) {
      debugPrint('🔗 Soru ID bulundu: $soruId');
      
      if (onSoruLinkReceived != null) {
        onSoruLinkReceived!(soruId);
      } else {
        // Callback henüz ayarlanmadıysa beklet
        pendingSoruId = soruId;
      }
    }
  }

  /// Bekleyen soru varsa işle
  void processPendingLink() {
    if (pendingSoruId != null && onSoruLinkReceived != null) {
      onSoruLinkReceived!(pendingSoruId!);
      pendingSoruId = null;
    }
  }

  /// Servisi kapat
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }
}

/// Paylaşım linki oluştur
String createShareLink(String soruId) {
  return 'https://ykscepte.web.app/soru.html?id=$soruId';
}

/// Challenge mesajı oluştur
String createChallengeMessage({
  required String gonderenAd,
  required String ders,
  required String konu,
  required String link,
}) {
  return '''
🔥 $gonderenAd sana meydan okuyor!

📚 $ders - $konu sorusunu çözebilir misin?

Cevabı görmek ve çözümü denemek için tıkla:
👇👇
$link

📲 YKS Cepte ile sınava hazırlan!
''';
}
