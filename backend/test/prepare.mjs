import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const backendDir = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const env = { ...process.env, DATABASE_URL: 'file:./test.db' };

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
