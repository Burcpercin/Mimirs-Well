fetch('http://localhost:3000/ask-mimir', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: "Bugün her şey ters gitti, hiçbir şey yolunda değil. Kendimi başarısız hissediyorum." })
})
.then(res => res.json())
.then(data => console.log("\nMimir diyor ki:\n", data.answer, "\n"))
.catch(err => console.error("Hata:", err));