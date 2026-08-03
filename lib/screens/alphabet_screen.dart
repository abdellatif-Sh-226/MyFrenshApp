import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alphabet')),
      body: const AlphabetGridView(),
    );
  }
}

class AlphabetGridView extends StatefulWidget {
  const AlphabetGridView({super.key});

  static const List<Map<String, String>> alphabet = [
    {'letter': 'A', 'sound': 'a'},
    {'letter': 'B', 'sound': 'b'},
    {'letter': 'C', 'sound': 'c'},
    {'letter': 'D', 'sound': 'd'},
    {'letter': 'E', 'sound': 'e'},
    {'letter': 'F', 'sound': 'f'},
    {'letter': 'G', 'sound': 'g'},
    {'letter': 'H', 'sound': 'h'},
    {'letter': 'I', 'sound': 'i'},
    {'letter': 'J', 'sound': 'j'},
    {'letter': 'K', 'sound': 'k'},
    {'letter': 'L', 'sound': 'l'},
    {'letter': 'M', 'sound': 'm'},
    {'letter': 'N', 'sound': 'n'},
    {'letter': 'O', 'sound': 'o'},
    {'letter': 'P', 'sound': 'p'},
    {'letter': 'Q', 'sound': 'q'},
    {'letter': 'R', 'sound': 'r'},
    {'letter': 'S', 'sound': 's'},
    {'letter': 'T', 'sound': 't'},
    {'letter': 'U', 'sound': 'u'},
    {'letter': 'V', 'sound': 'v'},
    {'letter': 'W', 'sound': 'w'},
    {'letter': 'X', 'sound': 'x'},
    {'letter': 'Y', 'sound': 'y'},
    {'letter': 'Z', 'sound': 'z'},
  ];

  @override
  State<AlphabetGridView> createState() => _AlphabetGridViewState();
}

class _AlphabetGridViewState extends State<AlphabetGridView> {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _configureTts();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setLanguage('fr-FR');
    await _flutterTts.setSpeechRate(0.7);
    await _flutterTts.setPitch(1.0);
  }

  void _playLetter(String letter) {
    _flutterTts.stop();
    _flutterTts.speak(letter);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Letter $letter'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: AlphabetGridView.alphabet.length,
      itemBuilder: (context, index) {
        final item = AlphabetGridView.alphabet[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _playLetter(item['letter']!),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item['letter']!,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.volume_up,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white38
                      : Colors.grey.shade500,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
