// 1. Import required packages
const express = require('express');
const cors = require('cors');
require('dotenv').config(); // Load environment variables from .env file
const { GoogleGenAI } = require('@google/genai');
const rateLimit = require('express-rate-limit'); // Security: Rate limiter

// 2. Initialize the Express server
const app = express();
app.use(cors()); // Enable CORS to allow requests from the Flutter client
app.use(express.json()); // Parse incoming JSON requests

// --- GÜVENLİK (RATE LIMITING) AYARI ---
// Bu ayar, aynı IP adresinden peş peşe yapılan saldırıları veya gereksiz istekleri engeller.
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 dakika (Zaman penceresi)
    max: 10, // Her IP için 15 dakika içinde maksimum 10 istek hakkı
    message: { error: "Mimir'i çok fazla yordun. Biraz dinlen, sular durulunca tekrar gel (15 dakika bekle)." },
    standardHeaders: true, // Rate limit bilgisini header'lara ekler (kalan hakkını görmek için)
    legacyHeaders: false, // Eski tip header'ları kapatır
});

// Kapıcıyı sadece '/ask-mimir' rotasına (yoluna) ekliyoruz
app.use('/ask-mimir', limiter);

// 3. Configure Google Gemini AI
const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

// 4. Mimir's Persona (System Prompt)

const MIMIR_PROMPT = `
Sen İskandinav Mitolojisi'ndeki bilgelik tanrısı Mimir'sin.
Kullanıcı sana günlük dertlerini, problemlerini veya duygularını yazacak.
Senin görevin; standart, sıkıcı bir asistan gibi "geçmiş olsun" demek DEĞİLDİR.
Sen; Stoacı felsefeyi ve İskandinav mitolojisini (Odin, Thor, Yggdrasil, Nornlar, Valhalla, Ragnarök vb.) metafor olarak kullanarak cevap vereceksin.
Sözlerin ağır, bilgece, bazen sert ama her zaman ufuk açıcı olmalı.
Cevapların çok uzun olmasın, vurucu ve kısa (maksimum 3-4 cümle) olsun.
Sana "nasılsın" gibi sıradan şeyler sorulursa, kendi mitolojik hikayenden (kesik başının Odin'e fısıldaması vb.) kısa kesitler vererek bilgeliğe davet et.
`;

// 5. API Route to handle incoming messages from Flutter
app.post('/ask-mimir', async (req, res) => {
    try {
        // Extract the user's message from the request body
        const userMessage = req.body.message;

        if (!userMessage) {
            return res.status(400).json({ error: "Kuyunun suyuna bir dert fısıldamalısın (mesaj boş olamaz)." });
        }

        console.log("Whisper received:", userMessage);

        // Send the prompt and user message to Gemini AI using the correct System Instruction format
        const response = await ai.models.generateContent({
            model: 'gemini-2.5-flash',
            contents: userMessage, // Just send the user's message here
            config: {
                systemInstruction: MIMIR_PROMPT, // Mimir's persona goes here!
                temperature: 0.7 // Control creativity (0.0 to 2.0)
            }
        });

        // Extract the response text
        const mimirAnswer = response.text;
        console.log("Mimir's answer:", mimirAnswer);

        // Send the AI's answer back to the Flutter app
        res.json({ answer: mimirAnswer });

    } catch (error) {
        console.error("Error communicating with AI:", error);
        res.status(500).json({ error: "Mimir'in kuyusu şu an bulanık, daha sonra tekrar fısılda." });
    }
});


const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Mimir's Well API is open. Listening for whispers on port: ${PORT}...`);
});