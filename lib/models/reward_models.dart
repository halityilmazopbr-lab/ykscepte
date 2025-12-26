import 'package:flutter/material.dart';

/// Kategori Enum
enum RewardCategory { all, gaming, education, lifestyle }

/// Ödül Ürünü Modeli
class RewardItem {
  final String id;
  final String name;       // Örn: 1450 Valorant Points
  final String imagePath;  // Logo yolu
  final double price;      // Veliye yansıyacak fiyat (Örn: 150 TL)
  final RewardCategory category; 
  final bool isParentApproved; // "Veli Dostu" etiketi için
  final String description; // Ürün açıklaması

  RewardItem({
    required this.id, 
    required this.name, 
    required this.imagePath, 
    required this.price, 
    required this.category,
    this.isParentApproved = false,
    this.description = '',
  });
}

/// Çalışma Hedefi Modeli
class StudyGoal {
  final String id;
  final String title;       // Örn: "Türev Fasikülü Bitirme"
  final String rewardName;  // Örn: "Kahve Dünyası 100 TL"
  final double targetValue; // Hedef değer (örn: 500 soru)
  final double currentValue; // Şu anki ilerleme
  final bool isSponsored;   // Veli parayı yatırdı mı?
  final bool isCompleted;   // Hedef bitti mi?
  final DateTime? deadline; // Bitiş tarihi
  final RewardItem? reward; // Ödül ürünü

  StudyGoal({
    required this.id,
    required this.title,
    required this.rewardName,
    required this.targetValue,
    this.currentValue = 0.0,
    this.isSponsored = false,
    this.isCompleted = false,
    this.deadline,
    this.reward,
  });

  double get progress => currentValue / targetValue;
  int get progressPercent => (progress * 100).clamp(0, 100).toInt();
}
