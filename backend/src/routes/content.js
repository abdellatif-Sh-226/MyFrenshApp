import { Router } from 'express';
import { prisma } from '../db.js';
import { requireAuth } from '../middleware/auth.js';

const router = Router();
router.use(requireAuth);

router.get('/units', async (req, res) => {
  const units = await prisma.unit.findMany({ orderBy: { unitNumber: 'asc' } });
  res.json(
    units.map((u) => ({
      unitNumber: u.unitNumber,
      title: u.title,
      category: u.category,
      difficulty: u.difficulty,
      order: u.order,
      prerequisites: u.prerequisites,
      questions: u.questions,
    })),
  );
});

router.get('/stories', async (req, res) => {
  const stories = await prisma.story.findMany({ orderBy: { id: 'asc' } });
  res.json(
    stories.map((s) => ({
      id: s.id,
      title: s.title,
      content: s.content,
      questions: s.questions,
    })),
  );
});

router.get('/courses', async (req, res) => {
  const courses = await prisma.course.findMany({ orderBy: { id: 'asc' } });
  res.json(
    courses.map((c) => ({
      id: c.id,
      title: c.title,
      description: c.description,
      iconKey: c.iconKey,
      lessons: c.lessons,
      questions: c.questions,
    })),
  );
});

export default router;
