import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_models.dart';

class StorageService {
  static const String knowledgeBoxName = 'knowledge_box';
  static const String reflectionBoxName = 'reflection_box';
  static const String decisionBoxName = 'decision_box';
  static const String taskBoxName = 'task_box';
  static const String focusBoxName = 'focus_box';
  static const String ideaBoxName = 'idea_box';

  static late Box knowledgeBox;
  static late Box reflectionBox;
  static late Box decisionBox;
  static late Box taskBox;
  static late Box focusBox;
  static late Box ideaBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    knowledgeBox = await Hive.openBox(knowledgeBoxName);
    reflectionBox = await Hive.openBox(reflectionBoxName);
    decisionBox = await Hive.openBox(decisionBoxName);
    taskBox = await Hive.openBox(taskBoxName);
    focusBox = await Hive.openBox(focusBoxName);
    ideaBox = await Hive.openBox(ideaBoxName);
  }

  static Future<void> saveKnowledge(KnowledgeItem item) async {
    await knowledgeBox.put(item.id, item.toMap());
  }

  static List<KnowledgeItem> getKnowledge() {
    return knowledgeBox.values
        .map((value) => KnowledgeItem.fromMap(value))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> deleteKnowledge(String id) async {
    await knowledgeBox.delete(id);
  }

  static Future<void> saveReflection(ReflectionEntry entry) async {
    await reflectionBox.put(entry.id, entry.toMap());
  }

  static List<ReflectionEntry> getReflections() {
    return reflectionBox.values
        .map((value) => ReflectionEntry.fromMap(value))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> deleteReflection(String id) async {
    await reflectionBox.delete(id);
  }

  static Future<void> saveDecision(DecisionEntry entry) async {
    await decisionBox.put(entry.id, entry.toMap());
  }

  static List<DecisionEntry> getDecisions() {
    return decisionBox.values
        .map((value) => DecisionEntry.fromMap(value))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> deleteDecision(String id) async {
    await decisionBox.delete(id);
  }

  static Future<void> saveTask(TaskItem task) async {
    await taskBox.put(task.id, task.toMap());
  }

  static List<TaskItem> getTasks() {
    return taskBox.values
        .map((value) => TaskItem.fromMap(value))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> deleteTask(String id) async {
    await taskBox.delete(id);
  }

  static Future<void> saveFocusSession(FocusSession session) async {
    await focusBox.put(session.id, session.toMap());
  }

  static List<FocusSession> getFocusSessions() {
    return focusBox.values
        .map((value) => FocusSession.fromMap(value))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> deleteFocusSession(String id) async {
    await focusBox.delete(id);
  }

  static Future<void> saveIdea(IdeaItem idea) async {
    await ideaBox.put(idea.id, idea.toMap());
  }

  static List<IdeaItem> getIdeas() {
    return ideaBox.values
        .map((value) => IdeaItem.fromMap(value))
        .toList()
        .reversed
        .toList();
  }

  static Future<void> deleteIdea(String id) async {
    await ideaBox.delete(id);
  }

  static Future<void> clearAllPersonalData() async {
    await knowledgeBox.clear();
    await reflectionBox.clear();
    await decisionBox.clear();
    await taskBox.clear();
    await focusBox.clear();
    await ideaBox.clear();
  }
}
