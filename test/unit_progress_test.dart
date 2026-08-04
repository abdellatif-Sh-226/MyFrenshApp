import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:french_vocabulary_master/models/unit_model.dart';
import 'package:french_vocabulary_master/providers/progress_provider.dart';
import 'package:french_vocabulary_master/services/progress_service.dart';

Unit _unit(
  int number, {
  String category = 'noms',
  int order = 1,
  List<int> prerequisites = const [],
}) {
  return Unit(
    unitNumber: number,
    title: 'Unit $number',
    category: UnitCategory.fromString(category),
    difficulty: 'Beginner',
    order: order,
    prerequisites: prerequisites,
    questions: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final units = [
    _unit(1, order: 1),
    _unit(2, order: 2),
    _unit(3, order: 3),
    _unit(6, category: 'verbes', order: 1),
    _unit(7, category: 'verbes', order: 2),
    _unit(11, category: 'phrases', order: 1, prerequisites: [2, 7]),
  ];

  test('unit 2 stays locked until unit 1 score reaches unlockScore', () async {
    SharedPreferences.setMockInitialValues({});

    final service = ProgressService();
    await service.init();
    await service.resetAllProgress();

    final provider = ProgressProvider(service);
    expect(provider.canOpenUnit(units[0], units), isTrue);
    expect(provider.canOpenUnit(units[1], units), isFalse);

    await service.saveBestScore(1, 18);
    await provider.loadProgress();
    expect(provider.canOpenUnit(units[1], units), isTrue);
  });

  test('first lesson of every category is unlocked', () async {
    SharedPreferences.setMockInitialValues({});
    final service = ProgressService();
    await service.init();
    await service.resetAllProgress();

    final provider = ProgressProvider(service);
    expect(provider.canOpenUnit(units[3], units), isTrue); // verbes lesson 1
    expect(provider.canOpenUnit(units[5], units), isTrue); // phrases lesson 1
  });
}
