import 'package:flutter/material.dart';
import '../data/grammar_catalog.dart';

/// Standalone grammar academy: accessible independently of unit progression.
class GrammarAcademyScreen extends StatelessWidget {
  const GrammarAcademyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('أكاديمية القواعد')),
    body: FutureBuilder<List<GrammarTopic>>(
      future: const GrammarCatalog().load(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('تعذر تحميل دروس القواعد'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final topic = snapshot.data![index];
            return Card(
              child: ListTile(
                title: Text(topic.title),
                subtitle: Text(topic.level),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => GrammarTopicScreen(topic: topic),
                )),
              ),
            );
          },
        );
      },
    ),
  );
}

class GrammarTopicScreen extends StatefulWidget {
  const GrammarTopicScreen({required this.topic, super.key});
  final GrammarTopic topic;

  @override
  State<GrammarTopicScreen> createState() => _GrammarTopicScreenState();
}

class _GrammarTopicScreenState extends State<GrammarTopicScreen> {
  int questionIndex = 0;
  int? selected;
  int correctCount = 0;
  bool finished = false;

  void next() {
    final question = widget.topic.questions[questionIndex];
    if (selected == question.correctIndex) correctCount++;
    if (questionIndex + 1 == widget.topic.questions.length) {
      setState(() => finished = true);
    } else {
      setState(() {
        questionIndex++;
        selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(topic.explanation, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          for (final example in topic.examples)
            Directionality(
              textDirection: TextDirection.ltr,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(example, textAlign: TextAlign.left),
              ),
            ),
          const Divider(height: 32),
          if (finished)
            Semantics(
              liveRegion: true,
              child: Text('النتيجة: $correctCount من ${topic.questions.length}'),
            )
          else if (topic.questions.isEmpty)
            const Text('لا توجد أسئلة لهذا الدرس بعد')
          else ...[
            Text('السؤال ${questionIndex + 1} من ${topic.questions.length}'),
            const SizedBox(height: 12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(topic.questions[questionIndex].prompt,
                style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < topic.questions[questionIndex].options.length; i++)
              RadioListTile<int>(
                value: i,
                groupValue: selected,
                title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(topic.questions[questionIndex].options[i]),
                ),
                onChanged: (value) => setState(() => selected = value),
              ),
            if (selected != null) ...[
              Text(
                selected == topic.questions[questionIndex].correctIndex
                    ? 'إجابة صحيحة' : 'حاول التعلّم من التوضيح:',
              ),
              Text(topic.questions[questionIndex].explanation),
              const SizedBox(height: 12),
              FilledButton(onPressed: next, child: const Text('التالي')),
            ],
          ],
        ],
      ),
    );
  }
}
