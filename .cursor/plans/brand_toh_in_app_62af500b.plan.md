---
name: Brand TOH in app
overview: "Allineare l’app Housekeep al documento [`docs/brand/the-organized-hive-brand-decisions.md`](docs/brand/the-organized-hive-brand-decisions.md): nome visibile, palette, tipografia già vicina al brief, asset launcher opzionali — senza rinominare il package Dart `housekeep` né obbligare subito il cambio `applicationId` (impatto store/utenti)."
todos:
  - id: brand-constants-platform-labels
    content: Aggiungere lib/core/brand/app_brand.dart; aggiornare app.dart, AndroidManifest, Info.plist, pubspec description, doc utente/README
    status: completed
  - id: theme-color-scheme-toh
    content: Nuovo ColorScheme da palette HEX brief; collegare app_theme; grep colori hardcoded Stitch
    status: completed
  - id: dark-theme-minimum
    content: Allineare o documentare dark theme post-cambio palette
    status: completed
  - id: copy-onboarding-notifications
    content: Allineare copy onboarding + notifiche al messaging framework; passata empty/error mirata
    status: completed
  - id: tests-brand-strings
    content: Aggiornare test che assertano 'Housekeep' o titoli obsoleti; flutter analyze + flutter test
    status: completed
  - id: launcher-icons-optional
    content: "Opzionale: nuovi asset AppIcon + flutter_launcher_icons quando pronti"
    status: completed
isProject: false
---

# Piano: applicare il brand The Organized Hive in codebase

## Contesto

- Brand decisions: [docs/brand/the-organized-hive-brand-decisions.md](docs/brand/the-organized-hive-brand-decisions.md).
- Oggi: `MaterialApp.title` = `Housekeep` in [lib/app.dart](lib/app.dart); colori blu/M3 in [lib/core/theme/stitch_color_scheme.dart](lib/core/theme/stitch_color_scheme.dart); tipografia già **Manrope + Inter** in [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) (allineata al brief).
- Package Dart `housekeep` e `applicationId` `com.housekeep.app` restano **invariati** in questa fase (evita rottura installazioni e firma); solo **label visibili** e tema.

## Fase 1 — Costanti brand e titolo app

1. Aggiungere un piccolo modulo costanti, es. `lib/core/brand/app_brand.dart`, con:
  - `appNameDisplay` = `The Organized Hive` (o `Organized Hive` se si preferisce compattezza su status bar — da allineare al doc §3.1).
  - `appNameShort` = `Hive` (notifiche, tooltip dove serva brevità).
  - Costanti opzionali per tagline IT/EN se servono in onboarding/welcome (stringhe letterali o chiavi per futuro `intl`).
2. In [lib/app.dart](lib/app.dart): impostare `MaterialApp.title` dalla costante; valutare `onGenerateTitle` con `Localizations.localeOf` per titolo sistema **IT vs EN** (tagline breve nel titolo è raro; di solito solo nome app).
3. **Android**: [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml) — `android:label` da `housekeep` a nome display brand.
4. **iOS**: [ios/Runner/Info.plist](ios/Runner/Info.plist) — `CFBundleDisplayName` / `CFBundleName` coerenti con il nome display (oggi `Housekeep` / `housekeep`).
5. **pubspec**: aggiornare solo `description` in [pubspec.yaml](pubspec.yaml) verso messaggio allineato al payoff (il campo `name:` resta `housekeep`).
6. Aggiornare [README.md](README.md) (se presente) o [docs/user/overview.md](docs/user/overview.md) con riga “prodotto: The Organized Hive (repo: housekeep)” per evitare confusione.

## Fase 2 — Palette Material 3 dal documento

1. Implementare i token HEX del documento in un file dedicato, es. `lib/core/theme/organized_hive_color_scheme.dart` (o estendere `StitchColors` rinominando/deprecando il nome “Stitch” solo se il team vuole eliminare il riferimento al prototipo).
2. Mappare i token del brief a `ColorScheme` M3 in `lightScheme()`:
  - `primary` / `onPrimary` / `primaryContainer` da `#2F6F6B` e varianti.
  - `secondary` / `secondaryContainer` da terracotta `#C4785A` (contrasto su testo verificato).
  - `surface` / `surfaceContainer`* da `#F7F4EF` e grigi caldi; `error` da `#C4504A` con `errorContainer` coerente.
  - Mantenere `useMaterial3: true` e rivedere [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart) solo se servono aggiustamenti a `ColorScheme` extension custom (es. `amberAccent` usato altrove — grep e allineamento).
3. **Dark theme**: il documento privilegia light come identità; decidere se `buildDarkTheme()` resta approssimativo o viene aggiornato con varianti scure dei token (minimo: contrasto leggibile).
4. Cercare colori hardcoded (`0xFF005DAC`, ecc.) nel `lib/` e sostituire con `Theme.of(context).colorScheme` ove possibile.

## Fase 3 — Copy e voice (incrementale)

1. **Onboarding / welcome**: allineare le prime schermate in [lib/presentation/views/screens/onboarding/](lib/presentation/views/screens/onboarding/) al one-liner e ai pilastri del documento (IT prima; EN se esistono stringhe duplicate o file dedicati).
2. **Empty / error**: passata mirata su stringhe utente in schermate ad alto traffico (inventario, panoramica, lista spesa) vs checklist §8 del doc — senza rifattorizzare tutta l’app in un solo sprint.
3. **Notifiche**: testi in [lib/data/local/repositories/local_notification_repository.dart](lib/data/local/repositories/local_notification_repository.dart) (o dove si costruiscono i body) — prefisso breve “Hive” o nome completo secondo `appNameShort`.

*Nota:* non esiste ancora `l10n` con ARB; una fase successiva opzionale è introdurre `flutter gen-l10n` e spostare stringhe brand-critical in `app_en.arb` / `app_it.arb`.

## Fase 4 — Icona launcher e store (opzionale / asset)

1. Sostituire icone in `android/app/src/main/res/mipmap-`* e set iOS in `ios/Runner/Assets.xcassets/AppIcon.appiconset` con design **esagono/moduli astratti** (brief §7) — richiede asset grafici esterni.
2. Aggiornare `flutter_launcher_icons` in [pubspec.yaml](pubspec.yaml) se già configurato (verificare presenza).

## Fase 5 — Verifica

1. `flutter analyze` su file toccati.
2. `flutter test` (widget test che cercano testo “Housekeep” vanno aggiornati se il nome compare in UI).
3. Smoke manuale: avvio app, task switcher (titolo), tema light, schermata onboarding.

## Fuori scope immediato

- Rinominare `applicationId` / bundle ID / package `housekeep` (migrazione store e utenti).
- Rinominare classe `HousekeepApp` (puramente interno; opzionale refactor cosmetico).

## Ordine consigliato

Fase 1 → Fase 2 → Fase 5 (regressione) → Fase 3 a blocchi → Fase 4 quando gli asset sono pronti.