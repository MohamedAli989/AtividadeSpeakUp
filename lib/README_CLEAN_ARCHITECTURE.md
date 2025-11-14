# Clean Architecture scaffold (proposal)

This folder contains a minimal Clean Architecture scaffold and an example refactor for the "Terms" flow.

Structure added under `lib/src`:

- `domain/` — Entities, repository interfaces and usecases.
- `data/` — DataSources and repository implementations.
- `presentation/` — UI code (widgets/screens) that depends on `domain` abstractions.
- `core/` — App-level wiring (Riverpod providers) that connects data -> domain -> presentation.

What I implemented as an example:
- Domain: `TermAcceptance`, `TermsRepository`, `SetTermsAccepted` usecase.
- Data: `LocalTermsDataSource` (wraps the existing `PersistenceService`) and `TermsRepositoryImpl`.
- Core: `providers.dart` exposes Riverpod providers for the persistence service, datasource, repository and usecase.
- Presentation: `src/presentation/screens/terms/terms_screen.dart` — a refactored `TermsScreenClean` that uses the `SetTermsAccepted` usecase via Riverpod.

Guidance to migrate other code:

- Keep current files for compatibility while gradually migrating to `lib/src`.
- Replace direct calls to `PersistenceService` or provider-state with usecases and repository interfaces.
- Add unit tests for usecases and repository impls.
- When ready, switch imports in the app to point to the new presentation widgets (or remove the old ones).

Next suggested steps (I can do these on request):
- Migrate `accepted_terms_provider.dart` to use the new repository/usecase.
- Wire the new `TermsScreenClean` into navigation (replace existing screen export).
- Add more usecases and repositories for `user`, `onboarding`, and `practice` flows.
