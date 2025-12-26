import 'dart:async';
import 'dart:math';

class LibraryUser {
  final String id;
  final String name;
  final String avatarUrl; // Profil resmi (veya avatar indexi)
  bool isSleeping; // Uygulamadan çıktı mı?
  bool isOnFire; // Uzun süredir çalışıyor mu?
  final String subject; // Ne çalışıyor? (Mat, Fizik...)

  LibraryUser({
    required this.id, 
    required this.name, 
    required this.avatarUrl, 
    this.isSleeping = false,
    this.isOnFire = false,
    this.subject = "Genel"
  });
}

class LibraryService {
  // Singleton
  static final LibraryService _instance = LibraryService._internal();
  factory LibraryService() => _instance;
  LibraryService._internal();

  // Yayın (Stream)
  final _usersController = StreamController<List<LibraryUser>>.broadcast();
  Stream<List<LibraryUser>> get usersStream => _usersController.stream;

  List<LibraryUser> _fakeUsers = [];
  Timer? _simulationTimer;

  // SİMÜLASYONU BAŞLAT
  void enterLibrary(String myName) {
    _fakeUsers = _generateFakeUsers();
    
    // Kendimizi ekleyelim
    _fakeUsers.insert(0, LibraryUser(
      id: "me", 
      name: myName, 
      avatarUrl: "assets/avatars/me.png", 
      subject: "NETX",
      isOnFire: true
    ));
    
    _emit();

    // Diğer kullanıcıların hareketlerini simüle et (Biri uyusun, biri gelsin)
    _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _simulateRandomEvents();
    });
  }

  // DURUMU GÜNCELLE (Uygulama alta atılınca burası çağrılacak)
  void setMyStatus({required bool isSleeping}) {
    int myIndex = _fakeUsers.indexWhere((u) => u.id == "me");
    if (myIndex != -1) {
      _fakeUsers[myIndex].isSleeping = isSleeping;
      _emit();
    }
  }

  void leaveLibrary() {
    _simulationTimer?.cancel();
    _fakeUsers.clear();
  }

  void _simulateRandomEvents() {
    final random = Random();
    // Rastgele birini uyut veya uyandır
    int index = random.nextInt(_fakeUsers.length);
    if (_fakeUsers[index].id != "me") {
      _fakeUsers[index].isSleeping = random.nextBool(); // %50 ihtimal
      _emit();
    }
  }

  void _emit() => _usersController.add(_fakeUsers);

  // MOCK DATA ÜRETİCİ
  List<LibraryUser> _generateFakeUsers() {
    return List.generate(20, (index) => LibraryUser(
      id: "$index",
      name: "Ajan ${100 + index}",
      avatarUrl: "",
      isSleeping: index % 5 == 0, // Her 5 kişiden 1'i uyuyor olsun
      subject: ["Matematik", "Fizik", "Tarih", "Kimya"][index % 4],
      isOnFire: index % 3 == 0 // Her 3 kişiden 1'i alev almış (çok çalışıyor)
    ));
  }
}
