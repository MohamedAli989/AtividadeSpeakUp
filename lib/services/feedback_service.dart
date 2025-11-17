// lib/services/feedback_service.dart
import 'dart:math';
import 'package:pprincipal/features/3_content/domain/entities/practice_attempt.dart';
import 'package:pprincipal/features/3_content/domain/entities/feedback.dart'
    as fb_model;

/// Serviço responsável por analisar a pronúncia do utilizador.
///
/// Atualmente implementa um modo "mock" que retorna um feedback falso
/// com valores aleatórios para facilitar testes e desenvolvimento.
class FeedbackService {
  FeedbackService();

  /// Analisa a pronúncia de uma tentativa de prática.
  ///
  /// Em modo mock aguarda 2 segundos e retorna um [FeedbackModel] sintético.
  Future<fb_model.FeedbackModel> analisarPronuncia(
    PracticeAttempt tentativa,
  ) async {
    // Mock: simula latência de rede/processamento
    await Future.delayed(const Duration(seconds: 2));

    final rnd = Random();
    final overall = 60 + rnd.nextInt(41); // 60..100
    final fluency = 50 + rnd.nextInt(51);
    final accuracy = 50 + rnd.nextInt(51);

    final feedback = fb_model.FeedbackModel(
      id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
      practiceAttemptId: tentativa.id,
      overallScore: overall.toDouble(),
      fluencyScore: fluency.toDouble(),
      accuracyScore: accuracy.toDouble(),
      timestamp: DateTime.now(),
    );

    return feedback;
  }
}
