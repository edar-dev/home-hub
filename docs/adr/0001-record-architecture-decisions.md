# 0001. Tracciare le decisioni con ADR

- Stato: Accettato
- Data: 2026-03-28

## Contesto

Il progetto cresce (feature, persistenza, CI). Senza storico scritto, le motivazioni di scelte passate si perdono e si rischia di ripetere dibattiti o contraddire il design.

## Decisione

Usare **Architecture Decision Records** in `docs/adr/`: un file numerato per decisione, con contesto, decisione, conseguenze e alternative.

## Conseguenze

- Onboarding più chiaro per nuovi contributor.
- Leggero overhead: aggiornare o aggiungere ADR quando si cambia strategia importante.

## Alternative scartate

- Wiki esterna sola (meno versionata col codice).
- Solo commenti sparsi nel codice (difficile trovare il quadro).
