const express = require('express');
const http = require('http');
const WebSocket = require('ws');
const path = require('path');

const app = express();
app.use(express.static(path.join(__dirname, 'public')));

const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const clients = new Set();
const MAX_LEN = 300;

function broadcast(payload, except) {
  const raw = JSON.stringify(payload);
  for (const client of clients) {
    if (client !== except && client.readyState === WebSocket.OPEN) {
      client.send(raw);
    }
  }
}

function usersCount() {
  return [...clients].filter((c) => c.readyState === WebSocket.OPEN && c.username).length;
}

function sendSystem(text) {
  broadcast({
    type: 'system',
    text,
    users: usersCount(),
    timestamp: new Date().toLocaleTimeString()
  });
}

wss.on('connection', (ws) => {
  clients.add(ws);
  ws.username = null;

  ws.send(JSON.stringify({
    type: 'system',
    text: 'Conectado al chat. Escribe tu nombre y pulsa Unirme.',
    users: usersCount(),
    timestamp: new Date().toLocaleTimeString()
  }));

  ws.on('message', (raw) => {
    let data;
    try {
      data = JSON.parse(raw.toString());
    } catch {
      return;
    }

    if (data.type === 'join') {
      const username = String(data.username || '').trim().slice(0, 40);
      if (!username) return;
      ws.username = username;
      sendSystem(`${username} se unió al chat`);
      return;
    }

    if (data.type === 'typing') {
      if (!ws.username) return;
      broadcast({
        type: 'typing',
        username: ws.username,
        isTyping: Boolean(data.isTyping)
      }, ws);
      return;
    }

    if (data.type === 'chat' || data.text) {
      const username = ws.username || String(data.username || '').trim() || 'Anónimo';
      const text = String(data.text || '').trim();
      if (!text || text.length > MAX_LEN) return;

      broadcast({
        type: 'chat',
        username,
        text,
        timestamp: new Date().toLocaleTimeString()
      });
    }
  });

  ws.on('close', () => {
    const name = ws.username;
    clients.delete(ws);
    if (name) sendSystem(`${name} salió del chat`);
  });

  ws.on('error', () => {
    clients.delete(ws);
  });
});

const PORT = 3000;
server.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});
