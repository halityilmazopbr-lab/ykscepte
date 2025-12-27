# Firestore Security Rules - Yaşayan Soru Bankası

## Firebase Console'a Yapıştırılacak Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ============================================
    // YAŞAYAN SORU BANKASI (havuz_sorulari)
    // ============================================
    match /havuz_sorulari/{soruId} {
      
      // OKUMA: Herkes okuyabilir (soru çekmek için)
      allow read: if true;
      
      // OLUŞTURMA: Giriş yapmış kullanıcılar (AI servisi için)
      allow create: if request.auth != null;
      
      // GÜNCELLEME: Sadece belirli alanlar güncellenebilir
      allow update: if request.auth != null 
                    && request.resource.data.diff(resource.data).affectedKeys()
                       .hasOnly([
                         'goruntulenme',
                         'dogruSayisi', 
                         'yanlisSayisi',
                         'begeni',
                         'begenmeme',
                         'rapor',
                         'onayliMi'
                       ]);
      
      // SİLME: Sadece admin (custom claim gerekli)
      // Şimdilik kapalı, ileride admin panel eklenince açılır
      allow delete: if false;
    }
  }
}
```

---

## 🆕 Hybrid Filtering - Kullanıcı Geçmişi Collection

### Collection: `users/{userId}/cozulen_sorular`

**Security Rules:**
```javascript
match /users/{userId} {
  // Kullanıcı kendi verilerine erişebilir
  match /cozulen_sorular/{soruId} {
    allow read, write: if request.auth.uid == userId;
  }
}
```

**Açıklama:**
- Her kullanıcı sadece kendi çözülen soru geçmişini okuyabilir/yazabilir
- Admin erişimi için custom claim eklenebilir
- Subcollection yapısı sayesinde kullanıcılar birbirinin geçmişini göremez
```

## Composite Index Gereksinimi

Firebase Console'da şu index'i oluşturmanız gerekecek:

**Collection**: `havuz_sorulari`

| Field | Order |
|-------|-------|
| ders | Ascending |
| konu | Ascending |
| onayliMi | Ascending |
| rapor | Ascending |

⚠️ **Önemli**: İlk soru sorgusu yapıldığında Firebase Console'da bir hata göreceksiniz ve otomatik link verilecek. O linke tıklayıp index'i oluşturun.

## Data Structure

```typescript
interface HavuzSorulari {
  soruMetni: string;
  siklar: string[]; // 5 elemanlı array
  dogruCevap: string;
  cozumAciklamasi?: string;
  ders: string;
  konu: string;
  goruntulenme: number; // Atomic increment
  dogruSayisi: number; // Atomic increment
  yanlisSayisi: number; // Atomic increment
  begeni: number; // Atomic increment
  begenmeme: number; // Atomic increment
  rapor: number; // Atomic increment
  onayliMi: boolean; // Karantina kontrolü
  kaynak: "AI" | "Manuel";
  olusturulmaTarihi: Timestamp;
}
```

---

## 🏆 ARENA - Global Challenge System

### Collection: `arena_challenges`

**Security Rules:**
```javascript
match /arena_challenges/{challengeId} {
  // Herkes okuyabilir (challenge listesi için)
  allow read: if true;
  
  // Sadece admin oluşturabilir/güncelleyebilir
  allow create, update, delete: if request.auth.token.admin == true;
  
  // Subcollection: Katılımcılar
  match /katilimcilar/{userId} {
    // Herkes okuyabilir (leaderboard için)
    allow read: if true;
    
    // ANTI-CHEAT: Sadece kendi kaydını oluşturabilir + Tek seferlik
    allow create: if request.auth.uid == userId
                  && !exists(/databases/$(database)/documents/arena_challenges/$(challengeId)/katilimcilar/$(userId));
    
    // Güncelleme ve silme yasak (cheat prevention)
    allow update, delete: if false;
  }
}
```

**Composite Indexes:**
```
Collection: arena_challenges/*/katilimcilar
- puan (Descending) + sure (Ascending) → Leaderboard
- katilimZamani (Descending) → Live ticker
```

**Açıklama:**
- Challenge'lar herkes tarafından görüntülenebilir
- Katılım kayıtları tek seferlik (anti-cheat)
- Server timestamp ile zaman koruması
- Transaction ile çift giriş engeli

---

## 🏛️ SORU MEYDANI - Social Learning Network

### Collection: `help_requests`

**Security Rules:**
```javascript
match /help_requests/{requestId} {
  // Herkes okuyabilir
  allow read: if true;
  
  // Soru sorma: Authenticated kullanıcı + AI Guardian geçmeli
  allow create: if request.auth != null 
                && request.resource.data.senderUserId == request.auth.uid;
                
  // Güncelleme: Sadece çözüm sayısını artırmak veya çözüldü işaretlemek için (Service Transaction)
  allow update: if request.auth != null;

  // Subcollection: Solutions
  match /solutions/{solutionId} {
    allow read: if true;
    
    // Çözüm gönderme: Kendi kimliğiyle
    allow create: if request.auth != null 
                  && request.resource.data.solverUserId == request.auth.uid;
    
    // Sadece soran kişi "En İyi Cevap" seçebilir
    allow update: if request.auth != null 
                  && get(/databases/$(database)/documents/help_requests/$(requestId)).data.senderUserId == request.auth.uid;
  }
}
```

**Anti-Harassment Policy:**
- Mesajlar AI (Local/Cloud) tarafından taranır.
- Raporlama (Report) sonrası 3 ihlalde **Device ID Ban** uygulanır.
