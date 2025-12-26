/**
 * 🧬 Sınav İkizi Cloud Functions
 * - Haftalık Yeniden Eşleştirme (Pazar 00:00)
 * - Push Notification Gönderimi
 * - Günlük Düello Sonuçlandırma
 */

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// ========== PERSONA SİSTEMİ (Backend versiyonu) ==========

const KOD_ADLARI = [
    "Neon Kaplan", "Demir Kartal", "Gölge Şahin", "Kristal Tilki",
    "Elektrik Panter", "Buz Aslanı", "Ateş Baykuşu", "Çelik Ejderha",
    "Fırtına Kobrası", "Zümrüt Tavus", "Altın Atmaca", "Gece Kurdu",
    "Yıldırım Okçu", "Alev Savaşçı", "Buz Prensi", "Toprak Devı",
    "Rüzgar Kaşifi", "Su Ustası", "Işık Avcısı", "Gölge Ninja",
    "Yıldız Gezgini", "Ay Şövalyesi", "Güneş Koruyucu", "Galaksi Kaptanı",
    "Meteor Avcısı", "Nebula Savaşçı", "Kuasar Kaşifi", "Pulsar Pilotu",
];

const AVATARLAR = [
    "🐯", "🦅", "🦊", "🐺", "🐆", "🦁", "🦉", "🐉",
    "🐍", "🦚", "🦇", "🐻‍❄️", "🦈", "🐙", "🦋", "🦄",
    "⚡", "🔥", "❄️", "🌊", "🌪️", "☀️", "🌙", "⭐",
];

/**
 * Hash bazlı persona atama
 */
function ataPersona(odgrenciId) {
    let hash = 0;
    for (let i = 0; i < odgrenciId.length; i++) {
        const char = odgrenciId.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash;
    }
    hash = Math.abs(hash);

    const kodAdi = KOD_ADLARI[hash % KOD_ADLARI.length];
    const emoji = AVATARLAR[Math.floor(hash / KOD_ADLARI.length) % AVATARLAR.length];

    return { kodAdi, emoji };
}

/**
 * Twin Score hesapla
 */
function hesaplaTwinScore(profil) {
    let puan = 500;
    puan += Math.min(300, (profil.ortalamaNet / 10) * 30);
    puan += Math.min(200, (profil.gunlukCalismaDakika / 60) * 25);
    return Math.round(Math.min(1000, Math.max(0, puan)));
}

// ========== HAFTALIK YENİDEN EŞLEŞTİRME ==========

/**
 * Her Pazar gece 00:00'da çalışır (Türkiye saati)
 * Tüm öğrencileri yeniden eşleştirir
 */
exports.haftalikYenidenEslestir = functions
    .region("europe-west1")
    .pubsub.schedule("0 0 * * 0") // Pazar 00:00 UTC, TR için "0 21 * * 6" olabilir
    .timeZone("Europe/Istanbul")
    .onRun(async (context) => {
        console.log("🧬 Haftalık İkiz Eşleştirmesi başlıyor...");

        try {
            // 1. Tüm aktif eşleşmeleri pasifleştir
            const mevcutEslesmeler = await db.collection("examTwins")
                .where("durum", "==", "aktif")
                .get();

            const batch = db.batch();
            mevcutEslesmeler.docs.forEach((doc) => {
                batch.update(doc.ref, { durum: "pasif" });
            });
            await batch.commit();

            console.log(`✅ ${mevcutEslesmeler.size} eski eşleşme pasifleştirildi`);

            // 2. Tüm profilleri çek ve grupla (alan + hedef bazlı)
            const profiller = await db.collection("twinProfiles").get();
            const gruplar = {};

            profiller.docs.forEach((doc) => {
                const profil = doc.data();
                const key = `${profil.alan}_${profil.hedefBolum}`;

                if (!gruplar[key]) {
                    gruplar[key] = [];
                }

                gruplar[key].push({
                    id: doc.id,
                    ...profil,
                    twinScore: hesaplaTwinScore(profil),
                });
            });

            // 3. Her grup içinde eşleştir
            let toplamEslestirme = 0;

            for (const key of Object.keys(gruplar)) {
                const grup = gruplar[key];

                // Score'a göre sırala
                grup.sort((a, b) => a.twinScore - b.twinScore);

                // Ardışık ikilileri eşleştir (en yakın score'lar)
                for (let i = 0; i < grup.length - 1; i += 2) {
                    const ogr1 = grup[i];
                    const ogr2 = grup[i + 1];

                    const persona1 = ataPersona(ogr2.id);
                    const persona2 = ataPersona(ogr1.id);
                    const now = new Date().toISOString();

                    // Öğrenci 1'in gördüğü eşleşme
                    await db.collection("examTwins").add({
                        odgrenciId: ogr1.id,
                        ikizId: ogr2.id,
                        ikizKodAdi: persona1.kodAdi,
                        ikizEmoji: persona1.emoji,
                        ikizSeviye: Math.floor(ogr2.twinScore / 50) + 1,
                        durum: "aktif",
                        eslesmeTarihi: now,
                        benimHaftalikSkor: 0,
                        ikizHaftalikSkor: 0,
                        benimGunlukSoru: 0,
                        ikizGunlukSoru: 0,
                        ustUsteGalibiyetSayisi: 0,
                        sonReaksiyonlar: [],
                    });

                    // Öğrenci 2'nin gördüğü eşleşme
                    await db.collection("examTwins").add({
                        odgrenciId: ogr2.id,
                        ikizId: ogr1.id,
                        ikizKodAdi: persona2.kodAdi,
                        ikizEmoji: persona2.emoji,
                        ikizSeviye: Math.floor(ogr1.twinScore / 50) + 1,
                        durum: "aktif",
                        eslesmeTarihi: now,
                        benimHaftalikSkor: 0,
                        ikizHaftalikSkor: 0,
                        benimGunlukSoru: 0,
                        ikizGunlukSoru: 0,
                        ustUsteGalibiyetSayisi: 0,
                        sonReaksiyonlar: [],
                    });

                    toplamEslestirme++;
                }
            }

            console.log(`🎉 Haftalık eşleştirme tamamlandı: ${toplamEslestirme} yeni ikiz çifti`);
            return null;
        } catch (error) {
            console.error("❌ Haftalık eşleştirme hatası:", error);
            throw error;
        }
    });

// ========== GÜNLÜK DÜELLO SONUÇLANDIRMA ==========

/**
 * Her gece 23:59'da çalışır
 * Günlük düelloları sonlandırır ve ödülleri dağıtır
 */
exports.gunlukDuelloSonlandir = functions
    .region("europe-west1")
    .pubsub.schedule("59 23 * * *")
    .timeZone("Europe/Istanbul")
    .onRun(async (context) => {
        console.log("⚔️ Günlük düellolar sonlandırılıyor...");

        try {
            const bugun = new Date();
            const bugunStr = bugun.toISOString().split("T")[0];

            // Bugünkü bitmemiş düelloları bul
            const duellolar = await db.collection("dailyBets")
                .where("kazananId", "==", null)
                .get();

            let sonlandirilan = 0;

            for (const doc of duellolar.docs) {
                const duello = doc.data();
                const duelloTarihi = duello.tarih.split("T")[0];

                // Bugünden önceki düelloları sonlandır
                if (duelloTarihi <= bugunStr) {
                    let kazananId = null;

                    if (duello.odgrenci1SoruSayisi > duello.odgrenci2SoruSayisi) {
                        kazananId = duello.odgrenci1Id;
                    } else if (duello.odgrenci2SoruSayisi > duello.odgrenci1SoruSayisi) {
                        kazananId = duello.odgrenci2Id;
                    }

                    await doc.ref.update({ kazananId });

                    // Kazanana 20 elmas ver
                    if (kazananId) {
                        await db.collection("ogrenciler").doc(kazananId).update({
                            elmaslar: admin.firestore.FieldValue.increment(20),
                        });

                        // Kazanan için üst üste galibiyet sayısını artır
                        const twinDocs = await db.collection("examTwins")
                            .where("odgrenciId", "==", kazananId)
                            .where("durum", "==", "aktif")
                            .limit(1)
                            .get();

                        if (!twinDocs.empty) {
                            await twinDocs.docs[0].ref.update({
                                ustUsteGalibiyetSayisi: admin.firestore.FieldValue.increment(1),
                            });
                        }

                        // Kaybeden için sıfırla
                        const kaybedenId = kazananId === duello.odgrenci1Id ?
                            duello.odgrenci2Id : duello.odgrenci1Id;

                        const kaybedenTwin = await db.collection("examTwins")
                            .where("odgrenciId", "==", kaybedenId)
                            .where("durum", "==", "aktif")
                            .limit(1)
                            .get();

                        if (!kaybedenTwin.empty) {
                            await kaybedenTwin.docs[0].ref.update({
                                ustUsteGalibiyetSayisi: 0,
                            });
                        }
                    }

                    // Co-op modu kontrolü
                    if (duello.coopModu &&
                        duello.odgrenci1SoruSayisi >= duello.coopHedef &&
                        duello.odgrenci2SoruSayisi >= duello.coopHedef) {
                        // Her ikisine 40 elmas
                        await db.collection("ogrenciler").doc(duello.odgrenci1Id).update({
                            elmaslar: admin.firestore.FieldValue.increment(40),
                        });
                        await db.collection("ogrenciler").doc(duello.odgrenci2Id).update({
                            elmaslar: admin.firestore.FieldValue.increment(40),
                        });
                        await doc.ref.update({ coopBasarili: true });
                    }

                    sonlandirilan++;
                }
            }

            console.log(`✅ ${sonlandirilan} düello sonlandırıldı`);
            return null;
        } catch (error) {
            console.error("❌ Düello sonlandırma hatası:", error);
            throw error;
        }
    });

// ========== PUSH NOTIFICATION ==========

/**
 * İkiz aktivite bildirimi
 * İkiz uygulamayı açtığında diğerine bildirim gönder
 */
exports.ikizAktiviteBildirimi = functions
    .region("europe-west1")
    .firestore.document("examTwins/{twinId}")
    .onUpdate(async (change, context) => {
        const onceki = change.before.data();
        const sonraki = change.after.data();

        // Son aktivite değiştiyse
        if (onceki.sonAktivite !== sonraki.sonAktivite) {
            try {
                // İkizin FCM token'ını al
                const ikizDoc = await db.collection("ogrenciler")
                    .doc(sonraki.odgrenciId)
                    .get();

                if (!ikizDoc.exists || !ikizDoc.data().fcmToken) {
                    console.log("FCM token bulunamadı, bildirim gönderilemedi");
                    return null;
                }

                const fcmToken = ikizDoc.data().fcmToken;
                const persona = ataPersona(sonraki.ikizId);

                // Bildirim gönder
                await messaging.send({
                    token: fcmToken,
                    notification: {
                        title: "🔥 İkizin Çalışmaya Başladı!",
                        body: `${persona.kodAdi} şu an masada. Sen hala burada mısın?`,
                    },
                    data: {
                        type: "twin_activity",
                        twinId: context.params.twinId,
                    },
                    android: {
                        priority: "high",
                        notification: {
                            channelId: "twin_notifications",
                            icon: "notification_icon",
                        },
                    },
                    apns: {
                        payload: {
                            aps: {
                                sound: "default",
                                badge: 1,
                            },
                        },
                    },
                });

                console.log(`📱 Bildirim gönderildi: ${sonraki.odgrenciId}`);
            } catch (error) {
                console.error("Bildirim gönderme hatası:", error);
            }
        }

        return null;
    });

/**
 * Reaksiyon bildirimI
 * Biri reaksiyon gönderdiğinde alıcıya bildirim
 */
exports.reaksiyonBildirimi = functions
    .region("europe-west1")
    .firestore.document("twinReactions/{reactionId}")
    .onCreate(async (snap, context) => {
        const reaksiyon = snap.data();

        try {
            // Alıcının FCM token'ını al
            const aliciDoc = await db.collection("ogrenciler")
                .doc(reaksiyon.alanId)
                .get();

            if (!aliciDoc.exists || !aliciDoc.data().fcmToken) {
                return null;
            }

            const fcmToken = aliciDoc.data().fcmToken;
            const persona = ataPersona(reaksiyon.gonderenId);

            const emojiMesajlari = {
                "🔥": "sana alev attı!",
                "👏": "seni alkışladı!",
                "💤": "seni dürtükledi!",
                "⚡": "sana enerji gönderdi!",
                "🎯": "hedefi işaret etti!",
            };

            const mesaj = emojiMesajlari[reaksiyon.emoji] || "sana reaksiyon gönderdi!";

            await messaging.send({
                token: fcmToken,
                notification: {
                    title: `${reaksiyon.emoji} ${persona.kodAdi}`,
                    body: `İkizin ${mesaj}`,
                },
                data: {
                    type: "twin_reaction",
                    emoji: reaksiyon.emoji,
                },
            });

            console.log(`📱 Reaksiyon bildirimi gönderildi: ${reaksiyon.alanId}`);
        } catch (error) {
            console.error("Reaksiyon bildirimi hatası:", error);
        }

        return null;
    });

// ========== GÜNLÜK DÜELLO OLUŞTURMA ==========

/**
 * Her sabah 08:00'da yeni günlük düello başlat
 */
exports.gunlukDuelloBaslat = functions
    .region("europe-west1")
    .pubsub.schedule("0 8 * * *")
    .timeZone("Europe/Istanbul")
    .onRun(async (context) => {
        console.log("🎲 Günlük düellolar başlatılıyor...");

        try {
            const aktifIkizler = await db.collection("examTwins")
                .where("durum", "==", "aktif")
                .get();

            // Her aktif ikiz için günlük düello oluştur (sadece bir taraf için, duplicate önleme)
            const islenmisler = new Set();
            let olusturulan = 0;

            for (const doc of aktifIkizler.docs) {
                const ikiz = doc.data();
                const pairKey = [ikiz.odgrenciId, ikiz.ikizId].sort().join("_");

                if (islenmisler.has(pairKey)) continue;
                islenmisler.add(pairKey);

                await db.collection("dailyBets").add({
                    twinId: doc.id,
                    odgrenci1Id: ikiz.odgrenciId,
                    odgrenci2Id: ikiz.ikizId,
                    tarih: new Date().toISOString(),
                    odgrenci1SoruSayisi: 0,
                    odgrenci2SoruSayisi: 0,
                    kazananId: null,
                    odul: 20,
                    coopModu: false,
                    coopHedef: 50,
                    coopBasarili: false,
                });

                olusturulan++;
            }

            console.log(`✅ ${olusturulan} günlük düello oluşturuldu`);
            return null;
        } catch (error) {
            console.error("❌ Günlük düello başlatma hatası:", error);
            throw error;
        }
    });
