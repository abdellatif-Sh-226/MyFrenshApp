import { test, before, after, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import bcrypt from 'bcryptjs';
import { createApp } from '../src/app.js';
import { prisma } from '../src/db.js';

let server;
let base;

before(async () => {
  server = createApp().listen(0);
  await new Promise((resolve) => server.once('listening', resolve));
  base = `http://localhost:${server.address().port}`;
});

after(async () => {
  server.close();
  await prisma.$disconnect();
});

beforeEach(async () => {
  await prisma.friendship.deleteMany();
  await prisma.friendRequest.deleteMany();
  await prisma.mistake.deleteMany();
  await prisma.progress.deleteMany();
  await prisma.user.deleteMany();
});

async function api(method, path, { token, body } = {}) {
  const res = await fetch(base + path, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await res.text();
  const data = text ? JSON.parse(text) : null;
  return { status: res.status, data };
}

async function register(username, password = 'secret1') {
  return api('POST', '/api/auth/register', { body: { username, password } });
}

test('health check', async () => {
  const { status, data } = await api('GET', '/api/health');
  assert.equal(status, 200);
  assert.equal(data.ok, true);
});

test('register creates a user and login works', async () => {
  const reg = await register('alice');
  assert.equal(reg.status, 201);
  assert.ok(reg.data.token);
  assert.equal(reg.data.user.username, 'alice');

  const dup = await register('alice');
  assert.equal(dup.status, 409);

  const bad = await api('POST', '/api/auth/login', {
    body: { username: 'alice', password: 'wrong' },
  });
  assert.equal(bad.status, 401);

  const login = await api('POST', '/api/auth/login', {
    body: { username: 'alice', password: 'secret1' },
  });
  assert.equal(login.status, 200);
  assert.ok(login.data.token);
});

test('content endpoints require auth and return seeded data', async () => {
  const noAuth = await api('GET', '/api/units');
  assert.equal(noAuth.status, 401);

  const { data: reg } = await register('bob');
  const { status, data } = await api('GET', '/api/units', { token: reg.token });
  assert.equal(status, 200);
  assert.ok(data.length >= 10);
  assert.ok(data[0].questions.length > 0);

  const stories = await api('GET', '/api/stories', { token: reg.token });
  assert.equal(stories.status, 200);
  assert.ok(stories.data.length >= 3);

  const courses = await api('GET', '/api/courses', { token: reg.token });
  assert.equal(courses.status, 200);
  assert.ok(courses.data.length >= 1);
});

test('progress keeps the best score (replace, never lower)', async () => {
  const { data: reg } = await register('carol');
  const token = reg.token;

  await api('PUT', '/api/me/progress/1', { token, body: { score: 20 } });
  const r2 = await api('PUT', '/api/me/progress/1', { token, body: { score: 12 } });
  assert.equal(r2.data.bestScore, 20);

  await api('PUT', '/api/me/writing/1', { token, body: { score: 16 } });
  const r3 = await api('PUT', '/api/me/writing/1', { token, body: { score: 5 } });
  assert.equal(r3.data.writingBestScore, 16);

  const progress = await api('GET', '/api/me/progress', { token });
  assert.equal(progress.data.scores['1'], 20);
  assert.equal(progress.data.writingScores['1'], 16);
});

test('score is computed from stars server-side', async () => {
  const { data: reg } = await register('dave');
  const token = reg.token;
  await api('PUT', '/api/me/progress/1', { token, body: { score: 20 } });
  await api('PUT', '/api/me/progress/2', { token, body: { score: 18 } });
  await api('PUT', '/api/me/progress/3', { token, body: { score: 16 } });
  await api('PUT', '/api/me/writing/1', { token, body: { score: 18 } });

  const score = await api('GET', '/api/me/score', { token });
  assert.equal(score.data.total, 50 + 30 + 20 + 40);
});

test('mistakes are stored and returned', async () => {
  const { data: reg } = await register('erin');
  const token = reg.token;
  await api('POST', '/api/me/mistakes', {
    token,
    body: {
      mistakes: [
        { word: 'maison', meaning: 'منزل', wrongAnswer: 'مكتب', unitNumber: 1 },
      ],
    },
  });
  const progress = await api('GET', '/api/me/progress', { token });
  assert.equal(progress.data.mistakes.length, 1);
  assert.equal(progress.data.mistakes[0].word, 'maison');
});

test('friends flow: invite, accept, list with scores', async () => {
  const a = await register('friendA');
  const b = await register('friendB');
  const tokenA = a.data.token;
  const tokenB = b.data.token;

  const invite = await api('POST', '/api/friends/requests', {
    token: tokenA,
    body: { username: 'friendB' },
  });
  assert.equal(invite.status, 201);

  const selfInvite = await api('POST', '/api/friends/requests', {
    token: tokenA,
    body: { username: 'friendA' },
  });
  assert.equal(selfInvite.status, 400);

  const requests = await api('GET', '/api/friends/requests', { token: tokenB });
  assert.equal(requests.data.incoming.length, 1);

  await api('PUT', '/api/me/progress/1', { token: tokenB, body: { score: 20 } });

  const accept = await api('POST', `/api/friends/requests/${requests.data.incoming[0].id}/accept`, {
    token: tokenB,
  });
  assert.equal(accept.status, 200);

  const friendsA = await api('GET', '/api/friends', { token: tokenA });
  assert.equal(friendsA.data.length, 1);
  assert.equal(friendsA.data[0].username, 'friendB');
  assert.equal(friendsA.data[0].score, 50);
});

test('admin endpoints require admin role', async () => {
  const regular = await register('normie');
  const denied = await api('POST', '/api/admin/units', {
    token: regular.data.token,
    body: { unitNumber: 99, difficulty: 'Beginner', questions: [] },
  });
  assert.equal(denied.status, 403);

  const passwordHash = await bcrypt.hash('adminpass', 4);
  const admin = await prisma.user.create({
    data: { username: 'rootadmin', passwordHash, isAdmin: true },
  });
  const login = await api('POST', '/api/auth/login', {
    body: { username: 'rootadmin', password: 'adminpass' },
  });
  assert.equal(login.status, 200);

  const created = await api('POST', '/api/admin/units', {
    token: login.data.token,
    body: {
      unitNumber: 99,
      difficulty: 'Beginner',
      questions: [{ word: 'test', choices: ['a', 'b', 'c', 'd'], answer: 'a' }],
    },
  });
  assert.equal(created.status, 201);

  const del = await api('DELETE', '/api/admin/units/99', { token: login.data.token });
  assert.equal(del.status, 200);
});
