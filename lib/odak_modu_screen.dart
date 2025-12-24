import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Odak Modu - Focus Zone
/// Arka plan sesleri ile çalışma ortamı
class OdakModuEkrani extends StatefulWidget {
  const OdakModuEkrani({super.key});

  @override
  State<OdakModuEkrani> createState() => _OdakModuEkraniState();
}

class _OdakModuEkraniState extends State<OdakModuEkrani> with TickerProviderStateMixin {
  // Zamanlayıcı
  int _selectedMinutes = 25;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;

  // Ses kontrolleri
  String? _activeSound;
  double _volume = 0.5;
  
  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioLoading = false;

  // Sesler - Web uyumlu ses dosyaları (CORS friendly)
  final List<Map<String, dynamic>> _sounds = [
    {
      "id": "rain", 
      "name": "Yağmur", 
      "icon": Icons.water_drop, 
      "color": Colors.blue,
      "type": "asset",
      "url": "sounds/yagmur.mp3"
    },
    {
      "id": "forest", 
      "name": "Orman", 
      "icon": Icons.forest, 
      "color": Colors.green,
      "type": "network",
      "url": "https://upload.wikimedia.org/wikipedia/commons/9/9f/Waldatmung.ogg"
    },
    {
      "id": "ocean", 
      "name": "Okyanus", 
      "icon": Icons.waves, 
      "color": Colors.cyan,
      "type": "network",
      "url": "https://upload.wikimedia.org/wikipedia/commons/e/e9/2017-01-07_Ocean_Beach_-_ocean_waves.webm"
    },
    {
      "id": "fire", 
      "name": "Şömine", 
      "icon": Icons.local_fire_department, 
      "color": Colors.orange,
      "type": "network",
      "url": "https://upload.wikimedia.org/wikipedia/commons/2/25/Burning_fire.ogg"
    },
    {
      "id": "coffee", 
      "name": "Kafe", 
      "icon": Icons.coffee, 
      "color": Colors.brown,
      "type": "network",
      "url": "https://upload.wikimedia.org/wikipedia/commons/0/0d/Relaxed_Music_for_Cafe_Bar%2C_Restaurant._Good_Morning_Jazz.ogg"
    },
    {
      "id": "wind", 
      "name": "Rüzgar", 
      "icon": Icons.air, 
      "color": Colors.grey,
      "type": "network",
      "url": "https://upload.wikimedia.org/wikipedia/commons/5/55/En-us-wind.ogg"
    },
    {
      "id": "night", 
      "name": "Gece", 
      "icon": Icons.nightlight, 
      "color": Colors.indigo,
      "type": "network",
      "url": "https://upload.wikimedia.org/wikipedia/commons/f/ff/Crickets_chirping_at_night_2017-07-14.ogg"
    },
    {
      "id": "thunder", 
      "name": "Fırtına", 
      "icon": Icons.flash_on, 
      "color": Colors.deepPurple,
      "type": "network",
      "url": "https://upload.wikimedia.org/wikipedia/commons/4/4e/Thunder3.ogg"
    },
  ];

  // Preset süreleri
  final List<int> _presets = [15, 25, 45, 60, 90];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60;
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    // Audio player ayarları
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Sürekli döngü
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds == 0) {
      _remainingSeconds = _selectedMinutes * 60;
    }
    
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopTimer();
        _showCompleteDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _showCompleteDialog() {
    // Sesi durdur
    _audioPlayer.stop();
    setState(() => _activeSound = null);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF21262D),
        title: const Text("🎉 Tebrikler!", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 16),
            Text(
              "$_selectedMinutes dakikalık odak seansını tamamladın!",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text("Tamam"),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleSound(String soundId) async {
    if (_activeSound == soundId) {
      setState(() => _activeSound = null);
      await _audioPlayer.stop();
    } else {
      setState(() {
        _activeSound = soundId;
        _isAudioLoading = true;
      });
      
      try {
        final sound = _sounds.firstWhere((s) => s['id'] == soundId);
        
        if (sound['type'] == 'asset') {
          await _audioPlayer.play(AssetSource(sound['url']));
        } else {
          await _audioPlayer.play(UrlSource(sound['url']));
        }
        
        setState(() => _isAudioLoading = false);

        if (sound['type'] == 'network') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("🎵 ${sound['name']} çalınıyor..."),
                backgroundColor: sound['color'],
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isAudioLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ses oynatılırken hata oluştu")),
          );
        }
      }
    }
  }

  Future<void> _updateVolume(double value) async {
    setState(() => _volume = value);
    await _audioPlayer.setVolume(value);
  }

  String get _formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161B22),
        title: const Text("🎧 Odak Modu", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer Circle
            _buildTimerCircle(),
            
            const SizedBox(height: 24),
            
            // Süre Preset'leri
            _buildPresets(),
            
            const SizedBox(height: 32),
            
            // Kontrol Butonları
            _buildControls(),
            
            const SizedBox(height: 40),
            
            // Arka Plan Sesleri
            _buildSoundsSection(),
            
            const SizedBox(height: 24),
            
            // Volume Slider
            if (_activeSound != null) _buildVolumeSlider(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle() {
    return ScaleTransition(
      scale: _isRunning ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              _isRunning ? Colors.green.withAlpha(30) : Colors.purple.withAlpha(30),
              Colors.transparent,
            ],
          ),
          border: Border.all(
            color: _isRunning ? Colors.green : Colors.purple,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isRunning ? Colors.green : Colors.purple).withAlpha(50),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _formattedTime,
                style: TextStyle(
                  color: _isRunning ? Colors.green : Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isRunning ? "Odaklan! 🎯" : (_isPaused ? "Duraklatıldı" : "Hazır"),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _presets.map((mins) {
        bool isSelected = _selectedMinutes == mins;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: _isRunning ? null : () {
              setState(() {
                _selectedMinutes = mins;
                _remainingSeconds = mins * 60;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.purple : const Color(0xFF21262D),
                borderRadius: BorderRadius.circular(20),
                border: isSelected ? null : Border.all(color: Colors.grey.shade800),
              ),
              child: Text(
                "$mins dk",
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade400,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stop
        if (_isRunning || _isPaused)
          IconButton(
            onPressed: _stopTimer,
            icon: const Icon(Icons.stop_circle, size: 50),
            color: Colors.red,
          ),
        
        const SizedBox(width: 20),
        
        // Play/Pause
        GestureDetector(
          onTap: _isRunning ? _pauseTimer : _startTimer,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.purple.shade700],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withAlpha(80),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              size: 40,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSoundsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "🔊 Arka Plan Sesleri",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isAudioLoading) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purple),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Odaklanmana yardımcı olacak bir ses seç",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _sounds.length,
          itemBuilder: (context, index) {
            final sound = _sounds[index];
            bool isActive = _activeSound == sound['id'];
            
            return GestureDetector(
              onTap: () => _toggleSound(sound['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isActive ? (sound['color'] as Color).withAlpha(50) : const Color(0xFF21262D),
                  borderRadius: BorderRadius.circular(16),
                  border: isActive 
                      ? Border.all(color: sound['color'], width: 2)
                      : Border.all(color: Colors.grey.shade800),
                  boxShadow: isActive ? [
                    BoxShadow(
                      color: (sound['color'] as Color).withAlpha(80),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ] : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      sound['icon'],
                      color: isActive ? sound['color'] : Colors.grey.shade500,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sound['name'],
                      style: TextStyle(
                        color: isActive ? sound['color'] : Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isActive)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Icon(Icons.graphic_eq, size: 14, color: Colors.white54),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVolumeSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  _volume == 0 ? Icons.volume_off : (_volume < 0.5 ? Icons.volume_down : Icons.volume_up),
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text("Ses Seviyesi", style: TextStyle(color: Colors.white70)),
              ],
            ),
            Text("${(_volume * 100).toInt()}%", style: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            activeTrackColor: Colors.purple,
            inactiveTrackColor: Colors.grey.shade800,
            thumbColor: Colors.white,
            overlayColor: Colors.purple.withAlpha(50),
          ),
          child: Slider(
            value: _volume,
            onChanged: _updateVolume,
          ),
        ),
      ],
    );
  }
}
