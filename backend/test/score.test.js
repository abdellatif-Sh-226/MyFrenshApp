import { test } from 'node:test';
import assert from 'node:assert/strict';
import { starsForScore, computeUserScore } from '../src/score.js';

test('starsForScore thresholds', () => {
  assert.equal(starsForScore(0), 0);
  assert.equal(starsForScore(15), 0);
  assert.equal(starsForScore(16), 1);
  assert.equal(starsForScore(17), 1);
  assert.equal(starsForScore(18), 2);
  assert.equal(starsForScore(19), 2);
  assert.equal(starsForScore(20), 3);
});

test('computeUserScore uses best tier, never adds', () => {
  assert.equal(computeUserScore([{ bestScore: 16, writingBestScore: 0 }]).total, 20);
  assert.equal(computeUserScore([{ bestScore: 18, writingBestScore: 0 }]).total, 30);
  assert.equal(computeUserScore([{ bestScore: 20, writingBestScore: 0 }]).total, 50);
});

test('computeUserScore writing tiers', () => {
  assert.equal(computeUserScore([{ bestScore: 20, writingBestScore: 16 }]).total, 80);
  assert.equal(computeUserScore([{ bestScore: 20, writingBestScore: 18 }]).total, 90);
  assert.equal(computeUserScore([{ bestScore: 20, writingBestScore: 20 }]).total, 100);
});

test('computeUserScore sums multiple units', () => {
  const s = computeUserScore([
    { bestScore: 20, writingBestScore: 0 },
    { bestScore: 18, writingBestScore: 0 },
    { bestScore: 16, writingBestScore: 0 },
  ]);
  assert.equal(s.total, 100);
  assert.equal(s.quizTotal, 100);
});
