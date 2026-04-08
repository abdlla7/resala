import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      question: '1. الهدف الأساسي للجنة المعارض هو؟',
      options: [
        'بيع الأجهزة',
        'توفير ملابس للأسر المحتاجة بأسعار رمزية',
        'تعليم الأطفال',
        'تنظيم رحلات',
      ],
      correctAnswerIndex: 1, // B
    ),
    QuizQuestion(
      question: '2. لجنة إطعام تهتم بـ؟',
      options: [
        'توزيع ألعاب',
        'توصيل وجبات غذائية للأسر المحتاجة',
        'تنظيم حفلات',
        'جمع ملابس',
      ],
      correctAnswerIndex: 1, // B
    ),
    QuizQuestion(
      question: '3. فكرة السوق تعتمد على؟',
      options: [
        'بيع سلع بسعر مرتفع',
        'بيع سلع مجانية فقط',
        'بيع بسعر رمزي لتغطية التكلفة',
        'بيع إلكترونيات',
      ],
      correctAnswerIndex: 2, // C
    ),
    QuizQuestion(
      question: '4. لجنة أبطال تحدي تركز على؟',
      options: ['كبار السن', 'الأطفال وإسعادهم', 'التجار', 'الطلاب الجامعيين'],
      correctAnswerIndex: 1, // B
    ),
    QuizQuestion(
      question: '5. وظيفة لجنة تحقيق أماني هي؟',
      options: [
        'بيع منتجات',
        'تقديم دعم نفسي ومعنوي وتحقيق الأمنيات',
        'تدريب رياضي',
        'جمع تبرعات فقط',
      ],
      correctAnswerIndex: 1, // B
    ),
    QuizQuestion(
      question: '6. نشر الأخلاقيات يهدف إلى؟',
      options: [
        'الربح المادي',
        'تعزيز السلوك الإيجابي داخل المجتمع',
        'بيع كتب',
        'تنظيم مسابقات رياضية فقط',
      ],
      correctAnswerIndex: 1, // B
    ),
    QuizQuestion(
      question: '7. دور العلاقات العامة الأساسي؟',
      options: [
        'توزيع ملابس',
        'التواصل الخارجي وجذب متطوعين وشركاء',
        'الطبخ',
        'التعليم',
      ],
      correctAnswerIndex: 1, // B
    ),
    QuizQuestion(
      question: '8. لجنة المتابعة تهتم بـ؟',
      options: [
        'تحفيز المتطوعين ومتابعة نشاطهم',
        'بيع سلع',
        'تنظيم حفلات',
        'تصميم لوجو',
      ],
      correctAnswerIndex: 0, // A
    ),
    QuizQuestion(
      question: '9. لجنة الميديا مسؤولة عن؟',
      options: [
        'الطبخ',
        'صناعة المحتوى والتصوير والنشر',
        'جمع الملابس',
        'التدريب البدني',
      ],
      correctAnswerIndex: 1, // B
    ),
    QuizQuestion(
      question: '10. لجنة أشبال تعمل على؟',
      options: [
        'تدريب الأطفال على القيادة والعمل التطوعي',
        'بيع الطعام',
        'إدارة السوق',
        'التواصل مع الشركات',
      ],
      correctAnswerIndex: 0, // A
    ),
  ];

  void _answerQuestion(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index == _questions[_currentQuestionIndex].correctAnswerIndex) {
        _score++;
      }
    });

    // Auto move to next question after delay
    Future.delayed(const Duration(seconds: 1, milliseconds: 500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      _showResult();
    }
  }

  void _showResult() {
    // Navigate to results or show dialog
    // For now, let's just show a simple result view in place
    setState(() {
      _currentQuestionIndex = _questions.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_currentQuestionIndex >= _questions.length) {
      return _buildResultScreen(theme, isDark);
    }

    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اختبار اللجان',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'السؤال ${_currentQuestionIndex + 1} من ${_questions.length}',
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2BEE4B),
              ),
            ),
            const SizedBox(height: 32),
            FadeInDown(
              child: Text(
                question.question,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: question.options.length,
                itemBuilder: (context, index) {
                  final option = question.options[index];
                  Color? buttonColor;
                  if (_isAnswered) {
                    if (index == question.correctAnswerIndex) {
                      buttonColor = Colors.green.shade100;
                    } else if (index == _selectedAnswerIndex) {
                      buttonColor = Colors.red.shade100;
                    }
                  }

                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _answerQuestion(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: buttonColor ?? theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  _isAnswered &&
                                      index == question.correctAnswerIndex
                                  ? Colors.green
                                  : (_isAnswered &&
                                            index == _selectedAnswerIndex
                                        ? Colors.red
                                        : Colors.grey.withValues(alpha: 0.3)),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    color:
                                        _isAnswered &&
                                            (index ==
                                                    question
                                                        .correctAnswerIndex ||
                                                index == _selectedAnswerIndex)
                                        ? Colors.black87
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                              const SizedBox(width: 12),
                              CircleAvatar(
                                radius: 12,
                                backgroundColor:
                                    _isAnswered &&
                                        index == question.correctAnswerIndex
                                    ? Colors.green
                                    : (_isAnswered &&
                                              index == _selectedAnswerIndex
                                          ? Colors.red
                                          : Colors.grey.withValues(alpha: 0.3)),
                                child: Text(
                                  String.fromCharCode(
                                    65 + index,
                                  ), // A, B, C, D...
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen(ThemeData theme, bool isDark) {
    bool passed = _score >= (_questions.length / 2);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                child: Icon(
                  passed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  size: 100,
                  color: passed ? const Color(0xFF2BEE4B) : Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                child: Text(
                  passed ? 'مبروك!' : 'حاول مرة أخرى',
                  style: GoogleFonts.cairo(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'لقد أجبت بشكل صحيح على $_score من ${_questions.length}',
                  style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 48),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (passed) {
                        context.go(
                          '/dashboard',
                        ); // Go back to dashboard on success
                      } else {
                        setState(() {
                          _currentQuestionIndex = 0;
                          _score = 0;
                          _selectedAnswerIndex = null;
                          _isAnswered = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: passed
                          ? const Color(0xFF2BEE4B)
                          : theme.primaryColor,
                      foregroundColor: const Color.fromARGB(255, 255, 48, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      passed ? 'العودة للرئيسية' : 'إعادة الاختبار',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}
