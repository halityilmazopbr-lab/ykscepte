/// 🔮 Kahin (Oracle) Modülü - İnteraktif Dialog
/// Slider ile net ayarlama ve anlık sıralama tahmini

import 'package:flutter/material.dart';
import 'oracle_service.dart';

class OracleDialog extends StatefulWidget {
  final double initialTytNet;
  final int? targetRank;

  const OracleDialog({
    super.key,
    required this.initialTytNet,
    this.targetRank,
  });

  @override
  State<OracleDialog> createState() => _OracleDialogState();
}

class _OracleDialogState extends State<OracleDialog> {
  final OracleService _oracle = OracleService();
  final TextEditingController _targetController = TextEditingController();

  late double _currentNet;
  late int _targetRank;
  int _predictedRank = 0;
  String _message = "";

  @override
  void initState() {
    super.initState();
    _currentNet = widget.initialTytNet;
    _targetRank = widget.targetRank ?? 20000;
    _targetController.text = _targetRank.toString();
    _updatePrediction();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _updatePrediction() {
    setState(() {
      _predictedRank = _oracle.calculateTytRank(_currentNet);
      _message = _oracle.getOracleMessage(_predictedRank, _targetRank);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hedefe ulaştıysa yeşil, yoksa kırmızı
    final bool onTarget = _predictedRank <= _targetRank;
    final statusColor = onTarget ? Colors.greenAccent : Colors.redAccent;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ═══════════════════════════════════════════════════
              // BAŞLIK
              // ═══════════════════════════════════════════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.purpleAccent),
                  const SizedBox(width: 8),
                  const Text(
                    "KAHİN SİMÜLASYONU",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 30),

              // ═══════════════════════════════════════════════════
              // HEDEF SIRALAMA INPUT
              // ═══════════════════════════════════════════════════
              const Text(
                "HEDEFİN KAÇ BİN?",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Örn: 20000",
                    hintStyle: TextStyle(color: Colors.grey[700]),
                    icon: const Icon(Icons.flag, color: Colors.purpleAccent),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null && parsed > 0) {
                      _targetRank = parsed;
                      _updatePrediction();
                    }
                  },
                ),
              ),

              const SizedBox(height: 25),

              // ═══════════════════════════════════════════════════
              // NET SLIDER
              // ═══════════════════════════════════════════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TYT NETİN:", style: TextStyle(color: Colors.white70)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentNet.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.purpleAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.purpleAccent,
                  inactiveTrackColor: Colors.purple.withValues(alpha: 0.2),
                  thumbColor: Colors.white,
                  overlayColor: Colors.purpleAccent.withValues(alpha: 0.2),
                  valueIndicatorColor: Colors.purpleAccent,
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: _currentNet,
                  min: 0,
                  max: 120,
                  divisions: 240, // 0.5'lik artışlar
                  label: _currentNet.toStringAsFixed(1),
                  onChanged: (val) {
                    setState(() => _currentNet = val);
                    _updatePrediction();
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════════════════
              // BÜYÜK SIRALAMA SONUCU
              // ═══════════════════════════════════════════════════
              const Text(
                "TAHMİNİ SIRALAMA",
                style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                _oracle.formatRank(_predictedRank),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: statusColor.withValues(alpha: 0.5), blurRadius: 20),
                  ],
                ),
              ),

              // Hedefle karşılaştırma
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    onTarget ? Icons.check_circle : Icons.cancel,
                    color: statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    onTarget
                        ? "Hedefin ${_oracle.formatRank(_targetRank)}'den iyi!"
                        : "Hedefe ${_oracle.formatRank(_predictedRank - _targetRank)} uzaktasın",
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════════════════
              // YORUM KUTUSU
              // ═══════════════════════════════════════════════════
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                ),
              ),

              const SizedBox(height: 20),

              // ═══════════════════════════════════════════════════
              // NET TAHMİNİ (hedefe ulaşmak için)
              // ═══════════════════════════════════════════════════
              if (!onTarget) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Hedefe ulaşmak için +${_oracle.estimateNetGain(_currentNet, _targetRank).toStringAsFixed(1)} net lazım",
                          style: const TextStyle(color: Colors.amber, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ═══════════════════════════════════════════════════
              // KAPAT BUTONU
              // ═══════════════════════════════════════════════════
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, _currentNet),
                  child: const Text(
                    "ANLAŞILDI",
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
