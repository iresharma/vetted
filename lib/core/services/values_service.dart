import 'package:vetted_club_mobile/core/services/functions_service.dart';

class ValuesService {
  ValuesService._();

  static final ValuesService instance = ValuesService._();

  Future<ValuesQuizStatus> getQuizStatus() async {
    final data = await FunctionsService.instance.call('getValuesQuizStatus');
    return ValuesQuizStatus.fromMap(data);
  }

  Future<void> submitQuiz(Map<String, dynamic> quizAnswers) async {
    await FunctionsService.instance.call(
      'submitValuesQuiz',
      data: {'quizAnswers': quizAnswers},
    );
  }

  Future<void> skipQuiz() async {
    await FunctionsService.instance.call('skipValuesQuiz');
  }
}

class ValuesQuizStatus {
  const ValuesQuizStatus({
    required this.status,
    this.source,
    this.updatedAt,
  });

  final String status;
  final String? source;
  final String? updatedAt;

  bool get isPending => status == 'pending';
  bool get isComplete => status == 'completed' || status == 'skipped';

  factory ValuesQuizStatus.fromMap(Map<String, dynamic> map) {
    return ValuesQuizStatus(
      status: (map['status'] as String?) ?? 'pending',
      source: map['source'] as String?,
      updatedAt: map['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'source': source,
        'updatedAt': updatedAt,
      };
}
