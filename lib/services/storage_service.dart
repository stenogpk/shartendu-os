import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_models.dart';

class StorageService {
  static const String knowledgeBoxName = 'knowledge_box';
  static const String reflectionBoxName = 'reflection_box';
  static const String decisionBoxName = 'decision_box';

  static late Box knowledgeBox;
  static late Box reflectionBox;
  static late Box decisionBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    knowledgeBox = await Hive.openBox(knowledgeBoxName);
    reflectionBox = await Hive.openBox(reflectionBoxName);
    decisionBox = await Hive.openBox(decisionBoxName);
  }

  // ---------------- Knowledge ----------------

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

  // ---------------- Reflection ----------------

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

  // ---------------- Decisions ----------------

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

  // ---------------- Utility ----------------

  static Future<void> clearAllPersonalData() async {
    await knowledgeBox.clear();
    await reflectionBox.clear();
    await decisionBox.clear();
  }
}
