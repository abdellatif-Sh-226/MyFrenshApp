import { readFileSync } from 'node:fs';
import bcrypt from 'bcryptjs';
import { prisma } from './db.js';
import { seedStories, seedCourses } from './data/seedContent.js';

const ADMIN_USERNAME = process.env.ADMIN_USERNAME || 'admin';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';

// Unit definitions: 1-5 Noms, 6-10 Verbes, 11-15 Phrases
const UNIT_DEFS = [
  { file: 'noms1_colors',   category: 'noms',    title: 'Les Couleurs',       difficulty: 'Beginner', order: 1, prerequisites: null },
  { file: 'noms2_numbers',  category: 'noms',    title: 'Les Nombres',        difficulty: 'Beginner', order: 2, prerequisites: null },
  { file: 'noms3_animals',  category: 'noms',    title: 'Les Animaux',        difficulty: 'Elementary', order: 3, prerequisites: null },
  { file: 'noms4_food',     category: 'noms',    title: 'La Nourriture',      difficulty: 'Elementary', order: 4, prerequisites: null },
  { file: 'noms5_family',   category: 'noms',    title: 'La Famille',         difficulty: 'Intermediate', order: 5, prerequisites: null },
  { file: 'verbes1_physical', category: 'verbes', title: 'Les Actions Physiques', difficulty: 'Elementary', order: 1, prerequisites: null },
  { file: 'verbes2_daily',  category: 'verbes',  title: 'Les Verbes du Quotidien', difficulty: 'Elementary', order: 2, prerequisites: null },
  { file: 'verbes3_movement', category: 'verbes', title: 'Le Mouvement',      difficulty: 'Intermediate', order: 3, prerequisites: null },
  { file: 'verbes4_mental', category: 'verbes',  title: 'Les Verbes Mentaux', difficulty: 'Upper Intermediate', order: 4, prerequisites: null },
  { file: 'verbes5_emotions', category: 'verbes', title: 'Les Émotions',      difficulty: 'Advanced', order: 5, prerequisites: null },
  { file: 'phrases1_simple',   category: 'phrases', title: 'Phrases Simples',      difficulty: 'Elementary', order: 1, prerequisites: [2, 7] },
  { file: 'phrases2_daily',    category: 'phrases', title: 'Phrases du Quotidien', difficulty: 'Intermediate', order: 2, prerequisites: [3, 8] },
  { file: 'phrases3_advanced', category: 'phrases', title: 'Phrases Avancées',     difficulty: 'Upper Intermediate', order: 3, prerequisites: [4, 9] },
  { file: 'phrases4_social',   category: 'phrases', title: 'Phrases Sociales',     difficulty: 'Advanced', order: 4, prerequisites: [5, 10] },
  { file: 'phrases5_expert',   category: 'phrases', title: 'Phrases Expertes',     difficulty: 'Expert', order: 5, prerequisites: [5, 10] },
];

async function seedAdmin() {
  const passwordHash = await bcrypt.hash(ADMIN_PASSWORD, 10);
  const existing = await prisma.user.findUnique({ where: { username: ADMIN_USERNAME } });
  if (existing) {
    await prisma.user.update({ where: { id: existing.id }, data: { isAdmin: true, passwordHash } });
    console.log(`Admin updated: ${ADMIN_USERNAME}`);
  } else {
    await prisma.user.create({ data: { username: ADMIN_USERNAME, passwordHash, isAdmin: true } });
    console.log(`Admin created: ${ADMIN_USERNAME}`);
  }
}

async function seedUnits() {
  for (let i = 1; i <= UNIT_DEFS.length; i++) {
    const def = UNIT_DEFS[i - 1];
    const url = new URL(`../../assets/data/${def.file}.json`, import.meta.url);
    const questions = JSON.parse(readFileSync(url, 'utf8'));
    const data = {
      title: def.title,
      category: def.category,
      difficulty: def.difficulty,
      order: def.order,
      prerequisites: def.prerequisites,
      questions,
    };
    await prisma.unit.upsert({
      where: { unitNumber: i },
      update: data,
      create: { unitNumber: i, ...data },
    });
  }
  console.log(`Units seeded (${UNIT_DEFS.length})`);
}

async function seedStoriesIntoDb() {
  for (const s of seedStories) {
    const existing = await prisma.story.findFirst({ where: { title: s.title } });
    if (existing) {
      await prisma.story.update({ where: { id: existing.id }, data: s });
    } else {
      await prisma.story.create({ data: s });
    }
  }
  console.log(`Stories seeded (${seedStories.length})`);
}

async function seedCoursesIntoDb() {
  for (const c of seedCourses) {
    const existing = await prisma.course.findFirst({ where: { title: c.title } });
    if (existing) {
      await prisma.course.update({ where: { id: existing.id }, data: c });
    } else {
      await prisma.course.create({ data: c });
    }
  }
  console.log(`Courses seeded (${seedCourses.length})`);
}

async function main() {
  await seedAdmin();
  await seedUnits();
  await seedStoriesIntoDb();
  await seedCoursesIntoDb();
  console.log('Seed complete.');
}

main()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
