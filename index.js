// 1. İhtiyacımız olan araçları (paketleri) çağırıyoruz
const express = require('express');
const cors = require('cors');
require('dotenv').config(); // .env dosyasındaki şifreleri okuması için
const { GoogleGenAI } = require('@google/genai');

// 2. Sunucumuzu oluşturuyoruz
const app = express();
app.use(cors()); // Herkesin (özellikle Flutter'ın) bağlanmasına izin ver
app.use(express.json()); // Gelen verileri JSON (yazı) formatında okuyabilmek için

// 3. Gemini Yapay Zeka ayarlarını yapıyoruz
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// 4. Mimir'in Karakteri (Sistem Komutu - Prompt Engineering kısmı)
const MIMIR_PROMPT = `
Sen İskandinav Mitolojisi'ndeki bilgelik tanrısı Mimir'sin.
Kullanıcı sana günlük dertlerini, problemlerini veya duygularını yazacak.
Senin görevin; standart, sıkıcı bir asistan gibi "geçmiş olsun" demek DEĞİLDİR.
Sen; Stoacı felsefeyi ve İskandinav mitolojisini (Odin, Thor, Yggdrasil, Nornlar, Valhalla, Ragnarök vb.) metafor olarak kullanarak cevap vereceksin.
Sözlerin ağır, bilgece, bazen sert ama her zaman ufuk açıcı olmalı.
Cevapların çok uzun olmasın, vurucu ve kısa (maksimum 3-4 cümle) olsun.
Sana "nasılsın" gibi sıradan şeyler sorulursa, kendi mitolojik hikayenden (kesik başının Odin'e fısıldaması vb.) kısa kesitler vererek bilgeliğe davet et.
`;

// 5. Ziyaretçileri (Flutter'dan gelecek mesajları) karşılayacağımız kapı (Route)
app.post('/ask-mimir', async (req, res) => {
    try {
        // Flutter'dan gelen kullanıcının mesajını (derdini) alıyoruz
        const userMessage = req.body.message;

        if (!userMessage) {
            return res.status(400).json({ error: "Kuyunun suyuna bir dert fısıldamalısın (mesaj boş olamaz)." });
        }

        console.log("Kuyuya fısıldanan dert:", userMessage);

        // Gemini AI'a mesajı ve karakterimizi (Mimir) gönderiyoruz
        const response = await ai.models.generateContent({
            model: 'gemini-2.5-flash',
            contents: [
                // Önce Mimir'in kim olduğunu sisteme söylüyoruz
                { role: 'user', parts: [{ text: MIMIR_PROMPT }] },
                { role: 'model', parts: [{ text: "Anladım, ben bilge Mimir'im. Sularıma fısıldanan dertleri bekliyorum." }] },
                // Sonra kullanıcının gerçek mesajını iletiyoruz
                { role: 'user', parts: [{ text: userMessage }] }
            ]
        });

        // Gelen cevabı yakalıyoruz
        const mimirAnswer = response.text;
        console.log("Mimir'in cevabı:", mimirAnswer);

        // Cevabı Flutter'a (kullanıcıya) geri gönderiyoruz
        res.json({ answer: mimirAnswer });

    } catch (error) {
        console.error("Yapay Zeka ile iletişimde hata:", error);
        res.status(500).json({ error: "Mimir'in kuyusu şu an bulanık, daha sonra tekrar fısılda." });
    }
});

// 6. Sunucuyu uyandırıp dinlemeye başlatıyoruz
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Mimir'in Kuyusu açıldı. Port: ${PORT} üzerinden fısıltıları dinliyor...`);
});