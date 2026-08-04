import { Router } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../db.js';

const router = Router();

function sign(user) {
  return jwt.sign(
    { id: user.id, username: user.username, isAdmin: user.isAdmin },
    process.env.JWT_SECRET,
    { expiresIn: '7d' },
  );
}

function publicUser(user) {
  return { id: user.id, username: user.username, isAdmin: user.isAdmin, profilePhoto: user.profilePhoto };
}

router.post('/register', async (req, res) => {
  const { username, password } = req.body || {};
  const name = String(username || '').trim();
  if (!/^[A-Za-z0-9_]{3,20}$/.test(name)) {
    return res
      .status(400)
      .json({ error: 'Username must be 3-20 characters (letters, numbers, underscore)' });
  }
  if (!password || password.length < 4) {
    return res.status(400).json({ error: 'Password must be at least 4 characters' });
  }
  const existing = await prisma.user.findUnique({ where: { username: name } });
  if (existing) {
    return res.status(409).json({ error: 'Username already taken' });
  }
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.create({ data: { username: name, passwordHash } });
  res.status(201).json({ token: sign(user), user: publicUser(user) });
});

router.post('/login', async (req, res) => {
  const { username, password } = req.body || {};
  const name = String(username || '').trim();
  const user = await prisma.user.findUnique({ where: { username: name } });
  if (!user) {
    return res.status(401).json({ error: 'Invalid username or password' });
  }
  const ok = await bcrypt.compare(password || '', user.passwordHash);
  if (!ok) {
    return res.status(401).json({ error: 'Invalid username or password' });
  }
  res.json({ token: sign(user), user: publicUser(user) });
});

export default router;
