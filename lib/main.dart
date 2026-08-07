import 'package:flutter/material.dart';
import 'spell_checker.dart';

void main() {
  runApp(const SpellCheckerApp());
}

class SpellCheckerApp extends StatelessWidget {
  const SpellCheckerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpellChecker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SpellCheckerHomePage(),
    );
  }
}

class SpellCheckerHomePage extends StatefulWidget {
  const SpellCheckerHomePage({super.key});

  @override
  State<SpellCheckerHomePage> createState() => _SpellCheckerHomePageState();
}

class _SpellCheckerHomePageState extends State<SpellCheckerHomePage> {
  final _controller = TextEditingController();
  final _engine = SpellCheckerEngine();
  List<SpellIssue> _issues = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkText() {
    setState(() {
      _issues = _engine.check(_controller.text);
    });
  }

  void _clearText() {
    _controller.clear();
    setState(() => _issues = const []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpellChecker'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Write or paste text below, then check it for unknown words.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _controller,
                  expands: true,
                  maxLines: null,
                  minLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: const InputDecoration(
                    hintText: 'Start writing here…',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _checkText,
                    icon: const Icon(Icons.spellcheck),
                    label: const Text('Check spelling'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _clearText,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ResultPanel(issues: _issues),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  const _ResultPanel({required this.issues});

  final List<SpellIssue> issues;

  @override
  Widget build(BuildContext context) {
    if (issues.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No unknown words found yet.'),
        ),
      );
    }

    final uniqueWords = issues.map((issue) => issue.word).toSet().toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${issues.length} possible spelling issue${issues.length == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(uniqueWords.join(', ')),
          ],
        ),
      ),
    );
  }
}
