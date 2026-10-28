import 'package:flutter/material.dart';
import 'grammar_progress_store.dart';
import 'grammar_quiz_screen.dart';

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
  GrammarTopic('الماضي البسيط', 'نستخدم الماضي البسيط لأحداث انتهت. نضيف ed للأفعال المنتظمة، بينما تتغير بعض الأفعال غير المنتظمة مثل go إلى went.',
      ['I played yesterday.', 'She visited her aunt.', 'He went home.'],
      'Yesterday, I ___ football.', ['play', 'played', 'playing'], 1, 'yesterday تدل على الماضي، لذلك نستخدم played.'),
  GrammarTopic('المستقبل باستخدام will', 'نستخدم will ثم الفعل الأساسي للتحدث عن المستقبل أو اتخاذ قرار.',
      ['I will study tomorrow.', 'She will help you.', 'We will visit grandma.'],
      'Tomorrow, we ___ play.', ['will', 'are', 'did'], 0, 'بعد will يأتي الفعل الأساسي play.'),
  GrammarTopic('الصفات', 'الصفة تصف الشخص أو الشيء. غالبًا تأتي قبل الاسم أو بعد فعل الكينونة.',
      ['a small cat', 'The sky is blue.', 'She is kind.'],
      'This is a ___ bag.', ['happy', 'red', 'quickly'], 1, 'red صفة مناسبة لوصف لون الحقيبة.'),
  GrammarTopic('المقارنة باستخدام -er / more', 'نقارن بين شيئين باستعمال الصفة المقارنة وthan. نضيف er غالبًا للصفات القصيرة ونستخدم more مع كثير من الصفات الطويلة.',
      ['Ali is taller than Omar.', 'This book is more interesting than that one.'],
      'A giraffe is ___ than a cat.', ['tall', 'taller', 'tallest'], 1, 'نستخدم taller than عند المقارنة بين شيئين.'),
  GrammarTopic('التفضيل باستخدام -est / most', 'نستخدم the مع صيغة التفضيل عند مقارنة شخص أو شيء بمجموعة. غالبًا نضيف est أو نستخدم most.',
      ['This is the tallest tree.', 'She is the most careful student.'],
      'He is the ___ boy in the class.', ['tall', 'taller', 'tallest'], 2, 'نستخدم the tallest للمقارنة مع كل أفراد المجموعة.'),
  GrammarTopic('حروف الجر للمكان', 'تحدد in وon وunder وnext to مكان الشيء بالنسبة لغيره.',
      ['The toy is in the box.', 'The book is on the table.', 'The cat is under the chair.'],
      'The book is ___ the table.', ['on', 'happy', 'run'], 0, 'on تعني على سطح الشيء.'),
  GrammarTopic('can / cannot', 'نستخدم can للقدرة، وcannot أو can’t لعدم القدرة، ثم الفعل الأساسي.',
      ['I can swim.', 'A bird can fly.', 'A fish cannot walk.'],
      'She can ___ English.', ['speaks', 'speak', 'speaking'], 1, 'بعد can نستخدم الفعل الأساسي speak.'),
  GrammarTopic('have / has', 'نستخدم have مع I / you / we / they، وhas مع he / she / it للتعبير عن الملكية.',
      ['I have a pencil.', 'He has a bike.', 'They have books.'],
      'My sister ___ a cat.', ['have', 'has', 'having'], 1, 'نستخدم has مع My sister لأنها مفرد غائب.'),
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
  int attempts = 0;
  int? bonusSelection;
  int bonusAttempts = 0;
  bool _completionSaved = false;

  Future<void> _saveCompletion() async {
    if (_completionSaved) return;
    _completionSaved = true;
    try {
      final store = await GrammarProgressStore.open();
      await store.markCompleted(widget.topic.title);
    } catch (_) {
      _completionSaved = false;
      // Practice works even if persistent storage is unavailable.
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
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => GrammarQuizScreen(topic: topic),
            )),
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('اختبار نهائي: 3 أسئلة'),
          ),
          const SizedBox(height: 16),
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
              onChanged: (value) => setState(() {
                selected = value;
                attempts++;
              }),
            ),
          if (selected == topic.correctIndex) ...[
            const Divider(height: 36),
            Text('السؤال الثاني', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('اختر الجملة الصحيحة:'),
            for (var i = 0; i < 3; i++)
              RadioListTile<int>(
                title: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(i == 0 ? topic.examples.first :
                    i == 1 ? topic.question : topic.options.last),
                ),
                value: i,
                groupValue: bonusSelection,
                onChanged: (value) => setState(() {
                  bonusSelection = value;
                  bonusAttempts++;
                  if (value == 0) _saveCompletion();
                }),
              ),
            if (bonusSelection != null)
              Text(bonusSelection == 0
                ? 'ممتاز! أكملت السؤالين بنجاح.'
                : 'ليست الإجابة الصحيحة. راجع المثال الأول وحاول مجددًا.'),
          ],
          if (selected != null) ...[
            Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${selected == topic.correctIndex ? 'أحسنت! أتقنت هذا التدريب.' : 'حاول مرة أخرى.'} ${topic.reason}',
                  style: TextStyle(
                    color: selected == topic.correctIndex
                        ? Colors.green.shade700 : Colors.deepOrange,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() => selected = null),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(selected == topic.correctIndex
                  ? 'أعد التدريب' : 'جرّب من جديد'),
            ),
            if (selected == topic.correctIndex)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('عدد المحاولات: $attempts'),
              ),
          ],
        ],
      ),
    );
  }
}
