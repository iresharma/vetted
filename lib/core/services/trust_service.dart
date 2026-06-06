import 'package:vetted_club_mobile/core/services/functions_service.dart';
import 'package:vetted_club_mobile/features/trust/data/models/trust_report.dart';

class TrustService {
  TrustService._();

  static final TrustService instance = TrustService._();

  Future<TrustReport> loadReport({String? category, int limit = 50}) async {
    final response = await FunctionsService.instance.call(
      'getTrustReport',
      data: {
        if (category != null) 'category': category,
        'limit': limit,
      },
    );
    return TrustReport.fromMap(Map<String, dynamic>.from(response));
  }
}
