PR: feat(content-providers) — Persist vocabulary and wire providers

Summary
-	Replace in-memory vocabulary list with a persisted AsyncNotifier-based provider backed by SharedPreferences.
-	Add `VocabularyRepositoryImpl` and `VocabularyLocalDataSource` to store/load vocabulary as JSON.
-	Update `salvarVocabularioUseCaseProvider` to invalidate the vocabulary provider after saving so UI reloads.
-	Update `VocabularyPage` to handle AsyncValue from the new provider (loading / error / data states).
-	Fix Riverpod usage in Splash/login flows during earlier refactor (safe await of provider future and test compatibility).

Files changed / added (high level)
- lib/features/3_content/presentation/providers/vocabulary_providers.dart (replaced in-memory notifier with AsyncNotifier)
- lib/features/3_content/presentation/providers/vocabulary_usecase_providers.dart (invalidate provider after save)
- lib/features/3_content/presentation/pages/vocabulary_page.dart (handle AsyncValue)
- lib/features/3_content/data/datasources/vocabulary_local_datasource.dart (SharedPreferences JSON storage)
- lib/features/3_content/data/repositories/vocabulary_repository_impl.dart (loadAll/saveAll/saveItem implementations)
- lib/features/0_splash/presentation/pages/splash_screen.dart (safe provider await in initState)
- lib/features/2_auth/presentation/pages/login_screen.dart (ensure userProvider updated for skip-login flow)

Testing
- Ran full test suite locally: `flutter test --reporter=expanded` — all tests passed.
- Ran `flutter analyze --no-pub` during development and fixed issues.

How to review
- Focus on `vocabulary_providers.dart` to confirm the persistence initialization and salvar behavior.
- Confirm `vocabulary_page.dart` correctly handles loading/error states and still calls the usecase to save.
- Inspect `vocabulary_local_datasource.dart` for storage key format and JSON handling.

Notes / follow-ups
- Current user id source falls back to `user.email ?? 'u1'` when email absent; consider wiring real auth user id.
- CSV import currently does a simple import; consider duplicate detection / optimistic updates for better UX.
- Optionally implement optimistic UI updates in `VocabularyListNotifier.salvarItem`.

Command to run locally
```powershell
cd 'c:\Users\USER\Documents\GitHub\AtividadeSpeakUp'
flutter analyze --no-pub
flutter test --reporter=expanded
```

Reviewer suggestions
- @team/frontend for UI flow
- @team/backend for potential Firestore/Firebase integration if desired

Notes for PR body
- This PR upgrades vocabulary persistence and completes the Clean Architecture wiring for content providers. It is low-risk and covered by existing unit/widget tests. Please check the fallback user-id behavior and advise if we should integrate FirebaseAuth now.
