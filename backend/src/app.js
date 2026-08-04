import express from 'express';
import cors from 'cors';
import { prisma } from './db.js';
import authRoutes from './routes/auth.js';
import contentRoutes from './routes/content.js';
import adminRoutes from './routes/admin.js';
import progressRoutes from './routes/progress.js';
import friendsRoutes from './routes/friends.js';
import { requireAuth } from './middleware/auth.js';

export function createApp() {
  const app = express();
  app.use(cors());
  app.use(express.json({ limit: '2mb' }));

  app.get('/api/health', (req, res) => res.json({ ok: true }));

  app.use('/api/auth', authRoutes);
  app.use('/api', contentRoutes);
  app.use('/api/admin', adminRoutes);
  app.use('/api', progressRoutes);
  app.use('/api/friends', friendsRoutes);

  app.use('/api/me', requireAuth, async (req, res) => {
    const user = await prisma.user.findUnique({ where: { id: req.user.id } });
    res.json({ username: user.username, isAdmin: user.isAdmin, profilePhoto: user.profilePhoto });
  });

  app.use((err, req, res, next) => {
    console.error(err);
    res.status(500).json({ error: 'Internal server error' });
  });

  return app;
}
