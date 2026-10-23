/**
 * Peak Pact — онлайн-сервер (комнаты)
 * Не LAN: один общий хост для всех игроков.
 *
 * npm install
 * node server.js
 *
 * Порт: process.env.PORT || 3000
 */
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const fs = require('fs');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: '*' },
  pingInterval: 5000,
  pingTimeout: 10000
});

app.use(express.json({ limit: '1mb' }));

// Раздача игры, если peak-pact.html лежит рядом
const root = __dirname;
if (fs.existsSync(path.join(root, 'peak-pact.html'))) {
  app.use(express.static(root));
  app.get('/', (req, res) => res.sendFile(path.join(root, 'peak-pact.html')));
} else {
  app.get('/', (req, res) => res.type('text').send('Peak Pact online server OK'));
}

const rooms = new Map();

function code() {
  return String(Math.floor(1000 + Math.random() * 9000));
}

function lobbyState(c) {
  const room = rooms.get(c);
  if (!room) return null;
  return {
    code: c,
    name: room.name,
    private: !!room.private,
    maxPlayers: room.maxPlayers,
    players: room.players.map(p => ({ slot: p.slot, name: p.name })),
    host: room.host,
    started: room.started,
    diff: room.diff,
    mapId: room.mapId
  };
}

function publicRoomList() {
  const list = [];
  for (const [c, room] of rooms) {
    if (room.private || room.started) continue;
    list.push({
      code: c,
      name: room.name,
      players: room.players.length,
      maxPlayers: room.maxPlayers,
      diff: room.diff
    });
  }
  return list;
}

io.on('connection', (socket) => {
  console.log('connect', socket.id);

  socket.on('list_rooms', () => {
    socket.emit('room_list', publicRoomList());
  });

  socket.on('create', (data = {}) => {
    const roomName = String(data.roomName || data.name || 'Room').trim().slice(0, 48) || 'Room';
    const isPrivate = !!(data.isPrivate || data.private);
    let maxPlayers = parseInt(data.maxPlayers, 10);
    if (!Number.isFinite(maxPlayers)) maxPlayers = 4;
    maxPlayers = Math.max(1, Math.min(10, maxPlayers));
    const playerName = String(data.playerName || data.name || 'Host').trim().slice(0, 24) || 'Host';

    let c;
    do { c = code(); } while (rooms.has(c));

    rooms.set(c, {
      name: roomName,
      private: isPrivate,
      maxPlayers,
      players: [{ id: socket.id, name: playerName, slot: 0 }],
      host: socket.id,
      started: false,
      seed: Date.now() % 100000,
      diff: data.diff || 'easy',
      mapId: data.mapId || 0
    });

    socket.join(c);
    socket.room = c;
    socket.slot = 0;
    socket.emit('created', {
      code: c,
      slot: 0,
      seed: rooms.get(c).seed,
      name: roomName,
      private: isPrivate,
      maxPlayers
    });
    io.to(c).emit('lobby', lobbyState(c));
    io.emit('room_list', publicRoomList());
  });

  socket.on('join', (data = {}) => {
    const c = String(data.code || '').trim();
    const playerName = String(data.playerName || data.name || 'Guest').trim().slice(0, 24) || 'Guest';
    const room = rooms.get(c);
    if (!room) return socket.emit('err', 'Room not found');
    if (room.players.length >= room.maxPlayers) return socket.emit('err', 'Room full');
    if (room.started) return socket.emit('err', 'Already started');

    const used = new Set(room.players.map(p => p.slot));
    let slot = 0;
    while (used.has(slot) && slot < 10) slot++;

    room.players.push({ id: socket.id, name: playerName, slot });
    socket.join(c);
    socket.room = c;
    socket.slot = slot;
    socket.emit('joined', {
      code: c,
      slot,
      diff: room.diff,
      mapId: room.mapId,
      seed: room.seed,
      name: room.name
    });
    io.to(c).emit('lobby', lobbyState(c));
    io.emit('room_list', publicRoomList());
  });

  socket.on('start', () => {
    const c = socket.room;
    const room = rooms.get(c);
    if (!room || room.host !== socket.id) return;
    if (room.players.length < 1) return;
    room.started = true;
    room.seed = Date.now() % 100000;
    io.to(c).emit('start', {
      seed: room.seed,
      diff: room.diff,
      mapId: room.mapId,
      players: room.players.map(p => ({ slot: p.slot, name: p.name }))
    });
    io.emit('room_list', publicRoomList());
  });

  socket.on('input', (data) => {
    const c = socket.room;
    if (!c) return;
    socket.to(c).emit('input', { slot: socket.slot, ...data });
  });

  socket.on('state', (data) => {
    const c = socket.room;
    if (!c) return;
    socket.to(c).emit('state', { slot: socket.slot, ...data });
  });

  socket.on('event', (data) => {
    const c = socket.room;
    if (!c) return;
    socket.to(c).emit('event', { slot: socket.slot, ...data });
  });

  socket.on('disconnect', () => {
    const c = socket.room;
    if (!c) return;
    const room = rooms.get(c);
    if (!room) return;
    room.players = room.players.filter(p => p.id !== socket.id);
    if (room.players.length === 0) rooms.delete(c);
    else {
      if (room.host === socket.id) room.host = room.players[0].id;
      io.to(c).emit('lobby', lobbyState(c));
      io.to(c).emit('peer_left', { left: socket.id });
    }
    io.emit('room_list', publicRoomList());
  });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`Peak Pact online: http://0.0.0.0:${PORT}`);
});
