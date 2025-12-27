/// 🧠 ÖSYM Tarzı AI Flash Kart Servisi
/// Master Prompt ile sınav odaklı, pedagojik flashcard üretimi
/// 
/// Özellikler:
/// - ÖSYM Soru Hazırlama Komitesi perspektifi
/// - MEB Müfredatına uygun içerik
/// - İpucu ve Motivasyon notları
/// - Önem derecesi (Her Yıl Çıkar, Sık Çıkar, Nadiren Çıkar)

import 'dart:convert';
import '../gemini_service.dart';

/// Flash Kart Modeli (Zenginleştirilmiş)
class AIFlashCard {
  final String id;
  final String question;        // Soru
  final String answer;          // Cevap
  final String hint;            // İpucu (bilmeyince görünür)
  final String motivation;      // Motivasyon notu (cevaptan sonra)
  final String importance;      // Önem derecesi
  final String topic;           // Konu
  final String category;        // Kategori (TYT/AYT/YDT)
  
  // Leitner Sistemi
  int box;                      // Kutu (1-3)
  DateTime nextReview;          // Sonraki tekrar tarihi

  AIFlashCard({
    required this.id,
    required this.question,
    required this.answer,
    required this.hint,
    required this.motivation,
    required this.importance,
    required this.topic,
    this.category = 'TYT',
    this.box = 1,
    DateTime? nextReview,
  }) : nextReview = nextReview ?? DateTime.now();

  /// Önem derecesine göre emoji
  String get importanceEmoji {
    switch (importance) {
      case 'Her Yıl Çıkar':
        return '🔥';
      case 'Sık Çıkar':
        return '⭐';
      case 'Nadiren Çıkar':
        return '💡';
      default:
        return '📝';
    }
  }

  /// Önem derecesine göre renk
  int get importanceColor {
    switch (importance) {
      case 'Her Yıl Çıkar':
        return 0xFFFF6B6B; // Kırmızı
      case 'Sık Çıkar':
        return 0xFFFFD93D; // Sarı
      case 'Nadiren Çıkar':
        return 0xFF6BCB77; // Yeşil
      default:
        return 0xFF4D96FF; // Mavi
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'question': question,
    'answer': answer,
    'hint': hint,
    'motivation': motivation,
    'importance': importance,
    'topic': topic,
    'category': category,
    'box': box,
    'nextReview': nextReview.toIso8601String(),
  };

  factory AIFlashCard.fromJson(Map<String, dynamic> json) => AIFlashCard(
    id: json['id'] ?? '',
    question: json['question'] ?? json['front'] ?? '',
    answer: json['answer'] ?? json['back'] ?? '',
    hint: json['hint'] ?? 'Bu konuyu tekrar gözden geçir.',
    motivation: json['motivation'] ?? 'Her soru seni sınava bir adım daha yaklaştırıyor!',
    importance: json['importance'] ?? 'Sık Çıkar',
    topic: json['topic'] ?? 'Genel',
    category: json['category'] ?? 'TYT',
    box: json['box'] ?? 1,
    nextReview: json['nextReview'] != null 
        ? DateTime.parse(json['nextReview']) 
        : DateTime.now(),
  );
}

/// AI Flash Kart Üretim Servisi
class AIFlashcardService {
  
  /// 🎯 MASTER PROMPT - ÖSYM Uzmanı Kimliği
  static const String _masterPrompt = '''
Sen, ÖSYM Soru Hazırlama Komitesi'nde 20 yıl görev yapmış, emekli bir profesör ve aynı zamanda öğrencilere ilham veren bir koçsun.

🎯 GÖREVİN:
Verilen konuda ÖSYM formatına uygun, öğrencinin aklında kalacak ve sınavda karşısına çıkma ihtimali yüksek olan bilgi kartları (flashcard) üret.

📚 TEMEL KURALLAR:
1. SADECE MEB Müfredatı ve ÖSYM çıkmış soru tarzına uygun ol.
2. Wikipedia veya gereksiz ansiklopedik bilgilerden KAÇIN. Net ve öz ol.
3. Tarihleri, formülleri, isimleri ve kavramları DOĞRU yaz. Hata YASAK.
4. Her kartta pedagojik bir yaklaşım olsun: İpucu ile düşündür, Motivasyonla ödüllendir.

📋 ZORUNLU JSON FORMATI (Başka format KABUL EDİLMEZ):
[
  {
    "question": "ÖSYM tarzı soru metni",
    "answer": "Net ve doğru cevap",
    "hint": "Cevabı bulamazsa yardımcı olacak ipucu (1 cümle)",
    "motivation": "Öğrenciyi motive eden kısa not (1 cümle)",
    "importance": "Her Yıl Çıkar | Sık Çıkar | Nadiren Çıkar"
  }
]

🔥 ÖNEM DERECELERİ:
- "Her Yıl Çıkar": Son 5 yılda en az 3 kez çıkmış konular
- "Sık Çıkar": Son 5 yılda 1-2 kez çıkmış konular
- "Nadiren Çıkar": Müfredatta var ama seyrek sorulan konular

💡 İPUCU YAZMA REHBERİ:
- Doğrudan cevabı VERMEYECEKSİN.
- Hafızada çağrışım yapacak bir anahtar ver. Örn: "Osmanlı'nın kuruluş yılını düşün, 1 yüzyıl sonra..."

🚀 MOTİVASYON NOTU REHBERİ:
- Kısa, samimi ve cesaretlendirici ol.
- Örn: "Bu soruyu bilenler sınavda 2 dakika kazanıyor!" veya "Tarih dersinin yüzde 10'u bu konudan çıkıyor!"

⚠️ KRİTİK:
- JSON formatından ASLA çıkma.
- Soru sayısı tam 10 olsun.
- Türkçe karakterleri doğru kullan.
''';

  /// 🚀 AI ile Zengin Flash Kart Deste Oluştur
  static Future<List<AIFlashCard>> generateDeck({
    required String topic,
    String category = 'TYT',
    int cardCount = 10,
  }) async {
    final userPrompt = '''
KONU: $topic
KATEGORİ: $category
KART SAYISI: $cardCount

Yukarıdaki konuda $cardCount adet ÖSYM tarzı bilgi kartı oluştur.
SADECE JSON dizisi döndür, başka hiçbir şey yazma.
''';

    try {
      // Master Prompt + User Prompt birlikte gönder
      final fullPrompt = '$_masterPrompt\n\n---\n\n$userPrompt';
      final response = await GravityAI.generateText(fullPrompt);
      
      // JSON'u parse et
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr);
        
        return parsed.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          
          return AIFlashCard(
            id: 'ai_${topic.hashCode}_$index',
            question: item['question'] ?? '',
            answer: item['answer'] ?? '',
            hint: item['hint'] ?? 'Bu konuyu tekrar gözden geçir.',
            motivation: item['motivation'] ?? 'Her soru seni hedefe yaklaştırıyor!',
            importance: item['importance'] ?? 'Sık Çıkar',
            topic: topic,
            category: category,
          );
        }).toList();
      } else {
        throw Exception('AI yanıtında geçerli JSON bulunamadı');
      }
    } catch (e) {
      throw Exception('Flash kart oluşturma hatası: $e');
    }
  }

  /// 📸 Paragraftan Flash Kart Oluştur (Paragraf Canavarı)
  static Future<List<AIFlashCard>> generateFromParagraph({
    required String paragraph,
    String category = 'TYT',
  }) async {
    final userPrompt = '''
AŞAĞIDAKİ METNİ ANALİZ ET VE 5 ADET FLASH KART OLUŞTUR:

"""
$paragraph
"""

KATEGORİ: $category
KART SAYISI: 5

Metindeki kritik bilgileri ÖSYM tarzı soru-cevap formatına çevir.
SADECE JSON dizisi döndür.
''';

    try {
      final fullPrompt = '$_masterPrompt\n\n---\n\n$userPrompt';
      final response = await GravityAI.generateText(fullPrompt);
      
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr);
        
        return parsed.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          
          return AIFlashCard(
            id: 'paragraph_${paragraph.hashCode}_$index',
            question: item['question'] ?? '',
            answer: item['answer'] ?? '',
            hint: item['hint'] ?? 'Metni tekrar oku.',
            motivation: item['motivation'] ?? 'Paragrafları anlamak sınavın yarısı!',
            importance: item['importance'] ?? 'Sık Çıkar',
            topic: 'Metin Analizi',
            category: category,
          );
        }).toList();
      } else {
        throw Exception('AI yanıtında geçerli JSON bulunamadı');
      }
    } catch (e) {
      throw Exception('Paragraf analizi hatası: $e');
    }
  }

  /// 🖼️ Görsellerden Flash Kart Oluştur (OCR + AI)
  static Future<List<AIFlashCard>> generateFromImage({
    required String extractedText,
    String category = 'TYT',
  }) async {
    // OCR ile çıkarılan metni paragraf analizine yönlendir
    return generateFromParagraph(
      paragraph: extractedText,
      category: category,
    );
  }

  /// 🔄 Eksik Konular İçin Akıllı Öneri
  static Future<List<AIFlashCard>> generateForWeakTopics({
    required List<String> weakTopics,
    String category = 'TYT',
  }) async {
    final topicsStr = weakTopics.take(3).join(', ');
    
    final userPrompt = '''
ZAYIF KONULAR: $topicsStr
KATEGORİ: $category
KART SAYISI: 10

Bu öğrenci yukarıdaki konularda zorlanıyor. 
Her konudan eşit sayıda, TEMELden başlayarak kart oluştur.
Özellikle "Her Yıl Çıkar" önem dereceli konulara odaklan.
SADECE JSON dizisi döndür.
''';

    try {
      final fullPrompt = '$_masterPrompt\n\n---\n\n$userPrompt';
      final response = await GravityAI.generateText(fullPrompt);
      
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = response.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr);
        
        return parsed.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value as Map<String, dynamic>;
          
          return AIFlashCard(
            id: 'weak_${topicsStr.hashCode}_$index',
            question: item['question'] ?? '',
            answer: item['answer'] ?? '',
            hint: item['hint'] ?? 'Bu konuya daha fazla zaman ayır.',
            motivation: item['motivation'] ?? 'Zayıf konu çalışmak = Puan artışı!',
            importance: item['importance'] ?? 'Her Yıl Çıkar',
            topic: topicsStr,
            category: category,
          );
        }).toList();
      } else {
        throw Exception('AI yanıtında geçerli JSON bulunamadı');
      }
    } catch (e) {
      throw Exception('Zayıf konu analizi hatası: $e');
    }
  }
}
