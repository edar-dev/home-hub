---
name: fase5_onboarding_tour
overview: Piano sequenziale in 3 fasi per introdurre onboarding guidato, tour on-demand e impostazioni aiuto in Housekeep, integrando MVVM+Provider+Hive esistenti senza breaking changes.
todos:
  - id: p1-core-infra
    content: Implementare modelli onboarding, repository Hive, service e viewmodel con trigger e persistenza.
    status: completed
  - id: p2-screens-animation
    content: Implementare onboarding fullscreen 8 step con progress, CTA, setup iniziale, animazioni e test widget/golden.
    status: completed
  - id: p3-tour-settings-i18n
    content: Implementare tour overlay on-demand, QuickHelp FAB globale, settings onboarding/aiuto e localizzazione IT-EN-ES.
    status: completed
isProject: false
---

# FASE 5 — Onboarding Tour Guidato (3 piani sequenziali)

## Assunzioni e adattamento al codebase reale

- Il progetto usa `domain/entities` (non `domain/models`): manterremo coerenza con le fasi 1-4.
- In `pubspec.yaml` esistono già molte dipendenze FASE 1-4; aggiungiamo solo quelle necessarie a FASE 5.
- La shell attuale ha tab inventario/luoghi/riepilogo/analytics/lista spesa/notifiche in `[d:\source\housekeep\lib\presentation\views\screens\home_shell_screen.dart](d:\source\housekeep\lib\presentation\views\screens\home_shell_screen.dart)`, quindi l’onboarding verrà lanciato come overlay/modal sopra l’home.

## Piano 1 — Core Onboarding Infrastructure

### Obiettivo

Costruire persistenza, regole di trigger, service e VM per gestire stato onboarding/tour in modo robusto e testabile.

### Dipendenze (aggiunte)

- `app_tours: ^0.6.0`
- `lottie: ^3.1.2`
- `simple_animations: ^5.0.2`
- `firebase_analytics: ^11.3.2` (optional, dietro flag settings)

### File da creare

- `lib/domain/entities/onboarding_step.dart`
- `lib/domain/entities/language_code.dart`
- `lib/domain/entities/animation_speed.dart`
- `lib/domain/entities/onboarding_state.dart`
- `lib/domain/entities/onboarding_settings.dart`
- `lib/domain/entities/tour_step.dart`
- `lib/domain/repositories/onboarding_repository.dart`
- `lib/data/local/models/onboarding_state_hive_model.dart`
- `lib/data/local/models/onboarding_settings_hive_model.dart`
- `lib/data/local/repositories/local_onboarding_repository.dart`
- `lib/services/onboarding_service.dart`
- `lib/presentation/viewmodels/onboarding_view_model.dart`
- `lib/config/onboarding_config.dart`
- `lib/utils/onboarding_constants.dart`

### File da aggiornare

- `pubspec.yaml`
- `[d:\source\housekeep\lib\data\local\hive_service.dart](d:\source\housekeep\lib\data\local\hive_service.dart)` (adapter/typeId e box onboarding)
- `[d:\source\housekeep\lib\core\di\app_providers.dart](d:\source\housekeep\lib\core\di\app_providers.dart)` (repository onboarding)
- `[d:\source\housekeep\lib\app.dart](d:\source\housekeep\lib\app.dart)` (provider OnboardingViewModel)
- `lib/main.dart` (check `shouldShowOnboarding` su bootstrap)

### Snippet critici

- `OnboardingStep` enum con 8 step (welcome→complete).
- `OnboardingState` con:
  - `isCompleted`, `currentStep`, `firstCompletedDate`, `lastViewedDate`, `completedSteps`
  - `showAnimations`, `animationSpeed`, `language`, `showContextualTooltips`
  - getter `completionPercentage`, `isStepCompleted(step)`
- `OnboardingSettings` con:
  - `skipOnboardingAutomatically`, `showOnboardingOnUpdate`, `animationSpeed`, `preferredLanguage`, `enableAnalytics`, `showContextualHelp`
- `OnboardingRepository`:
  - `getOnboardingState`, `updateOnboardingState`, `markStepCompleted`, `completeOnboarding`, `resetOnboarding`
  - `getSettings`, `updateSettings`
- `OnboardingService.shouldShowOnboarding()`:
  - first install
  - major version bump
  - inattività > 30 giorni
  - setup incompleto (<50%: pochi prodotti/nessuna location)
  - rispetto settings skip

### Test (P1)

- `test/domain/onboarding_state_test.dart`
- `test/domain/onboarding_settings_test.dart`
- `test/data/local_onboarding_repository_test.dart`
- `test/presentation/onboarding_view_model_test.dart`
- Coprire edge case:
  - box Hive vuoti/corrotti
  - stato parziale/interrotto
  - reset debug

### Platform config

- Nessun permesso nuovo obbligatorio nel piano 1.
- Firebase analytics opzionale: inizialmente no-op se non configurato.

### Integrazione FASE 1-4

- Reuse DI centralizzata in `AppFactory` e `HousekeepApp`.
- Nessuna modifica ai repository core (product/location/analytics) se non lettura per trigger setup incompleto.

### Error handling e performance

- Fallback sicuri su default state/settings se Hive fallisce.
- Debounce `notifyListeners` in VM durante bootstrap.
- Nessun rendering pesante in questa fase.

---

## Piano 2 — Onboarding Screens + Animazioni

### Obiettivo

Implementare il flusso fullscreen 8 step con progress, swipe, CTA “Prova ora”, skip, setup iniziale e completion.

### File da creare

- `lib/presentation/views/screens/onboarding/onboarding_screen.dart`
- `lib/presentation/views/screens/onboarding/widgets/onboarding_step_view.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_progress_bar.dart`
- `lib/presentation/views/screens/onboarding/widgets/action_buttons.dart`
- `lib/presentation/views/screens/onboarding/widgets/lottie_animation_widget.dart`
- `lib/presentation/views/screens/onboarding/widgets/confetti_animation.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_welcome.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_add_product.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_scanner.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_locations.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_analytics.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_notifications.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_first_setup.dart`
- `lib/presentation/views/screens/onboarding/widgets/step_content_completion.dart`
- `lib/utils/onboarding_strings.dart` (IT/EN base, ES placeholder)

### File da aggiornare

- `pubspec.yaml` (`flutter.assets` con `assets/animations/`)
- `[d:\source\housekeep\lib\app.dart](d:\source\housekeep\lib\app.dart)` o `main.dart` per mostrare `OnboardingScreen` una volta deciso il trigger
- `[d:\source\housekeep\lib\presentation\views\screens\home_shell_screen.dart](d:\source\housekeep\lib\presentation\views\screens\home_shell_screen.dart)` (entry point non intrusivo al tour)

### Asset

- `assets/animations/welcome.json`
- `assets/animations/product_form.json`
- `assets/animations/scanner_demo.json`
- `assets/animations/locations_organize.json`
- `assets/animations/analytics_charts.json`
- `assets/animations/notification_alert.json`
- `assets/animations/confetti.json`

### UX/flow implementativo

- Progress dot + linear indicator (1/8…8/8).
- Swipe orizzontale mobile + controlli Avanti/Indietro.
- `Prova ora` apre feature reale:
  - prodotto: `ProductFormScreen`
  - scanner: `BarcodeScannerScreen`
  - analytics/notifiche/shopping: switch tab mirato o deep-link interno.
- Step `firstSetup` salva “nome casa” come prima location (se assente) tramite repository location.

### Test (P2)

- `test/views/onboarding/onboarding_screen_test.dart`
- `test/views/onboarding/step_progress_bar_test.dart`
- `test/views/onboarding/step_content_*_test.dart` (smoke)
- Golden:
  - onboarding light/dark per step chiave (welcome, scanner, completion)

### Platform config

- Verificare web fallback Lottie (asset load error -> placeholder statico).
- Gestione `MediaQuery.disableAnimations`/accessibility reduce motion.

### Error handling e performance

- Lottie lazy-load per step attivo (evitare preload di 8 json insieme).
- Se asset mancante: fallback icon + testo, senza crash.
- Limitare animazioni complesse su device low-end (rispettare `animationSpeed`).

---

## Piano 3 — Tour Overlay + Quick Help + Settings + i18n

### Obiettivo

Completare esperienza post-onboarding: tour on-demand, help FAB globale, sezione settings dedicata e localizzazione IT/EN/ES.

### File da creare

- `lib/services/tour_service.dart`
- `lib/presentation/views/widgets/tour/tour_overlay.dart`
- `lib/presentation/views/widgets/tour/tour_highlight.dart`
- `lib/presentation/views/widgets/tour/tour_tooltip.dart`
- `lib/presentation/views/widgets/tour/tour_step_navigator.dart`
- `lib/presentation/views/widgets/quick_help/quick_help_fab.dart`
- `lib/presentation/views/widgets/quick_help/help_tooltip.dart`
- `lib/presentation/views/widgets/quick_help/help_badge.dart`
- `lib/presentation/views/screens/settings/onboarding_settings_screen.dart`
- `lib/presentation/views/screens/settings/widgets/animation_speed_slider.dart`
- `lib/presentation/views/screens/settings/widgets/language_selector.dart`
- `lib/presentation/views/screens/settings/widgets/tour_action_buttons.dart`
- `lib/config/tour_config.dart`

### File da aggiornare

- `[d:\source\housekeep\lib\presentation\views\screens\home_shell_screen.dart](d:\source\housekeep\lib\presentation\views\screens\home_shell_screen.dart)` (inject `QuickHelpFAB` globale)
- `[d:\source\housekeep\lib\presentation\views\screens\settings\notification_settings_screen.dart](d:\source\housekeep\lib\presentation\views\screens\settings\notification_settings_screen.dart)` o nuova schermata aggregata “Onboarding & Aiuto”
- `lib/utils/onboarding_strings.dart` (IT/EN/ES complete)

### Tour on-demand

- Trigger:
  - long press su FAB help
  - bottone “Riproduci tour” in settings
- Overlay:
  - highlight target key-based
  - tooltip con CTA avanti/indietro/skip
  - resumable: persiste step corrente in `OnboardingState.currentStep`

### Settings

- `Skip onboarding automatico`
- `Riproduci tour completo`
- `AnimationSpeed` (slow/normal/fast)
- lingua IT/EN/ES
- tooltip contestuali
- analytics anonimo
- reset debug (solo debug mode)

### Test (P3)

- `test/views/quick_help_fab_test.dart`
- `test/views/tour_overlay_test.dart`
- `test/views/onboarding_settings_screen_test.dart`
- integration:
  - `integration_test/onboarding_flow_complete_test.dart`
  - `integration_test/onboarding_skip_test.dart`
  - `integration_test/tour_post_onboarding_test.dart`
  - `integration_test/onboarding_settings_test.dart`

### Platform-specific

- Android/iOS: nessun permesso aggiuntivo obbligatorio per overlay/help.
- Firebase analytics: inizializzare solo se disponibile, altrimenti `NoOp` tracker.
- Web: gesture fallback per long-press (menu pulsante “Tour”).

### Error handling e performance

- Se target highlight non trovato: step auto-skip con log diagnostico.
- Overlay non blocca rendering principale (usa `OverlayEntry` leggero).
- Tooltips contestuali con throttling (evitare spam).

---

## Migrazione FASE 4 → FASE 5

- Estendere `HiveService` con box onboarding state/settings e relativi adapter/typeId in coda.
- Seed default su box vuota (`OnboardingState.initial`, `OnboardingSettings.defaults`).
- Per utenti esistenti FASE 4:
  - mostrare onboarding se major update e setup incompleto o inattivo >30 giorni.
  - non alterare dati inventario preesistenti.

## Ordine consigliato di delivery

1. P1 (infrastruttura + test unit)
2. P2 (UI onboarding + widget/golden)
3. P3 (tour/help/settings + integration)

## Criteri di accettazione

- Onboarding trigger corretto su first-run/update/inactivity/help.
- 8 step navigabili con skip/prova/avanti e completion persistita.
- Tour on-demand funzionante da FAB e settings.
- Nessun crash su Hive vuoto/corrotto/asset mancante.
- `flutter analyze` e test suite verdi.

