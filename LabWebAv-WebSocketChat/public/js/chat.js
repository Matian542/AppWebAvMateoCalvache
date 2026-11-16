(() => {
  const MAX_LEN = 300;
  const statusEl = document.getElementById('status');
  const usersEl = document.getElementById('users');
  const chatEl = document.getElementById('chat');
  const typingEl = document.getElementById('typing');
  const usernameEl = document.getElementById('username');
  const joinBtn = document.getElementById('join');
  const messageEl = document.getElementById('message');
  const sendBtn = document.getElementById('send');
  const themeToggle = document.getElementById('themeToggle');

  let socket;
  let myName = localStorage.getItem('chatUsername') || '';
  let typingTimer;
  let joined = false;

  if (myName) usernameEl.value = myName;

  function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('chatTheme', theme);
    themeToggle.textContent = theme === 'dark' ? 'Modo claro' : 'Modo oscuro';
  }

  applyTheme(localStorage.getItem('chatTheme') || 'light');

  themeToggle.addEventListener('click', () => {
    const next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
    applyTheme(next);
  });

  function setStatus(text, kind) {
    statusEl.textContent = text;
    statusEl.className = `status ${kind}`;
  }

  function addSystem(text) {
    const el = document.createElement('div');
    el.className = 'system';
    el.textContent = text;
    chatEl.appendChild(el);
    chatEl.scrollTop = chatEl.scrollHeight;
  }

  function addBubble({ username, text, timestamp }, mine) {
    const wrap = document.createElement('div');
    wrap.className = `bubble ${mine ? 'mine' : 'theirs'}`;
    wrap.innerHTML = `
      ${mine ? '' : `<div class="name">${escapeHtml(username)}</div>`}
      <div>${escapeHtml(text)}</div>
      <span class="time">${escapeHtml(timestamp || '')}</span>
    `;
    chatEl.appendChild(wrap);
    chatEl.scrollTop = chatEl.scrollHeight;
  }

  function escapeHtml(str) {
    return String(str)
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
  }

  function sendJson(payload) {
    if (!socket || socket.readyState !== WebSocket.OPEN) return;
    socket.send(JSON.stringify(payload));
  }

  function connect() {
    setStatus('Reconectando…', 'warn');
    const protocol = location.protocol === 'https:' ? 'wss:' : 'ws:';
    socket = new WebSocket(`${protocol}//${location.host}`);

    socket.onopen = () => {
      setStatus('Conectado', 'ok');
      if (joined && myName) {
        sendJson({ type: 'join', username: myName });
      }
    };

    socket.onmessage = (event) => {
      let data;
      try {
        data = JSON.parse(event.data);
      } catch {
        return;
      }

      if (data.type === 'system') {
        addSystem(data.text);
        if (typeof data.users === 'number') {
          usersEl.textContent = `Usuarios: ${data.users}`;
        }
        return;
      }

      if (data.type === 'typing') {
        if (data.username !== myName) {
          typingEl.textContent = data.isTyping ? `${data.username} está escribiendo…` : '';
        }
        return;
      }

      if (data.type === 'chat' || data.text) {
        addBubble(data, data.username === myName);
        typingEl.textContent = '';
      }
    };

    socket.onclose = () => {
      setStatus('Desconectado — reconectando…', 'bad');
      setTimeout(connect, 3000);
    };

    socket.onerror = () => setStatus('Error de conexión', 'bad');
  }

  function joinChat() {
    const name = usernameEl.value.trim();
    if (!name) {
      alert('Escribe tu nombre');
      return;
    }
    myName = name;
    localStorage.setItem('chatUsername', myName);
    joined = true;
    usernameEl.disabled = true;
    joinBtn.disabled = true;
    sendJson({ type: 'join', username: myName });
  }

  function sendMessage() {
    if (!joined) {
      alert('Primero únete con tu nombre');
      return;
    }
    const text = messageEl.value.trim();
    if (!text) return;
    if (text.length > MAX_LEN) {
      alert(`Máximo ${MAX_LEN} caracteres`);
      return;
    }
    sendJson({ type: 'chat', username: myName, text });
    messageEl.value = '';
    sendJson({ type: 'typing', username: myName, isTyping: false });
  }

  joinBtn.addEventListener('click', joinChat);
  sendBtn.addEventListener('click', sendMessage);
  messageEl.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') sendMessage();
  });

  messageEl.addEventListener('input', () => {
    if (!joined) return;
    sendJson({ type: 'typing', username: myName, isTyping: true });
    clearTimeout(typingTimer);
    typingTimer = setTimeout(() => {
      sendJson({ type: 'typing', username: myName, isTyping: false });
    }, 1200);
  });

  connect();
})();
