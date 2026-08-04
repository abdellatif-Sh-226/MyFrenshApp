import { readFileSync } from 'node:fs';
import bcrypt from 'bcryptjs';
import { prisma } from './db.js';
import { seedStories, seedCourses } from './data/seedContent.js';

const ADMIN_USERNAME = process.env.ADMIN_USERNAME || 'admin';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD || 'admin123';

const UNIT_DIFFICULTIES = [
  'Beginner',
  'Beginner',
  'Elementary',
  'Elementary',
  'Intermediate',
  'Intermediate',
  'Upper Intermediate',
  'Advanced',
  'Advanced',
  'Expert',
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
  for (let i = 1; i <= 10; i++) {
    const url = new URL(`../../assets/data/unit${i}.json`, import.meta.url);
    const questions = JSON.parse(readFileSync(url, 'utf8'));
    const difficulty = UNIT_DIFFICULTIES[i - 1];
    await prisma.unit.upsert({
      where: { unitNumber: i },
      update: { difficulty, questions },
      create: { unitNumber: i, difficulty, questions },
    });
  }
  console.log('Units seeded (10)');
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
