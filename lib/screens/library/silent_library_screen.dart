import 'package:flutter/material.dart';
import '../../services/library_service.dart';

class SilentLibraryScreen extends StatefulWidget {
  const SilentLibraryScreen({super.key});

  @override
  _SilentLibraryScreenState createState() => _SilentLibraryScreenState();
}

class _SilentLibraryScreenState extends State<SilentLibraryScreen> with WidgetsBindingObserver {
  final LibraryService _service = LibraryService();
  
  // Ambiyans Sesi Kontrolü (Mock)
  bool _isSoundOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Lifecycle Takibi Başlat
    _service.enterLibrary("Ben"); // Odaya gir
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Takibi Bırak
    _service.leaveLibrary(); // Odadan çık
    super.dispose();
  }

  // 🔥 KRİTİK NOKTA: Uygulama Alta Atıldı mı?
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // Kullanıcı Instagram'a gitti! Avatarını uyut.
      print("Kullanıcı kaçtı!");
      _service.setMyStatus(isSleeping: true);
    } else if (state == AppLifecycleState.resumed) {
      // Geri döndü. Avatarı uyandır.
      print("Kullanıcı geri döndü.");
      _service.setMyStatus(isSleeping: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505), // Zifiri Karanlık
      appBar: AppBar(
        title: Column(
          children: [
            const Text("SESSİZ KÜTÜPHANE", style: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)),
            StreamBuilder<List<LibraryUser>>(
              stream: _service.usersStream,
              builder: (context, snapshot) {
                int count = snapshot.hasData ? snapshot.data!.length + 1420 : 1420; // +1420 hayali kullanıcı
                return Text("$count Çalışkan Aktif", style: const TextStyle(color: Colors.greenAccent, fontSize: 10));
              },
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSoundOn ? Icons.volume_up : Icons.volume_off, color: Colors.white54),
            onPressed: () => setState(() => _isSoundOn = !_isSoundOn),
          )
        ],
      ),
      body: StreamBuilder<List<LibraryUser>>(
        stream: _service.usersStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final users = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // Yan yana 4 masa
              childAspectRatio: 0.8,
              crossAxisSpacing: 15,
              mainAxisSpacing: 20,
            ),
            itemCount: users.length,
            itemBuilder: (ctx, index) {
              return _buildUserSeat(users[index]);
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white.withOpacity(0.05),
        child: const Text(
          "Uygulamadan çıkarsan avatarın 'Uyuyor' moduna geçer ve odak serin bozulur.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildUserSeat(LibraryUser user) {
    // Renk Kodları:
    // Uyuyorsa: Gri
    // Aktifse: Yeşil
    // Alev Modu (OnFire): Turuncu
    
    Color statusColor = Colors.greenAccent;
    if (user.isSleeping) statusColor = Colors.grey[800]!;
    else if (user.isOnFire) statusColor = Colors.orangeAccent;

    return Column(
      children: [
        // AVATAR KUTUSU
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor, 
                width: user.isOnFire ? 2 : 1 // Alevliyse kalın çerçeve
              ),
              boxShadow: user.isOnFire && !user.isSleeping
                  ? [BoxShadow(color: Colors.orange.withOpacity(0.4), blurRadius: 10)] 
                  : [],
            ),
            child: Center(
              child: user.isSleeping
                  ? const Icon(Icons.nightlight_round, color: Colors.grey, size: 30) // Uyuyor İkonu
                  : Text(
                      user.name.substring(0, 1), // İsmin baş harfi
                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 24),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // İSİM VE DURUM
        Text(
          user.isSleeping ? "Zzz..." : user.name,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
          maxLines: 1,
        ),
        if (!user.isSleeping)
          Text(
            user.subject,
            style: const TextStyle(color: Colors.white30, fontSize: 8),
          ),
      ],
    );
  }
}
