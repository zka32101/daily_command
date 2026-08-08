import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_advice_service.dart';

final aiAdviceServiceProvider = Provider<AiAdviceService>((ref) {
  return AiAdviceService();
});
