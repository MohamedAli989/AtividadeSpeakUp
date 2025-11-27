// lib/core/services/practice_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pprincipal/features/3_content/domain/entities/practice_attempt.dart';
import 'package:pprincipal/features/3_content/domain/entities/feedback.dart'
    as fb_model;
import 'package:pprincipal/core/services/feedback_service.dart';
import 'package:pprincipal/features/4_profile/presentation/providers/user_provider.dart';

/// Serviço que salva a tentativa de prática, chama a análise de IA e persiste
/// o feedback, além de atualizar o progresso do utilizador.
class PracticeService {
  PracticeService();

  /// Salva a tentativa, solicita análise (FeedbackService) e atualiza XP.
  ///
  /// O [ref] é usado para atualizar o provedor `userProvider` após ganhar XP.
  Future<fb_model.FeedbackModel?> saveUserPractice(
    PracticeAttempt tentativa,
    WidgetRef ref,
  ) async {
    try {
      // 1) Persiste a tentativa
      await FirebaseFirestore.instance
          .collection('practice_attempts')
          .doc(tentativa.id)
          .set(tentativa.toJson());

      // 2) Solicita análise (mock por enquanto)
      final feedback = await FeedbackService().analisarPronuncia(tentativa);

      // 3) Persiste o feedback
      await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedback.id)
          .set(feedback.toJson());

      // 4) Atualiza progresso do usuário (adiciona XP)
      final pontos = feedback.overallScore.round();
      await ref.read(userProvider.notifier).incrementXp(pontos);

      return feedback;
    } catch (e) {
      // Em caso de erro, retorna null (chamador decide como tratar)
      return null;
    }
  }
}
