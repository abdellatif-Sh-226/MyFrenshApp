import { Router } from 'express';
import { prisma } from '../db.js';
import { requireAuth } from '../middleware/auth.js';
import { computeUserScore } from '../score.js';

const router = Router();
router.use(requireAuth);

router.get('/me/progress', async (req, res) => {
  const userId = req.user.id;
  const progress = await prisma.progress.findMany({ where: { userId } });
  const mistakes = await prisma.mistake.findMany({ where: { userId }, orderBy: { timestamp: 'desc' } });
  const scores = {};
  const writingScores = {};
  for (const p of progress) {
    scores[p.unitNumber] = p.bestScore;
    writingScores[p.unitNumber] = p.writingBestScore;
  }
  res.json({
    scores,
    writingScores,
    mistakes: mistakes.map((m) => ({
      id: m.id,
      word: m.word,
      meaning: m.meaning,
      wrongAnswer: m.wrongAnswer,
      unitNumber: m.unitNumber,
      timestamp: m.timestamp,
    })),
  });
});

router.put('/me/progress/:unitNumber', async (req, res) => {
  const userId = req.user.id;
  const unitNumber = Number(req.params.unitNumber);
  const score = Math.max(0, Math.min(Number(req.body?.score ?? 0), 100));
  const existing = await prisma.progress.findUnique({ where: { userId_unitNumber: { userId, unitNumber } } });
  const best = Math.max(existing?.bestScore ?? 0, score);
  await prisma.progress.upsert({
    where: { userId_unitNumber: { userId, unitNumber } },
    update: { bestScore: best },
    create: { userId, unitNumber, bestScore: best },
  });
  res.json({ unitNumber, bestScore: best });
});

router.put('/me/writing/:unitNumber', async (req, res) => {
  const userId = req.user.id;
  const unitNumber = Number(req.params.unitNumber);
  const score = Math.max(0, Math.min(Number(req.body?.score ?? 0), 100));
  const existing = await prisma.progress.findUnique({ where: { userId_unitNumber: { userId, unitNumber } } });
  const best = Math.max(existing?.writingBestScore ?? 0, score);
  await prisma.progress.upsert({
    where: { userId_unitNumber: { userId, unitNumber } },
    update: { writingBestScore: best },
    create: { userId, unitNumber, writingBestScore: best },
  });
  res.json({ unitNumber, writingBestScore: best });
});

router.post('/me/mistakes', async (req, res) => {
  const userId = req.user.id;
  const list = Array.isArray(req.body?.mistakes) ? req.body.mistakes : [];
  await prisma.mistake.deleteMany({ where: { userId } });
  if (list.length > 0) {
    await prisma.mistake.createMany({
      data: list.map((m) => ({
        userId,
        word: String(m.word ?? ''),
        meaning: String(m.meaning ?? ''),
        wrongAnswer: String(m.wrongAnswer ?? ''),
        unitNumber: Number(m.unitNumber ?? 0),
      })),
    });
  }
  const mistakes = await prisma.mistake.findMany({ where: { userId }, orderBy: { timestamp: 'desc' } });
  res.json(mistakes);
});

router.delete('/me/progress', async (req, res) => {
  const userId = req.user.id;
  await prisma.progress.deleteMany({ where: { userId } });
  await prisma.mistake.deleteMany({ where: { userId } });
  res.json({ ok: true });
});

router.get('/me/score', async (req, res) => {
  const progress = await prisma.progress.findMany({ where: { userId: req.user.id } });
  res.json(computeUserScore(progress));
});

export default router;
