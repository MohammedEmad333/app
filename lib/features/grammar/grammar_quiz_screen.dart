import 'package:flutter/material.dart';
import 'grammar_lessons_screen.dart';
import 'grammar_progress_store.dart';

class GrammarQuizQuestion {
  const GrammarQuizQuestion(this.prompt, this.options, this.correctIndex);
  final String prompt;
  final List<String> options;
  final int correctIndex;
}

/// Curated practice questions for every standalone grammar topic.
final Map<int, List<GrammarQuizQuestion>> grammarExtraQuestions = {
  0: [
    GrammarQuizQuestion("He ___ my brother.", ["am","is","are"], 1),
    GrammarQuizQuestion("___ are my friends.", ["They","He","She"], 0),
  ],
  1: [
    GrammarQuizQuestion("I ___ happy.", ["is","am","are"], 1),
    GrammarQuizQuestion("She ___ a teacher.", ["are","am","is"], 2),
  ],
  2: [
    GrammarQuizQuestion("It is ___ orange.", ["an","a","the are"], 0),
    GrammarQuizQuestion("I see ___ dog.", ["an","a","are"], 1),
  ],
  3: [
    GrammarQuizQuestion("Three ___.", ["book","books","a book"], 1),
    GrammarQuizQuestion("Two ___.", ["children","child","childs"], 0),
  ],
  4: [
    GrammarQuizQuestion("He ___ milk.", ["like","likes","liking"], 1),
    GrammarQuizQuestion("They ___ every day.", ["plays","play","playing"], 1),
  ],
  5: [
    GrammarQuizQuestion("She ___ singing now.", ["am","are","is"], 2),
    GrammarQuizQuestion("I am ___ now.", ["read","reading","reads"], 1),
  ],
  6: [
    GrammarQuizQuestion("They ___ eat meat.", ["does not","do not","is not"], 1),
    GrammarQuizQuestion("She does not ___ tennis.", ["plays","play","playing"], 1),
  ],
  7: [
    GrammarQuizQuestion("___ you study English?", ["Does","Do","Is"], 1),
    GrammarQuizQuestion("Does she ___ books?", ["read","reads","reading"], 0),
  ],
  8: [
    GrammarQuizQuestion("She ___ yesterday.", ["walk","walked","walking"], 1),
    GrammarQuizQuestion("He ___ home last night.", ["go","went","going"], 1),
  ],
  9: [
    GrammarQuizQuestion("I will ___ tomorrow.", ["study","studied","studies"], 0),
    GrammarQuizQuestion("She ___ visit us next week.", ["will","did","is"], 0),
  ],
  10: [
    GrammarQuizQuestion("The flower is ___.", ["beautiful","slowly","run"], 0),
    GrammarQuizQuestion("It is a ___ cat.", ["sleep","small","quickly"], 1),
  ],
  11: [
    GrammarQuizQuestion("My bag is ___ than yours.", ["big","bigger","biggest"], 1),
    GrammarQuizQuestion("This test is ___ than that one.", ["easy","easier","easiest"], 1),
  ],
  12: [
    GrammarQuizQuestion("This is the ___ room.", ["clean","cleaner","cleanest"], 2),
    GrammarQuizQuestion("It is the ___ day of the week.", ["hot","hotter","hottest"], 2),
  ],
  13: [
    GrammarQuizQuestion("The ball is ___ the box.", ["under","quickly","blue"], 0),
    GrammarQuizQuestion("The picture is ___ the wall.", ["on","happy","walk"], 0),
  ],
  14: [
    GrammarQuizQuestion("Birds can ___.", ["flying","fly","flies"], 1),
    GrammarQuizQuestion("You cannot ___ here.", ["runs","running","run"], 2),
  ],
  15: [
    GrammarQuizQuestion("She ___ already finished.", ["have", "has", "is"], 1),
  ],
  16: [
    GrammarQuizQuestion("We ___ studying last night.", ["was", "were", "are"], 1),
  ],
  17: [
    GrammarQuizQuestion("I was born ___ June.", ["on", "at", "in"], 2),
  ],
  18: [
    GrammarQuizQuestion("He ___ a bicycle.", ["have", "has", "having"], 1),
  ],
};

List<GrammarQuizQuestion> questionsForTopic(GrammarTopic topic) {
  final index = grammarTopics.indexWhere((item) => item.title == topic.title);
  final initial = GrammarQuizQuestion(topic.question, topic.options, topic.correctIndex);
  final second = topic.secondQuestion == null || topic.secondOptions == null
      ? null
      : GrammarQuizQuestion(topic.secondQuestion!, topic.secondOptions!,
          topic.secondCorrectIndex);
  final extras = grammarExtraQuestions[index] ?? const <GrammarQuizQuestion>[];
  return [initial, if (second != null) second, if (extras.isNotEmpty) extras.first];
}

int grammarQuizPercent(List<GrammarQuizQuestion> questions, List<int> answers) {
  if (questions.isEmpty || answers.length != questions.length) {
    throw ArgumentError('Every question must have an answer.');
  }
  var correct = 0;
  for (var i = 0; i < questions.length; i++) {
    if (answers[i] == questions[i].correctIndex) correct++;
  }
  return (100 * correct / questions.length).round();
}

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key, required this.topic});
  final GrammarTopic topic;

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  late final questions = questionsForTopic(widget.topic);
  int index = 0;
  int? chosen;
  final answers = <int>[];
  int? result;
  bool submitting = false;

  Future<void> _complete() async {
    final score = grammarQuizPercent(questions, answers);
    setState(() { result = score; submitting = false; });
    try {
      final store = await GrammarProgressStore.open();
      await store.recordAttempt(widget.topic.title, score);
      if (score == 100) await store.markCompleted(widget.topic.title);
    } catch (_) {
      // The assessment remains usable if local storage is unavailable.
    }
  }

  void _next() {
    if (chosen == null || submitting || result != null) return;
    answers.add(chosen!);
    if (index == questions.length - 1) {
      setState(() => submitting = true);
      _complete();
    } else {
      setState(() { index++; chosen = null; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = result != null;
    return Scaffold(
      appBar: AppBar(title: Text('اختبار: ${widget.topic.title}')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        if (done) ...[
          Text('نتيجة الاختبار: $result%',
            style: Theme.of(context).textTheme.headlineSmall),
          Text('الإجابات الصحيحة: ${answers.asMap().entries.where((entry) => entry.value == questions[entry.key].correctIndex).length} من ${questions.length}'),
          const SizedBox(height: 12),
          for (var i = 0; i < questions.length; i++)
            ListTile(
              title: Directionality(textDirection: TextDirection.ltr,
                child: Text(questions[i].prompt)),
              subtitle: Text(answers[i] == questions[i].correctIndex
                ? 'إجابة صحيحة'
                : 'راجع: ${questions[i].options[questions[i].correctIndex]}'),
              leading: Icon(answers[i] == questions[i].correctIndex
                ? Icons.check_circle_outline : Icons.error_outline),
            ),
          OutlinedButton(
            onPressed: () => setState(() {
              index = 0; chosen = null; answers.clear(); result = null;
              submitting = false;
            }),
            child: const Text('أعد الاختبار'),
          ),
        ] else ...[
          Text('السؤال ${index + 1} من ${questions.length}',
            style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Directionality(textDirection: TextDirection.ltr,
            child: Text(questions[index].prompt,
              style: Theme.of(context).textTheme.titleMedium)),
          for (var i = 0; i < questions[index].options.length; i++)
            RadioListTile<int>(
              value: i, groupValue: chosen,
              title: Text(questions[index].options[i]),
              onChanged: (value) => setState(() => chosen = value),
            ),
          FilledButton(
            onPressed: chosen == null || submitting ? null : _next,
            child: Text(index == questions.length - 1 ? 'عرض النتيجة' : 'التالي'),
          ),
        ],
      ]),
    );
  }
}
