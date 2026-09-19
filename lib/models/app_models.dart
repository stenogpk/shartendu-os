class KnowledgeItem {
  final String id;
  final String title;
  final String learned;
  final String category;
  final String source;
  final String insight;
  final String action;
  final DateTime createdAt;
  final DateTime? reviewDate;

  KnowledgeItem({
    required this.id,
    required this.title,
    required this.learned,
    required this.category,
    required this.source,
    required this.insight,
    required this.action,
    required this.createdAt,
    this.reviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'learned': learned,
      'category': category,
      'source': source,
      'insight': insight,
      'action': action,
      'createdAt': createdAt.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
    };
  }

  factory KnowledgeItem.fromMap(Map<dynamic, dynamic> map) {
    return KnowledgeItem(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      learned: map['learned']?.toString() ?? '',
      category: map['category']?.toString() ?? 'General',
      source: map['source']?.toString() ?? '',
      insight: map['insight']?.toString() ?? '',
      action: map['action']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      reviewDate: map['reviewDate'] == null
          ? null
          : DateTime.tryParse(map['reviewDate'].toString()),
    );
  }
}

class ReflectionEntry {
  final String id;
  final DateTime date;
  final String proudOf;
  final String wastedTime;
  final String learned;
  final String tomorrowImprovement;

  ReflectionEntry({
    required this.id,
    required this.date,
    required this.proudOf,
    required this.wastedTime,
    required this.learned,
    required this.tomorrowImprovement,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'proudOf': proudOf,
      'wastedTime': wastedTime,
      'learned': learned,
      'tomorrowImprovement': tomorrowImprovement,
    };
  }

  factory ReflectionEntry.fromMap(Map<dynamic, dynamic> map) {
    return ReflectionEntry(
      id: map['id']?.toString() ?? '',
      date: DateTime.tryParse(map['date']?.toString() ?? '') ??
          DateTime.now(),
      proudOf: map['proudOf']?.toString() ?? '',
      wastedTime: map['wastedTime']?.toString() ?? '',
      learned: map['learned']?.toString() ?? '',
      tomorrowImprovement:
          map['tomorrowImprovement']?.toString() ?? '',
    );
  }
}

class DecisionEntry {
  final String id;
  final String question;
  final String options;
  final String chosen;
  final String reasoning;
  final String prediction;
  final String result;
  final DateTime createdAt;
  final DateTime? reviewDate;

  DecisionEntry({
    required this.id,
    required this.question,
    required this.options,
    required this.chosen,
    required this.reasoning,
    required this.prediction,
    required this.result,
    required this.createdAt,
    this.reviewDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'chosen': chosen,
      'reasoning': reasoning,
      'prediction': prediction,
      'result': result,
      'createdAt': createdAt.toIso8601String(),
      'reviewDate': reviewDate?.toIso8601String(),
    };
  }

  factory DecisionEntry.fromMap(Map<dynamic, dynamic> map) {
    return DecisionEntry(
      id: map['id']?.toString() ?? '',
      question: map['question']?.toString() ?? '',
      options: map['options']?.toString() ?? '',
      chosen: map['chosen']?.toString() ?? '',
      reasoning: map['reasoning']?.toString() ?? '',
      prediction: map['prediction']?.toString() ?? '',
      result: map['result']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      reviewDate: map['reviewDate'] == null
          ? null
          : DateTime.tryParse(map['reviewDate'].toString()),
    );
  }
}
