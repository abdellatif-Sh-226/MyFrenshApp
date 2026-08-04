// Star thresholds mirror the app: score >=16 -> 1 star, >=18 -> 2, >=20 -> 3.
const QUIZ_POINTS = { 1: 20, 2: 30, 3: 50 };
const WRITING_POINTS = { 1: 30, 2: 40, 3: 50 };

export function starsForScore(score) {
  if (score >= 20) return 3;
  if (score >= 18) return 2;
  if (score >= 16) return 1;
  return 0;
}

// Each unit contributes only its best tier (replace, never add).
export function computeUserScore(progressRows) {
  let quizTotal = 0;
  let writingTotal = 0;
  for (const p of progressRows) {
    quizTotal += QUIZ_POINTS[starsForScore(p.bestScore)] ?? 0;
    writingTotal += WRITING_POINTS[starsForScore(p.writingBestScore)] ?? 0;
  }
  return { total: quizTotal + writingTotal, quizTotal, writingTotal };
}
