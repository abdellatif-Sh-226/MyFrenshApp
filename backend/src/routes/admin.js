import { Router } from 'express';
import { prisma } from '../db.js';
import { requireAuth, requireAdmin } from '../middleware/auth.js';
import { computeUserScore } from '../score.js';

const router = Router();
router.use(requireAuth, requireAdmin);

// ---------- Units ----------
router.post('/units', async (req, res) => {
  const { unitNumber, difficulty, questions } = req.body || {};
  if (!unitNumber || !difficulty || !Array.isArray(questions) || questions.length === 0) {
    return res.status(400).json({ error: 'unitNumber, difficulty and questions are required' });
  }
  const num = Number(unitNumber);
  const existing = await prisma.unit.findUnique({ where: { unitNumber: num } });
  if (existing) return res.status(409).json({ error: 'Unit already exists' });
  const unit = await prisma.unit.create({ data: { unitNumber: num, difficulty, questions } });
  res.status(201).json(unit);
});

router.put('/units/:unitNumber', async (req, res) => {
  const num = Number(req.params.unitNumber);
  const existing = await prisma.unit.findUnique({ where: { unitNumber: num } });
  if (!existing) return res.status(404).json({ error: 'Unit not found' });
  const { difficulty, questions } = req.body || {};
  const unit = await prisma.unit.update({
    where: { id: existing.id },
    data: {
      difficulty: difficulty ?? existing.difficulty,
      questions: questions ?? existing.questions,
    },
  });
  res.json(unit);
});

router.delete('/units/:unitNumber', async (req, res) => {
  const num = Number(req.params.unitNumber);
  const existing = await prisma.unit.findUnique({ where: { unitNumber: num } });
  if (!existing) return res.status(404).json({ error: 'Unit not found' });
  await prisma.unit.delete({ where: { id: existing.id } });
  res.json({ ok: true });
});

// ---------- Stories ----------
router.post('/stories', async (req, res) => {
  const { title, content, questions } = req.body || {};
  if (!title || !content || !Array.isArray(questions)) {
    return res.status(400).json({ error: 'title, content and questions are required' });
  }
  const story = await prisma.story.create({ data: { title, content, questions } });
  res.status(201).json(story);
});

router.put('/stories/:id', async (req, res) => {
  const existing = await prisma.story.findUnique({ where: { id: Number(req.params.id) } });
  if (!existing) return res.status(404).json({ error: 'Story not found' });
  const { title, content, questions } = req.body || {};
  const story = await prisma.story.update({
    where: { id: existing.id },
    data: {
      title: title ?? existing.title,
      content: content ?? existing.content,
      questions: questions ?? existing.questions,
    },
  });
  res.json(story);
});

router.delete('/stories/:id', async (req, res) => {
  const existing = await prisma.story.findUnique({ where: { id: Number(req.params.id) } });
  if (!existing) return res.status(404).json({ error: 'Story not found' });
  await prisma.story.delete({ where: { id: existing.id } });
  res.json({ ok: true });
});

// ---------- Courses ----------
router.post('/courses', async (req, res) => {
  const { title, description, iconKey, lessons, questions } = req.body || {};
  if (!title || !Array.isArray(lessons) || !Array.isArray(questions)) {
    return res.status(400).json({ error: 'title, lessons and questions are required' });
  }
  const course = await prisma.course.create({
    data: { title, description: description || '', iconKey: iconKey || 'question', lessons, questions },
  });
  res.status(201).json(course);
});

router.put('/courses/:id', async (req, res) => {
  const existing = await prisma.course.findUnique({ where: { id: Number(req.params.id) } });
  if (!existing) return res.status(404).json({ error: 'Course not found' });
  const { title, description, iconKey, lessons, questions } = req.body || {};
  const course = await prisma.course.update({
    where: { id: existing.id },
    data: {
      title: title ?? existing.title,
      description: description ?? existing.description,
      iconKey: iconKey ?? existing.iconKey,
      lessons: lessons ?? existing.lessons,
      questions: questions ?? existing.questions,
    },
  });
  res.json(course);
});

router.delete('/courses/:id', async (req, res) => {
  const existing = await prisma.course.findUnique({ where: { id: Number(req.params.id) } });
  if (!existing) return res.status(404).json({ error: 'Course not found' });
  await prisma.course.delete({ where: { id: existing.id } });
  res.json({ ok: true });
});

// ---------- Users ----------
router.get('/users', async (req, res) => {
  const users = await prisma.user.findMany({ include: { progress: true } });
  res.json(
    users.map((u) => {
      const score = computeUserScore(u.progress);
      return {
        id: u.id,
        username: u.username,
        isAdmin: u.isAdmin,
        profilePhoto: u.profilePhoto,
        lastActiveAt: u.lastActiveAt,
        createdAt: u.createdAt,
        score: score.total,
        quizTotal: score.quizTotal,
        writingTotal: score.writingTotal,
        progress: u.progress.map((p) => ({
          unitNumber: p.unitNumber,
          bestScore: p.bestScore,
          writingBestScore: p.writingBestScore,
        })),
      };
    }),
  );
});

router.delete('/users/:id', async (req, res) => {
  const id = Number(req.params.id);
  if (id === req.user.id) {
    return res.status(400).json({ error: 'You cannot delete your own account' });
  }
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) return res.status(404).json({ error: 'User not found' });
  await prisma.user.delete({ where: { id } });
  res.json({ ok: true });
});

export default router;
