import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Standalone grammar content, deliberately separate from the unit skill tree.
class GrammarCatalog {
  const GrammarCatalog();

  Future<List<GrammarTopic>> load() async {
    final raw = await rootBundle.loadString('assets/data/grammar_topics.json');
    final items = jsonDecode(raw) as List<dynamic>;
    final topics = items.map((item) =>
      GrammarTopic.fromJson(item as Map<String, dynamic>)).toList();
    if (topics.map((topic) => topic.id).toSet().length != topics.length) {
      throw const FormatException('Duplicate grammar topic IDs');
    }
    return List.unmodifiable(topics);
  }
}

class GrammarTopic {
  const GrammarTopic({
    required this.id,
    required this.title,
    required this.level,
    required this.explanation,
    required this.examples,
    required this.questions,
  });

  final String id;
  final String title;
  final String level;
  final String explanation;
  final List<String> examples;
  final List<GrammarQuestion> questions;

  factory GrammarTopic.fromJson(Map<String, dynamic> json) => GrammarTopic(
    id: json['id'] as String,
    title: json['title'] as String,
    level: json['level'] as String,
    explanation: json['explanation'] as String,
    examples: List<String>.from(json['examples'] as List),
    questions: (json['questions'] as List).map((item) =>
      GrammarQuestion.fromJson(item as Map<String, dynamic>)).toList(),
  );
}

class GrammarQuestion {
  const GrammarQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    final options = List<String>.from(json['options'] as List);
    final correctIndex = json['correctIndex'] as int;
    if (options.length < 2 || correctIndex < 0 || correctIndex >= options.length) {
      throw const FormatException('Invalid grammar question options or answer');
    }
    return GrammarQuestion(
      prompt: json['prompt'] as String,
      options: options,
      correctIndex: correctIndex,
      explanation: json['explanation'] as String,
    );
  }
}
