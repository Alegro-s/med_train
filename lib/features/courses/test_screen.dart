import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/test_service.dart';
import '../../services/auth_service.dart';
import '../../models/test_result_model.dart';
import '../../widgets/loading_indicator.dart';
import '../../core/constants/colors.dart';

class TestScreen extends StatefulWidget {
  final String testId;
  final String moduleId;
  final String courseId;
  
  const TestScreen({
    super.key, 
    required this.testId,
    required this.moduleId,
    required this.courseId,
  });

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
          (a) => a['is_correct'] == true,
          orElse: () => null,
        );
        if (correctAnswer != null && correctAnswer['id'] == selected) {
          correct++;
        }
      }
    }

    final userId = context.read<AuthService>().currentUser!.id;
    final totalQuestions = _questions.length;
    final percentage = (correct / totalQuestions) * 100;
    final isPassed = percentage >= 70;

    final result = TestResult(
      id: '',
      userId: userId,
      testId: widget.testId,
      score: correct,
      isPassed: isPassed,
      completedAt: DateTime.now(),
    );
    
    await _testService.saveTestResult(result);
    
    setState(() {
      _score = correct;
      _submitted = true;
    });

    if (isPassed && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: LoadingIndicator());
    
    if (_submitted) {
      final total = _questions.length;
      final percentage = (_score! / total) * 100;
      final isPassed = percentage >= 70;

      return Scaffold(
        appBar: AppBar(title: const Text('Результат')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isPassed ? Icons.check_circle : Icons.cancel,
                  size: 80,
                  color: isPassed ? AppColors.success : AppColors.error,
                ),
                const SizedBox(height: 24),
                Text(
                  isPassed ? 'Тест пройден!' : 'Тест не пройден',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Правильных ответов: $_score из $total',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Результат: ${percentage.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, isPassed),
                  child: const Text('Вернуться к модулю'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];
    final answers = List<Map<String, dynamic>>.from(question['test_answers']);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Вопрос ${_currentIndex + 1} из ${_questions.length}'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  question['question_text'],
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Выберите правильный ответ:',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: answers.map((a) => RadioListTile<String>(
                  title: Text(a['answer_text']),
                  value: a['id'],
                  groupValue: _selectedAnswers[question['id']],
                  onChanged: (val) => setState(() => _selectedAnswers[question['id']] = val),
                  activeColor: AppColors.primary,
                )).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentIndex--),
                        child: const Text('Назад'),
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentIndex < _questions.length - 1
                          ? () => setState(() => _currentIndex++)
                          : _submit,
                      child: Text(_currentIndex < _questions.length - 1 ? 'Далее' : 'Завершить'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}