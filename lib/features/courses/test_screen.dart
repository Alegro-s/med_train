import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/test_service.dart';
import '../../services/auth_service.dart';
import '../../models/test_result_model.dart';
import '../../widgets/loading_indicator.dart';

class TestScreen extends StatefulWidget {
  final String testId;
  const TestScreen({super.key, required this.testId});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late final TestService _testService;
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  Map<String, String?> _selectedAnswers = {};
  bool _isLoading = true;
  int? _score;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _testService = context.read<TestService>();
    _loadTest();
  }

  Future<void> _loadTest() async {
    final questions = await _testService.getQuestionsWithAnswers(widget.testId);
    setState(() {
      _questions = questions;
      _isLoading = false;
    });
  }

  void _submit() async {
    int correct = 0;
    for (var q in _questions) {
      final selected = _selectedAnswers[q['id']];
      if (selected != null) {
        final correctAnswer = (q['test_answers'] as List).firstWhere(
              (a) => a['is_correct'],
          orElse: () => null,
        );
        if (correctAnswer != null && correctAnswer['id'] == selected) {
          correct++;
        }
      }
    }
    final userId = context.read<AuthService>().currentUser!.id;
    final result = TestResult(
      id: '', 
      userId: userId,
      testId: widget.testId,
      score: correct,
      isPassed: correct >= _questions.length * 0.7,
      completedAt: DateTime.now(),
    );
    await _testService.saveTestResult(result);
    setState(() {
      _score = correct;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingIndicator());
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Результат')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Вы набрали $_score из ${_questions.length}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Вернуться к курсу'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final answers = List<Map<String, dynamic>>.from(question['test_answers']);
    return Scaffold(
      appBar: AppBar(title: Text('Вопрос ${_currentIndex + 1} из ${_questions.length}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question['question_text'], style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ...answers.map((a) => RadioListTile<String>(
              title: Text(a['answer_text']),
              value: a['id'],
              groupValue: _selectedAnswers[question['id']],
              onChanged: (val) => setState(() => _selectedAnswers[question['id']] = val),
            )),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentIndex > 0)
                  ElevatedButton(onPressed: () => setState(() => _currentIndex--), child: const Text('Назад')),
                if (_currentIndex < _questions.length - 1)
                  ElevatedButton(onPressed: () => setState(() => _currentIndex++), child: const Text('Далее')),
                if (_currentIndex == _questions.length - 1)
                  ElevatedButton(onPressed: _submit, child: const Text('Завершить')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}