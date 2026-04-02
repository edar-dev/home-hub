# The Organized Hive — documento di decisioni di brand

**Versione:** 1.0  
**Stato:** decisioni chiuse per implementazione (copy, store, UI, icona)  
**Aggiornamento:** da usare come riferimento unico per designer, copywriter e chi cura store listing.

Questo file **consolida le scelte operative** derivate dal branding brief strategico. Per narrativa estesa (mission, competitor, manifesto) fare riferimento al brief completo condiviso con il team.

---

## 1. Scopo

- Allineare **tagline**, **subtitle store**, **palette**, **tipografia** e **vincoli visivi/voce** senza ambiguità.
- Ridurre reinterpretazioni in fase di UI, marketing e pubblicazione sugli store.

---

## 2. Decisioni chiuse (sintesi)

| Area | Decisione |
|------|-----------|
| Nome brand (master) | **The Organized Hive** |
| Nome breve in-app / icona | **Hive** (lockup secondario; non sostituisce il master brand) |
| Direzione visiva | Caldo **premium-accessible**: ordine modulare, hive **astratto** (no mascotte ape) |
| Tagline primaria (IT) | *La casa, a colpo d’occhio.* |
| Tagline primaria (EN) | *Your home, at a glance.* |
| Payoff / one-liner (IT) | *Inventario, scadenze e spesa in un solo posto chiaro — per chi coordina la casa.* |
| Payoff / one-liner (EN) | *Inventory, expiry, and shopping in one clear place — for whoever runs the home.* |
| Tono | Chiaro, calmo, competente; no corporate freddo, no infantilismo, no metafore api forzate |

---

## 3. Naming e store listing

### 3.1 Display name (suggerito)

| Store | Display name | Nota |
|-------|----------------|------|
| Apple App Store | **The Organized Hive** | Se troppo lungo in certe viste, valutare **Organized Hive** solo come variant display dopo test ASO |
| Google Play | **The Organized Hive** | Coerente con iOS |

### 3.2 Sottotitolo / short description (max ~80 caratteri dove possibile)

**Italiano (subtitle / breve descrizione)**  
*Inventario, scadenze, lista spesa e scanner — casa organizzata, insieme.*

**English (subtitle / short description)**  
*Inventory, expiry, grocery list, and scanner — an organized home, together.*

### 3.3 Descrizione lunga — prime righe (boilerplate)

**IT**  
The Organized Hive è l’hub per tenere sotto controllo cosa hai in casa, dove si trova e quando scade. Scanner, lista spesa e promemoria sono collegati al tuo inventario reale, così riduci sprechi e attriti. Pensato per essere **condiviso** con chi vive con te.

**EN**  
The Organized Hive is the hub for what you have at home, where it lives, and when it expires. Scanning, grocery lists, and reminders connect to your real inventory—so you waste less and argue less. Built to be **shared** with the people you live with.

---

## 4. Messaging — gerarchia

1. **Brand name** → The Organized Hive  
2. **Tagline** → (vedi §2)  
3. **One-liner** → (vedi §2)  
4. **Pilastri prodotto** (per bullet store e onboarding):  
   - Inventario per luoghi e posizioni  
   - Scadenze e promemoria  
   - Lista spesa collegata al reale  
   - Scanner codici a barre  
   - Collaborazione in casa  

**Tagline alternative approvate** (A/B test o social):  
- *Ordine domestico, senza sforzo inutile.*  
- *Meno domande, più chiarezza.*  
- *Condividi la casa, non il caos.*

---

## 5. Palette colore (HEX) — direzione “caldo premium-accessible”

Uso: UI app, icona, materiali marketing. Aggiustare contrasto WCAG su testo piccolo.

| Token | HEX | Uso |
|-------|-----|-----|
| `brand-primary` | `#2F6F6B` | Teal salvia — azioni primarie, elementi chiave marca |
| `brand-primary-dark` | `#1F4F4C` | Testo su chiaro, pressed state |
| `brand-secondary` | `#C4785A` | Terracotta calda — accenti domestici, CTA secondarie |
| `surface-canvas` | `#F7F4EF` | Sfondo principale (warm white) |
| `surface-elevated` | `#FFFFFF` | Card, sheet |
| `text-primary` | `#1C1B1A` | Corpo testo |
| `text-secondary` | `#5C5A57` | Supporto, caption |
| `border-subtle` | `#E3DFD6` | Divider, outline leggeri |
| `state-success` | `#5A7D5A` | Ok, sincronizzato (verde oliva, non neon) |
| `state-warning` | `#C9A227` | Attenzione morbida |
| `state-error` | `#C4504A` | Errori (corallo, non rosso allarme puro) |
| `accent-focus` | `#2E4057` | Link, focus tech (blu inchiostro) |

**Razionale:** primario calmo e “vivo”; secondario caldo per umanizzare; neutri crema per lunga lettura; stati leggibili senza clinicità ospedaliera.

---

## 6. Tipografia

| Ruolo | Direzione | Razionale |
|-------|-----------|-----------|
| Titoli / display | Sans geometric-humanist (es. famiglia con aperture ampie, tipo *Outfit*, *Manrope*, *DM Sans* — scelta finale a carico design system) | Modernità + calore |
| Corpo / UI | Sans neutra ad alta leggibilità (es. *Inter*, *Source Sans 3*) | Retention, schermate dense |
| Regola | Evitare serif display per UI mobile; massimo 2 famiglie | Coerenza e performance |

---

## 7. Logo e icona app

| Elemento | Decisione |
|----------|-----------|
| Logo | Wordmark **The Organized Hive** + simbolo opzionale **astratto** (esagono / cluster moduli); **no** ape illustrata come elemento dominante |
| Icona | Forma semplice a dimensione piccola: esagono stilizzato o 3–4 celle; deve funzionare in **monocromatico** per adaptive icon Android |
| Pattern | Micro-pattern esagonale solo come sfondo molto leggero (opacità bassa) |

---

## 8. Voice & tone — snapshot operativo

- **Voce:** chiara, calma, competente, rispettosa.  
- **Principi:** beneficio concreto prima del meccanismo; una idea per frase; verbi d’azione; italiano/inglese stesso registro (friendly-professional).

**Terminologia preferita (IT)**  

| Usa | Evita |
|-----|--------|
| Luogo, Posizione, Prodotto | Asset, SKU, entity |
| Lista spesa | Cart (se non è e-commerce) |
| Promemoria | Notification center (in UI utente) |
| Insieme / Condividi con… | Tribe, swarm, hive slang |

**Esempi microcopy**  
- Empty: *Non hai ancora luoghi. Aggiungine uno per iniziare.*  
- Errore: *Non abbiamo salvato. Controlla la connessione e riprova.*  
- Notifica: *Scadenza tra 3 giorni: [nome] in [luogo].*

---

## 9. Coerenza cross-canale

| Canale | Obbligo |
|--------|----------|
| App | Tagline in onboarding solo se supportata da schermata successiva con valore concreto |
| App Store / Play | Stesso nome display, subtitle allineato a §3.2, screenshot narrativi (inventario → scadenza → lista → condivisione) |
| Sito / landing | Hero: nome + tagline + one-liner; CTA: *Scarica l’app* / *Inizia gratis* |
| Social | Territori: chiarezza domestica, meno spreco, collaborazione; **no** meme api |

---

## 10. Checklist “non fare”

- [ ] Illustrazioni letterali di api / miele come identità principale  
- [ ] Emoji come sostituto del significato in UI core  
- [ ] Tono da corporate memo o jargon B2B  
- [ ] Urgenza finta nelle notifiche  
- [ ] Promesse assolute (“zero sforzo”, “mai più dimenticanze”)  

---

## 11. Prossimi passi operativi (post documento)

1. Applicare palette e tipografia nel design system (Figma / theme Flutter).  
2. Inserire subtitle IT/EN negli store (e localizzazioni future).  
3. Allineare stringhe onboarding alle prime 4 righe del messaggio prodotto.  
4. Brief unico a designer per icona (esagono astratto + variant dark).  
5. Revisione microcopy schermate esistenti vs §8.  

---

## 12. Nota su Housekeep

Il codice e il repository possono mantenere il nome tecnico **housekeep**; questo documento definisce il **brand prodotto consumer** **The Organized Hive** per comunicazione, store e UI copy pubblica. **Application ID Android** e **bundle ID iOS:** `com.organizedhive.app`. Allineare `pubspec.yaml` / nome legal entity secondo roadmap legale e ASO.

---

## 13. Implementazione tecnica (riferimento dev)

**Tema chiaro:** `lib/core/theme/organized_hive_color_scheme.dart` — `OrganizedHiveColors.lightScheme()` mappa i token §5 a Material 3.

**Tema scuro:** `OrganizedHiveColors.darkScheme()` usa `ColorScheme.fromSeed` sul colore primario brand. È un’identità **secondaria** rispetto al light; contrasto e leggibilità hanno priorità su fedeltà cromatica 1:1 con il prototipo Stitch.

**Costanti copy:** `lib/core/brand/app_brand.dart` (`appNameDisplay`, `appNameShort`, payoff).

**Icona launcher / store:** sostituire asset in `android/.../mipmap-*` e `ios/Runner/Assets.xcassets/AppIcon.appiconset` quando il design esagono/moduli è disponibile; opzionale configurazione `flutter_launcher_icons` in `pubspec.yaml`.
