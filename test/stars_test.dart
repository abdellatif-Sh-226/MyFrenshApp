import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:french_vocabulary_master/models/unit_model.dart';
import 'package:french_vocabulary_master/providers/progress_provider.dart';
import 'package:french_vocabulary_master/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Unit.starsForScore', () {
    test('returns 0 stars below 16', () {
      expect(Unit.starsForScore(0), 0);
      expect(Unit.starsForScore(15), 0);
    });

    test('returns 1 star for 16-17', () {
      expect(Unit.starsForScore(16), 1);
      expect(Unit.starsForScore(17), 1);
    });

    test('returns 2 stars for 18-19', () {
      expect(Unit.starsForScore(18), 2);
      expect(Unit.starsForScore(19), 2);
    });

    test('returns 3 stars for 20', () {
      expect(Unit.starsForScore(20), 3);
    });
  });

  group('writing score persistence', () {
    test('saves and returns writing best score per unit', () async {
      SharedPreferences.setMockInitialValues({});

      final service = ProgressService();
      await service.init();
      await service.resetAllProgress();

      final provider = ProgressProvider(service);
      await provider.loadProgress();
      expect(provider.getWritingBestScore(1), 0);

      await provider.updateWritingScore(1, 14);
      await provider.loadProgress();
      expect(provider.getWritingBestScore(1), 14);

      await provider.updateWritingScore(1, 18);
      await provider.loadProgress();
      expect(provider.getWritingBestScore(1), 18);

      await provider.updateWritingScore(1, 15);
      await provider.loadProgress();
      expect(provider.getWritingBestScore(1), 18);
    });

    test('updateWritingScore keeps the highest score', () async {
      SharedPreferences.setMockInitialValues({});

      final service = ProgressService();
      await service.init();
      await service.resetAllProgress();

      final provider = ProgressProvider(service);
      await provider.updateWritingScore(2, 16);
      await provider.updateWritingScore(2, 19);
      await provider.updateWritingScore(2, 5);
      await provider.loadProgress();
      expect(provider.getWritingBestScore(2), 19);
    });
  });
}
