import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:french_vocabulary_master/providers/progress_provider.dart';
import 'package:french_vocabulary_master/services/progress_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('unit 2 stays locked until unit 1 score reaches passThreshold', () async {
    SharedPreferences.setMockInitialValues({});

    final service = ProgressService();
    await service.init();
    await service.resetAllProgress();

    final provider = ProgressProvider(service);
    expect(provider.canOpenUnit(1), isTrue);
    expect(provider.canOpenUnit(2), isFalse);

    await service.saveBestScore(1, 18);
    await provider.loadProgress();
    expect(provider.canOpenUnit(2), isTrue);
  });
}
