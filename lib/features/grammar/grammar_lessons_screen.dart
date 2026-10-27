import 'package:flutter/material.dart';

/// Grammar lessons are independent of vocabulary units and lesson XP.
class GrammarTopic {
  const GrammarTopic(this.title, this.rule, this.examples, this.question,
      this.options, this.correctIndex, this.reason);
  final String title;
  final String rule;
  final List<String> examples;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String reason;
}

const grammarTopics = <GrammarTopic>[
  GrammarTopic('الضمائر الشخصية', 'نستخدم I للمتكلم، وYou للمخاطب، وHe للولد، وShe للبنت، وIt للشيء أو الحيوان، وWe للجمع الذي يشملنا، وThey للآخرين.',
      ['I am a student.', 'She is happy.', 'They are friends.'],
      '___ is my mother.', ['He', 'She', 'They'], 1, 'نستخدم She مع الأم.'),
  GrammarTopic('فعل الكينونة am / is / are', 'نستخدم am مع I، وis مع he / she / it، وare مع you / we / they.',
      ['I am ready.', 'He is kind.', 'We are happy.'],
      'They ___ students.', ['am', 'is', 'are'], 2, 'نستخدم are مع They.'),
  GrammarTopic('a / an', 'نستخدم a قبل الصوت الساكن، وan قبل الصوت المتحرك. المهم هو صوت بداية الكلمة.',
      ['a book', 'an apple', 'an orange'],
      'I have ___ apple.', ['a', 'an', 'are'], 1, 'كلمة apple تبدأ بصوت متحرك.'),
  GrammarTopic('المفرد والجمع', 'غالبًا نضيف s للاسم عند الحديث عن أكثر من واحد، لكن بعض الكلمات لها جمع غير منتظم.',
      ['one cat / two cats', 'one book / three books', 'one child / two children'],
      'I have two ___.', ['cat', 'cats', 'a cat'], 1, 'بعد two نستخدم الاسم بصيغة الجمع.'),
  GrammarTopic('المضارع البسيط', 'نستخدم المضارع البسيط للعادات والحقائق. نضيف s غالبًا مع he / she / it في الإثبات.',
      ['I play every day.', 'She plays football.', 'He likes milk.'],
      'She ___ to school.', ['go', 'goes', 'going'], 1, 'في الإثبات نستخدم goes مع She.'),
  GrammarTopic('المضارع المستمر', 'نستخدم am / is / are ثم الفعل مع ing لوصف شيء يحدث الآن.',
      ['I am reading.', 'He is running.', 'They are playing.'],
      'We ___ studying now.', ['am', 'is', 'are'], 2, 'نستخدم are مع We.'),
  GrammarTopic('النفي باستخدام do / does', 'نستخدم do not مع I / you / we / they، وdoes not مع he / she / it، ثم الفعل الأساسي.',
      ['I do not like tea.', 'She does not play tennis.'],
      'He ___ like coffee.', ['do not', 'does not', 'is not'], 1, 'نستخدم does not مع He.'),
  GrammarTopic('السؤال باستخدام Do / Does', 'نبدأ السؤال بـ Do مع I / you / we / they، وبـ Does مع he / she / it ثم الفعل الأساسي.',
      ['Do you like apples?', 'Does she read books?'],
      '___ he play football?', ['Do', 'Does', 'Is'], 1, 'يبدأ السؤال بـ Does مع He.'),
];

class GrammarLessonsScreen extends StatelessWidget {
  const GrammarLessonsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تعلّم القواعد الإنجليزية')),
    body: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: grammarTopics.length,
      itemBuilder: (context, index) {
        final lesson = grammarTopics[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(lesson.title),
            subtitle: const Text('شرح مبسّط • أمثلة • سؤال تدريبي'),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => GrammarDetailScreen(topic: lesson),
            )),
          ),
        );
      },
    ),
  );
}

class GrammarDetailScreen extends StatefulWidget {
  const GrammarDetailScreen({super.key, required this.topic});
  final GrammarTopic topic;

  @override
  State<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends State<GrammarDetailScreen> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    return Scaffold(
      appBar: AppBar(title: Text(topic.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('شرح القاعدة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(topic.rule),
          const SizedBox(height: 24),
          Text('أمثلة', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          for (final example in topic.examples)
            Card(child: Padding(
              padding: const EdgeInsets.all(12),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(example, textAlign: TextAlign.left),
              ),
            )),
          const SizedBox(height: 24),
          Text('اختبر فهمك', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(topic.question, textAlign: TextAlign.left),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < topic.options.length; i++)
            RadioListTile<int>(
              title: Text(topic.options[i]),
              value: i,
              groupValue: selected,
              onChanged: (value) => setState(() => selected = value),
            ),
          if (selected != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '${selected == topic.correctIndex ? 'إجابة صحيحة! ' : 'حاول مرة أخرى. '}${topic.reason}',
                style: TextStyle(
                  color: selected == topic.correctIndex ? Colors.green.shade700 : Colors.deepOrange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
