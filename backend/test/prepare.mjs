import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const backendDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const dbUrl = process.env.TEST_DATABASE_URL || process.env.DATABASE_URL;
if (!dbUrl || dbUrl.includes('PASTE_NEON_URL_HERE') || dbUrl.startsWith('postgresql://user:password@')) {
  console.error(
    'TEST_DATABASE_URL must point to a real (scratch) PostgreSQL database to run backend tests.\n' +
      'Example: TEST_DATABASE_URL="postgresql://user:pass@ep-xxx.region.aws.neon.tech/neondb?sslmode=require"',
  );
  process.exit(1);
}

const env = { ...process.env, DATABASE_URL: dbUrl };

function run(cmd, args) {
  const result = spawnSync(cmd, args, { stdio: 'inherit', cwd: backendDir, env });
  if (result.error) {
    console.error(result.error.message);
  }
  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }
}

const prismaCli = path.join(backendDir, 'node_modules', 'prisma', 'build', 'index.js');
run(process.execPath, [prismaCli, 'db', 'push']);
run(process.execPath, ['src/seed.js']);
