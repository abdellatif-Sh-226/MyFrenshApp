import { Router } from 'express';
import { prisma } from '../db.js';
import { requireAuth } from '../middleware/auth.js';
import { computeUserScore } from '../score.js';

const ONLINE_THRESHOLD_MS = 5 * 60 * 1000; // 5 minutes
const router = Router();

function isOnline(lastActiveAt) {
  return new Date(lastActiveAt).getTime() > Date.now() - ONLINE_THRESHOLD_MS;
}

function publicUserFields(user) {
  return {
    id: user.id,
    username: user.username,
    profilePhoto: user.profilePhoto,
    lastActiveAt: user.lastActiveAt,
    online: isOnline(user.lastActiveAt),
  };
}
router.use(requireAuth);

router.post('/requests', async (req, res) => {
  const name = String(req.body?.username || '').trim();
  if (!name) return res.status(400).json({ error: 'Username required' });
  if (name === req.user.username) {
    return res.status(400).json({ error: 'You cannot invite yourself' });
  }
  const target = await prisma.user.findUnique({ where: { username: name } });
  if (!target) return res.status(404).json({ error: 'User not found' });

  const alreadyFriends = await prisma.friendship.findFirst({
    where: {
      OR: [
        { userAId: req.user.id, userBId: target.id },
        { userAId: target.id, userBId: req.user.id },
      ],
    },
  });
  if (alreadyFriends) return res.status(409).json({ error: 'You are already friends' });

  const sent = await prisma.friendRequest.findFirst({
    where: { fromId: req.user.id, toId: target.id, status: 'pending' },
  });
  if (sent) return res.status(409).json({ error: 'Request already sent' });

  const incoming = await prisma.friendRequest.findFirst({
    where: { fromId: target.id, toId: req.user.id, status: 'pending' },
  });
  if (incoming) return res.status(409).json({ error: 'This user already invited you' });

  await prisma.friendRequest.create({ data: { fromId: req.user.id, toId: target.id } });
  res.status(201).json({ ok: true });
});

router.get('/requests', async (req, res) => {
  const incoming = await prisma.friendRequest.findMany({
    where: { toId: req.user.id, status: 'pending' },
    include: { from: true },
    orderBy: { createdAt: 'desc' },
  });
  const sent = await prisma.friendRequest.findMany({
    where: { fromId: req.user.id },
    include: { to: true },
    orderBy: { createdAt: 'desc' },
  });
  res.json({
    incoming: incoming.map((r) => ({ id: r.id, from: r.from.username, fromProfilePhoto: r.from.profilePhoto, fromLastActiveAt: r.from.lastActiveAt, fromOnline: isOnline(r.from.lastActiveAt), createdAt: r.createdAt })),
    sent: sent.map((r) => ({ id: r.id, to: r.to.username, status: r.status })),
  });
});

router.post('/requests/:id/accept', async (req, res) => {
  const request = await prisma.friendRequest.findFirst({
    where: { id: Number(req.params.id), toId: req.user.id, status: 'pending' },
  });
  if (!request) return res.status(404).json({ error: 'Request not found' });
  await prisma.$transaction([
    prisma.friendRequest.update({ where: { id: request.id }, data: { status: 'accepted' } }),
    prisma.friendship.create({ data: { userAId: request.fromId, userBId: request.toId } }),
  ]);
  res.json({ ok: true });
});

router.post('/requests/:id/decline', async (req, res) => {
  const request = await prisma.friendRequest.findFirst({
    where: { id: Number(req.params.id), toId: req.user.id, status: 'pending' },
  });
  if (!request) return res.status(404).json({ error: 'Request not found' });
  await prisma.friendRequest.update({ where: { id: request.id }, data: { status: 'declined' } });
  res.json({ ok: true });
});

router.get('/', async (req, res) => {
  const friendships = await prisma.friendship.findMany({
    where: { OR: [{ userAId: req.user.id }, { userBId: req.user.id }] },
    include: { userA: true, userB: true },
  });
  const friends = [];
  for (const f of friendships) {
    const other = f.userAId === req.user.id ? f.userB : f.userA;
    const progress = await prisma.progress.findMany({ where: { userId: other.id } });
    friends.push({
      ...publicUserFields(other),
      score: computeUserScore(progress).total,
      joinedAt: other.createdAt,
    });
  }
  friends.sort((a, b) => b.score - a.score);
  res.json(friends);
});

router.get('/leaderboard', async (req, res) => {
  const users = await prisma.user.findMany();
  const rows = [];
  for (const u of users) {
    const progress = await prisma.progress.findMany({ where: { userId: u.id } });
    rows.push({
      ...publicUserFields(u),
      score: computeUserScore(progress).total,
    });
  }
  rows.sort((a, b) => b.score - a.score);
  res.json(rows);
});

export default router;
