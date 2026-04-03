# Guida alla pubblicazione su Google Play (Flutter)

Guida operativa per pubblicare **The Organized Hive** (progetto Flutter `housekeep`) sul Google Play Store, partendo dal presupposto che **Google Play Console** sia già attivato (account sviluppatore a pagamento).

**Riferimenti progetto (verifica prima di pubblicare):**

| Voce | Valore attuale |
|------|----------------|
| **Application ID** (immutabile dopo la prima release) | `com.organizedhive.app` |
| **Nome visibile** (etichetta Android) | The Organized Hive |
| **Versione** (`pubspec.yaml`) | `version: 1.0.0+1` → `versionName` 1.0.0, `versionCode` 1 |
| **Firma release** | `android/key.properties` + keystore (vedi §3) |

---

## 1. Panoramica del flusso

1. Preparare **keystore** e **firma release** (una tantum; salva backup in luogo sicuro).
2. Generare **Android App Bundle** (`.aab`) con `flutter build appbundle` — in locale oppure tramite **CI/CD** (vedi §4).
3. In Play Console: **creare l’app** (se non esiste) e compilare tutte le sezioni obbligatorie.
4. Caricare il bundle nella traccia **test interno** (o closed), verificare su dispositivi reali — **manualmente** o **automaticamente** da pipeline (§4).
5. Completare **scheda store**, **Politica sui contenuti**, **Sicurezza dei dati**, **valutazione dei contenuti**, ecc.
6. Inviare per **revisione** e poi promuovere a **produzione** quando approvato.

Google può impiegare da poche ore a diversi giorni per la prima revisione.

---

## 2. Prerequisiti locali

- **Flutter SDK** aggiornato (stabile consigliato), `flutter doctor` senza errori bloccanti su Android.
- **Android SDK** / **JDK** compatibili con il progetto (oggi compile Java 11 nel `build.gradle.kts`).
- Account Play Console con **accordo sviluppatore** accettato e **quota annuale** pagata (se applicabile alla tua regione).

Comandi utili:

```bash
cd /percorso/del/progetto/housekeep
flutter doctor -v
flutter pub get
```

---

## 3. Keystore e firma release (obbligatorio per la pubblicazione)

L’app **non** può essere firmata con la chiave di debug su Play Store. Il progetto è già predisposto per `key.properties` in `android/`.

### 3.1 Generare un keystore (una tantum)

Su Windows (PowerShell o CMD), dalla cartella che preferisci (es. cartella sicura **fuori** dal repo):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

- Scegli password robuste per **keystore** e **chiave**; annotale in un password manager.
- **Conserva** `upload-keystore.jks` e le password: senza di essi **non** potrai aggiornare l’app con la stessa identità (dovresti creare una nuova app con nuovo `applicationId`).

### 3.2 File `key.properties` (non committare nel Git)

Crea `android/key.properties` (è tipicamente in `.gitignore`):

```properties
storePassword=<password del keystore>
keyPassword=<password della chiave>
keyAlias=upload
storeFile=C:/percorso/completo/upload-keystore.jks
```

Su Windows usa path assoluti; su macOS/Linux path assoluto tipo `/Users/tuonome/.../upload-keystore.jks`.

Il `build.gradle.kts` dell’app usa questo file per `signingConfigs.release`.

### 3.3 Play App Signing (consigliato, quasi standard)

In Play Console, alla prima upload, Google propone **Firma dell’app da parte di Google Play**. Accettando:

- Google gestisce la **chiave di firma** usata per distribuire agli utenti.
- Tu firmi gli upload con la **upload key** (il keystore sopra).

Se perdi la upload key, puoi chiedere **reimpostazione upload key** tramite Play Console (con verifiche); la chiave di distribuzione resta su Google.

### 3.4 Verifica build release in locale

```bash
flutter build appbundle --release
```

Output atteso: `build/app/outputs/bundle/release/app-release.aab`.

Se `key.properties` manca, la build può ancora usare firma **debug** (vedi `build.gradle.kts`): **non** caricare quel bundle in produzione.

---

## 4. CI/CD con Codemagic (firma + upload Play)

Obiettivo: **ogni release** produce un `.aab` **firmato** e, se configurato, lo pubblica su Google Play senza passare dal laptop.

### 4.1 Principi

- **Mai** committare `upload-keystore.jks`, `key.properties` o JSON del service account: usa **Environment variables / credentials** in Codemagic.
- Mantieni la stessa **upload key** usata in locale; Play App Signing resta l’opzione consigliata (§3.3).
- Il **`versionCode`** deve essere sempre crescente: aggiorna `pubspec.yaml` (`x.y.z+BUILD`) prima del trigger.

### 4.2 Setup Codemagic nel progetto

1. Crea un account su [Codemagic](https://codemagic.io/) e collega il repository.
2. In Codemagic apri l’app e scegli se usare:
   - **Workflow Editor** (UI, più semplice), oppure
   - `codemagic.yaml` versionato nel repo (più controllabile e replicabile).
3. Imposta trigger (branch `main`/`develop`, tag `v*`, oppure build manuale).

### 4.3 Secret/credential da configurare in Codemagic

Nella sezione **Environment variables** (gruppo protetto), crea:

| Variabile | Contenuto |
|-----------|-----------|
| `CM_KEYSTORE` | `upload-keystore.jks` in Base64 |
| `CM_KEYSTORE_PASSWORD` | Password keystore |
| `CM_KEY_ALIAS` | Alias chiave, es. `upload` |
| `CM_KEY_PASSWORD` | Password della chiave (alias) |
| `PLAY_SERVICE_ACCOUNT_CREDENTIALS` | JSON completo del service account Google Play |

Esempio Base64 su PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\upload-keystore.jks"))
```

### 4.4 Service account Google Play (upload API)

Per l’upload automatico su Play serve un **service account** con accesso alla **Google Play Developer API**:

1. In [Google Cloud Console](https://console.cloud.google.com/) crea (o seleziona) un progetto.
2. Abilita [Google Play Android Developer API](https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/).
3. Crea un service account in [IAM → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts).
4. Genera una chiave **JSON** (download una sola volta).
5. In Play Console → [Users and permissions](https://play.google.com/console/users-and-permissions), invita l’email del service account e assegna i permessi di release sulla tua app/traccia.
6. Incolla il JSON in `PLAY_SERVICE_ACCOUNT_CREDENTIALS` su Codemagic.

### 4.5 Esempio `codemagic.yaml` (Android + Play internal)

Metti questo file in root repository (`codemagic.yaml`) e adatta i nomi variabili/traccia:

```yaml
workflows:
  android-play-internal:
    name: Android Play Internal
    max_build_duration: 60
    environment:
      flutter: stable
      vars:
        PACKAGE_NAME: "com.organizedhive.app"
    scripts:
      - name: Flutter pub get
        script: flutter pub get
      - name: Configure Android signing
        script: |
          echo $CM_KEYSTORE | base64 --decode > $CM_BUILD_DIR/android/upload-keystore.jks
          cat > $CM_BUILD_DIR/android/key.properties <<EOF
          storePassword=$CM_KEYSTORE_PASSWORD
          keyPassword=$CM_KEY_PASSWORD
          keyAlias=$CM_KEY_ALIAS
          storeFile=upload-keystore.jks
          EOF
      - name: Build AAB
        script: flutter build appbundle --release
    artifacts:
      - build/app/outputs/bundle/release/app-release.aab
    publishing:
      google_play:
        credentials: $PLAY_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
        submit_as_draft: false
```

### 4.6 Flusso consigliato

1. Incrementa `version` in `pubspec.yaml` (soprattutto `+BUILD`).
2. Push su branch/tag che attiva il workflow Codemagic.
3. Verifica build logs + artifact `.aab`.
4. Se publishing abilitato, controlla la release in Play Console (traccia `internal` prima di `production`).

### 4.7 Produzione e sicurezza

- Inizia sempre da `internal`, poi `closed`/`open`, infine `production`.
- Proteggi i workflow di produzione (approval manuale / branch protection).
- Ruota periodicamente la chiave service account se sospetti esposizione.

### 4.8 GitHub Actions nel repo (opzionale)

I file in `.github/workflows/` possono restare come CI complementare (analyze/test/artifact). Se usi Codemagic come pipeline principale di release, usa **una sola pipeline “autorizzata a pubblicare”** per evitare rilasci doppi/confusi.

---

## 5. Creare l’applicazione in Google Play Console

1. Accedi a [Google Play Console](https://play.google.com/console).
2. **Crea app** (o seleziona l’app se già creata).
3. Compila i passaggi iniziali: nome app (**The Organized Hive**), lingua predefinita, tipo (app / gioco), gratuito o a pagamento, dichiarazioni policy.

**Attenzione:** l’**applicationId** (`com.organizedhive.app`) deve coincidere con il bundle che carichi; non è modificabile dopo la prima release pubblicata senza creare una nuova inserzione.

---

## 6. Versioning (ogni upload)

- In `pubspec.yaml`: `version: MAJOR.MINOR.PATCH+BUILD`
  - Prima parte → **versionName** (es. `1.0.0`).
  - Dopo `+` → **versionCode** (intero, **sempre crescente** per ogni upload accettato da Play).

Esempio prossimo aggiornamento: `1.0.1+2`, poi `1.0.2+3`, ecc.

Dopo ogni modifica:

```bash
flutter build appbundle --release
```

---

## 7. Tracce di distribuzione (ordine consigliato)

### 6.1 Test interno

- Aggiungi il `.aab` in **Release** → **Testing** → **Test interno**.
- Aggiungi indirizzi email tester (fino al limite consentito).
- I tester installano tramite link Play Store dedicato.

**Perché:** errori di crash, permessi o schermate rotte si vedono prima della revisione pubblica.

### 6.2 Test chiuso / aperto (opzionale)

Utile per gruppi più ampi o beta pubblica prima della produzione.

### 6.3 Produzione

Quando scheda e policy sono complete e i test sono ok, crea una **release in produzione** con lo stesso (o un bundle più nuovo) `.aab`.

---

## 8. Scheda del negozio (Store listing)

### 7.1 Testi (allineati al brand del repo)

Puoi copiare da `docs/brand/the-organized-hive-brand-decisions.md`:

- **Titolo:** The Organized Hive  
- **Breve descrizione (IT):**  
  *Inventario, scadenze, lista spesa e scanner — casa organizzata, insieme.*  
- **Breve descrizione (EN)** (se aggiungi lingua):  
  *Inventory, expiry, grocery list, and scanner — an organized home, together.*  
- **Descrizione completa:** espandi le “prime righe” del documento brand con bullet su inventario, scadenze, lista spesa, scanner, condivisione in casa.

### 7.2 Grafica obbligatoria / tipica

| Asset | Requisito tipico Play |
|--------|------------------------|
| **Icona alta risoluzione** | 512×512 px, PNG a 32 bit, max 1 MB |
| **Icona funzione** (feature graphic) | 1024×500 px (per alcune zone del Play; verifica nella console) |
| **Screenshot telefono** | Minimo 2, consigliati 4–8; formati e risoluzioni indicati nella console (es. 16:9 o 9:16 a seconda del tipo) |
| **Tablet** (se dichiari supporto tablet) | Screenshot aggiuntivi se richiesto |

Usa screenshot reali dell’app (no ingannevoli). Il brand prevede icone/splash dedicati: vedi `docs/brand/` e `docs/brand/launcher-icons-placeholder.md`.

### 7.3 Categorizzazione

- Categoria (es. **Produttività** o **Stile di vita** — scegli la più adatta alla descrizione reale).
- **Contatti sviluppatore:** email di supporto visibile agli utenti (obbligatoria in molte configurazioni).

---

## 9. Permessi dell’app e dichiarazioni

Dal manifest risultano almeno:

- `CAMERA` — per **scanner codici a barre** / acquisizione immagini se usata in quel modo.
- `POST_NOTIFICATIONS` — notifiche locali (Android 13+).

In Play Console, nelle sezioni **Dichiarazione delle autorizzazioni** / **Sicurezza dei dati** / **Modulo funzionalità**:

- Spiega **perché** servono camera e notifiche (uso effettivo nell’app).
- Se la fotocamera è solo per scanner, indicalo chiaramente (niente sorveglianza nascosta, ecc.).

---

## 10. Politica sulla privacy e URL

Per la maggior parte delle app che raccolgono dati o usano permessi sensibili, Play richiede un **URL di informativa sulla privacy** accessibile pubblicamente.

- Se l’app elabora dati solo **in locale** sul dispositivo, comunque documenta cosa succede (backup, export, analytics se presenti).
- Pubblica la policy su un sito o pagina stabile (GitHub Pages, sito aziendale, ecc.) e incolla l’URL nella console.

---

## 11. Sicurezza dei dati (Data safety)

Compila il modulo **Sicurezza dei dati** in modo coerente con il codice:

- Tipi di dati raccolti (es. inventario prodotti, foto se salvate localmente, ecc.).
- Scopo (funzionalità app).
- Condivisione con terze parti (se nessun backend tuo: indicare in modo accurato; eventuali SDK analytics vanno dichiarati).
- Crittografia in transito / a riposo se applicabile.

Incongruenze tra dichiarazione e comportamento reale possono causare **rifiuto** o **rimozione**.

---

## 12. Valutazione dei contenuti (questionario IARC)

Completa il questionario per ottenere la **classificazione per età**. Rispondi in base alle funzioni reali (app di inventario domestico → in genere classificazione ampia e permissiva).

---

## 13. Pubblico di destinazione e app per famiglie

- Indica se l’app è rivolta a **bambini** o no. Se non è pensata per bambini, dichiaralo chiaramente per evitare obblighi del programma “Designed for Families”.
- Allinea le risposte a contenuti e marketing reali.

---

## 14. Target API e compatibilità

Play richiede un **targetSdk** aggiornato (le soglie cambiano nel tempo; Flutter di solito allinea i template). Prima di ogni release:

```bash
flutter build appbundle --release
```

e verifica in Play Console eventuali **avvisi** sul bundle (API target, 64-bit, ecc.).

### 16 KB page size (dispositivi recenti)

Per app con **codice nativo** (Flutter include engine nativo), Google ha introdotto requisiti di compatibilità con **page size 16 KB** su alcuni dispositivi/target. Controlla:

- [Documentazione Android su 16 KB](https://developer.android.com/guide/practices/page-sizes)
- Avvisi in **Play Console** dopo l’upload del bundle (App Bundle Explorer).

Aggiorna Flutter/SDK se la console segnala problemi.

---

## 15. Checklist pre-invio revisione

- [ ] `flutter test` e smoke test manuale su dispositivo fisico (release o profile).
- [ ] Bundle firmato con keystore **release** (`key.properties` presente).
- [ ] `versionCode` incrementato rispetto all’ultimo upload accettato.
- [ ] Screenshot e testi scheda pronti (IT e opzionalmente EN).
- [ ] Icona 512×512 e feature graphic se richiesti.
- [ ] URL privacy policy valido.
- [ ] Modulo Sicurezza dei dati compilato in modo veritiero.
- [ ] Valutazione contenuti completata.
- [ ] Permessi (camera, notifiche) giustificati nella console.
- [ ] Email di contatto / sito sviluppatore se richiesti.

---

## 16. Comandi riepilogativi

```bash
# Dipendenze e analisi
flutter pub get
flutter analyze

# Artifact per Play Store
flutter build appbundle --release
```

File da caricare:  
`build/app/outputs/bundle/release/app-release.aab`

---

## 17. Dopo la pubblicazione

- Monitora **Android vitals** (ANR, crash), recensioni e **policy updates** Google.
- Per ogni versione: aggiorna `pubspec.yaml`, ricostruisci `.aab`, carica nella traccia appropriata, invia note di versione (cosa è cambiato per l’utente).

---

## Riferimenti ufficiali

- [Pubblicare un’app su Google Play](https://support.google.com/googleplay/android-developer/answer/9859348) (Help Center)
- [Flutter — Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Flutter — Continuous delivery](https://docs.flutter.dev/deployment/cd)
- [Google Play Android Developer API — Getting started](https://developers.google.com/android-publisher/getting_started)
- [Codemagic — Publish Flutter app to Google Play](https://docs.codemagic.io/flutter-publishing/publishing-to-google-play/)
- [Codemagic — Flutter apps (yaml/workflows)](https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/)
- [Android App Bundle](https://developer.android.com/guide/app-bundle)
- Brand/copy app: `docs/brand/the-organized-hive-brand-decisions.md`

---

*Ultimo aggiornamento guida: aprile 2026. Verifica sempre le schermate attuali di Play Console e le policy in vigore alla data della tua pubblicazione.*
