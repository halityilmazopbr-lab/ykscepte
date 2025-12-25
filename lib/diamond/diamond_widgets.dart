import 'package:flutter/material.dart';
import 'diamond_service.dart';
import 'diamond_shop_screen.dart';

/// 💎 Elmas Badge Widget - AppBar veya herhangi bir yerde kullanılabilir
class DiamondBadge extends StatefulWidget {
  final String ogrenciId;
  final String ogrenciAdi;
  final bool showLabel;
  final double size;
  
  const DiamondBadge({
    super.key,
    required this.ogrenciId,
    required this.ogrenciAdi,
    this.showLabel = true,
    this.size = 1.0,
  });

  @override
  State<DiamondBadge> createState() => _DiamondBadgeState();
}

class _DiamondBadgeState extends State<DiamondBadge> {
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }
  
  Future<void> _loadBalance() async {
    final balance = await DiamondService.getBalance(widget.ogrenciId);
    if (mounted) setState(() => _balance = balance);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => DiamondShopScreen(
            ogrenciId: widget.ogrenciId,
            ogrenciAdi: widget.ogrenciAdi,
          ),
        ),
      ).then((_) => _loadBalance()), // Geri dönünce güncelle
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12 * widget.size,
          vertical: 6 * widget.size,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan.shade700, Colors.blue.shade600],
          ),
          borderRadius: BorderRadius.circular(20 * widget.size),
          boxShadow: [
            BoxShadow(
              color: Colors.cyan.withAlpha(50),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("💎", style: TextStyle(fontSize: 16 * widget.size)),
            SizedBox(width: 4 * widget.size),
            Text(
              "$_balance",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14 * widget.size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 💎 Elmas Kazanma Animasyonu - Başarılı işlem sonrası gösterilir
class DiamondEarnAnimation extends StatefulWidget {
  final int amount;
  final String reason;
  final VoidCallback? onComplete;
  
  const DiamondEarnAnimation({
    super.key,
    required this.amount,
    required this.reason,
    this.onComplete,
  });

  @override
  State<DiamondEarnAnimation> createState() => _DiamondEarnAnimationState();
}

class _DiamondEarnAnimationState extends State<DiamondEarnAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward().then((_) {
      Future.delayed(const Duration(seconds: 1), () {
        widget.onComplete?.call();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withAlpha(100),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("💎", style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(
                    "+${widget.amount}",
                    style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.reason,
                    style: TextStyle(color: Colors.grey.shade400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// 💎 Elmas Kazanma Popup'ını göster
void showDiamondEarnPopup(BuildContext context, int amount, String reason) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (context) => Center(
      child: DiamondEarnAnimation(
        amount: amount,
        reason: reason,
        onComplete: () => Navigator.pop(context),
      ),
    ),
  );
}

/// 💎 Elmas Helper - Ödül verme işlemlerini kolaylaştırır
class DiamondHelper {
  
  /// Günlük giriş ödülünü kontrol et ve ver
  static Future<void> checkDailyLogin(BuildContext context, String ogrenciId) async {
    final success = await DiamondService.claimDailyLogin(ogrenciId);
    if (success && context.mounted) {
      showDiamondEarnPopup(context, DiamondService.GUNLUK_GIRIS, "Günlük Giriş Ödülü!");
    }
  }
  
  /// Ödev tamamlama ödülü ver
  static Future<void> rewardHomeworkCompletion(
    BuildContext context, 
    String ogrenciId, 
    String homeworkId,
  ) async {
    final success = await DiamondService.claimHomeworkReward(ogrenciId, homeworkId);
    if (success && context.mounted) {
      showDiamondEarnPopup(context, DiamondService.ODEV_TAMAMLA, "Ödev Tamamlandı!");
    }
  }
  
  /// Düello kazanma ödülü ver
  static Future<void> rewardDuelWin(BuildContext context, String ogrenciId) async {
    final success = await DiamondService.claimDuelReward(ogrenciId);
    if (success && context.mounted) {
      showDiamondEarnPopup(context, DiamondService.DUELLO_KAZAN, "Düello Zaferi!");
    }
  }
  
  /// Hata defteri ekleme ödülü ver
  static Future<void> rewardErrorLog(BuildContext context, String ogrenciId) async {
    final success = await DiamondService.claimErrorLogReward(ogrenciId);
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("💎 +1 Elmas kazandın!"),
          backgroundColor: Colors.cyan,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// Deneme sınavı bitirme ödülü ver
  static Future<void> rewardExamCompletion(
    BuildContext context, 
    String ogrenciId, 
    String examId,
  ) async {
    final success = await DiamondService.claimExamCompletionReward(ogrenciId, examId);
    if (success && context.mounted) {
      showDiamondEarnPopup(context, DiamondService.DENEME_BITIR, "Deneme Sınavı Tamamlandı! 🎉");
    }
  }
}
