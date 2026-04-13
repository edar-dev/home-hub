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

Con **`codemagic.yaml`**, i secret vanno quasi sempre in un **Environment variable group** e il workflow deve dichiarare quel gruppo in `environment.groups` (vedi [documentazione Codemagic — Google Play + YAML](https://docs.codemagic.io/yaml-publishing/google-play/)). Se ometti `groups` o il nome non coincide, le variabili **non** entrano nel build: `PLAY_SERVICE_ACCOUNT_CREDENTIALS` risulta **vuota** e in publish compare l’errore JSON `Expecting value: line 1 column 1 (char 0)`.

1. In Codemagic apri l’app → **Environment variables**.
2. Crea un gruppo (es. **`google_credentials`**) e aggiungi le variabili sotto come **Secret** (stesso nome usato in `codemagic.yaml` in `groups:`).

| Variabile | Contenuto |
|-----------|-----------|
| `CM_KEYSTORE` | `upload-keystore.jks` in Base64 |
| `CM_KEYSTORE_PASSWORD` | Password keystore |
| `CM_KEY_ALIAS` | Alias chiave, es. `upload` |
| `CM_KEY_PASSWORD` | Password della chiave (alias) |
| `PLAY_SERVICE_ACCOUNT_CREDENTIALS` | **Intero** file JSON del service account (da `{` a `}`), incollato così com’è — non Base64, non path su disco |

Se preferisci un altro nome gruppo, usa **lo stesso** in Codemagic e in `codemagic.yaml` (`groups: - nome_gruppo`).

Esempio Base64 su PowerShell:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes("C:\path\upload-keystore.jks"))
```

### 4.4 Service account Google Play (upload API)

Per l’upload automatico su Play serve un **service account** con accesso alla **Google Play Developer API**:

1. In [Google Cloud Console](https://console.cloud.google.com/) crea (o seleziona) un **progetto** (annota il **project id** nel JSON).
2. Abilita [Google Play Android Developer API](https://console.developers.google.com/apis/api/androidpublisher.googleapis.com/) in **quel** progetto.
3. Crea un service account in [IAM → Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts) **in quel progetto**.
4. Genera una chiave **JSON** (download una sola volta) per quel service account.
5. In Play Console → [Users and permissions](https://play.google.com/console/users-and-permissions), **invita** l’**email** del service account (`client_email` nel JSON); in **Autorizzazioni app** aggiungi l’app e i permessi sulle **versioni** / release (traccia *internal* inclusa).  
   Secondo la [documentazione ufficiale attuale](https://developers.google.com/android-publisher/getting_started), **non è più obbligatorio** “collegare” l’account sviluppatore al progetto Cloud da una schermata dedicata in Play Console: conta il service account invitato con i permessi giusti + API abilitata nel progetto dove hai creato la chiave JSON.
6. Incolla il JSON in `PLAY_SERVICE_ACCOUNT_CREDENTIALS` nel gruppo referenziato da `codemagic.yaml` (es. `google_credentials`).

### 4.4a Passo passo: creare il service account e scaricare il JSON

Usa lo **stesso account Google** con cui accedi a Play Console (o un account con diritti di **Amministratore** sul progetto Cloud). I menu possono essere in inglese nell’interfaccia.

#### Parte A — Progetto Google Cloud

1. Apri [Google Cloud Console](https://console.cloud.google.com/).
2. In alto, accanto al logo Google Cloud, apri il **selettore di progetto** (nome progetto o “Select a project”).
3. Clicca **Nuovo progetto** (*New project*):
   - **Nome progetto:** es. `organizedhive-play` (libero, solo per te).
   - **Posizione organizzazione:** lascia “Nessuna organizzazione” se sei su account personale.
4. Clicca **Crea** e attendi qualche secondo; poi **seleziona** quel progetto dal selettore (devi essere *dentro* quel progetto per i passi successivi).

#### Parte B — Abilitare l’API Android Publisher

1. Menu ☰ → **API e servizi** → **Libreria** (*APIs & Services* → *Library*).
2. Cerca **`Google Play Android Developer API`**.
3. Apri il risultato e clicca **Abilita** (*Enable*). Attendi che risulti abilitata.

#### Parte C — Creare il service account

1. Menu ☰ → **IAM e amministrazione** → **Account di servizio** (*IAM & Admin* → *Service Accounts*).
2. Clicca **+ Crea account di servizio** (*Create service account*).
3. **Passo 1 — Dettagli**
   - **Nome account di servizio:** es. `play-upload-codemagic`
   - **ID account di servizio:** si compila da solo (nota l’email che finisce con `@…iam.gserviceaccount.com` — ti servirà dopo).
4. **Passo 2 — Autorizzazioni (facoltativo per Play)**  
   Puoi lasciare **nessun ruolo** qui e andare avanti con **Continua**; i permessi veri per pubblicare su Play si danno dalla **Play Console** (Parte F). Se ti obbliga a scegliere, un ruolo minimo tipo **Utilizzatore account di servizio** (*Service Account User*) va bene.
5. **Passo 3 — Concedi agli utenti l’accesso** → **Fine** / **Fatto**.

#### Parte D — Scaricare la chiave JSON (una sola volta)

1. Nella tabella **Account di servizio**, clicca **sull’email** del service account appena creato (non solo sulla riga).
2. Vai alla scheda **Chiavi** (*Keys*).
3. **Aggiungi chiave** → **Crea nuova chiave** (*Add key* → *Create new key*).
4. Tipo: **JSON** → **Crea**.
5. Si scarica un file `.json` (es. `progetto-xxxxx-abcdef.json`). **Conservalo in luogo sicuro** — non committarlo nel Git.

**Cosa contiene il file:** testo che inizia con `{` e contiene `"type": "service_account"`, `"project_id"`, `"private_key"`, `"client_email"`, ecc.

**Per Codemagic:** apri il file con Blocco note / VS Code, **seleziona tutto** (`Ctrl+A`), **copia**, e incolla il valore nella variabile Secret **`PLAY_SERVICE_ACCOUNT_CREDENTIALS`** (tutto il JSON, una sola “unità” di testo). Non aggiungere virgolette attorno, non mettere solo il path del file.

#### Parte E — (Opzionale) Pagina “Accesso alle API” in Play Console

Google [dichiara](https://developers.google.com/android-publisher/getting_started) che **non serve più** collegare manualmente l’account sviluppatore al progetto Cloud per usare l’API: molti sviluppatori **non vedono** più il vecchio menu **Impostazioni sviluppatore → Accesso alle API** oppure la schermata è vuota / diversa — **è normale**.

Se la tua console la mostra ancora, puoi provare il link diretto (sostituisci con il tuo account se necessario): [play.google.com/console/api-access](https://play.google.com/console/api-access). Eventuale **collegamento** progetto Cloud qui è **facoltativo**; l’essenziale è: **API abilitata nel progetto** dove hai creato il JSON + **invito** del service account (Parte F).

#### Parte F — Invitare il service account in Play Console

1. Play Console → **Utenti e autorizzazioni** (*Users and permissions*).
2. **Invita utenti** → nel campo email incolla **`client_email`** del JSON (es. `play-upload-codemagic@progetto-id.iam.gserviceaccount.com`).
3. Assegna almeno i permessi per **gestire le release** sull’app **The Organized Hive** (o il nome della tua inserzione), inclusa la traccia **test interni** / *internal* se usi quella in `codemagic.yaml`.
4. Completa l’invito (a volte richiede conferma via link se Google lo chiede per l’account di servizio).

Dopo questi passaggi, il JSON in Codemagic è il file scaricato alla **Parte D**, senza modifiche.

### 4.4b Errore: `Expecting value: line 1 column 1 (char 0)` (publish Google Play)

Significa che Codemagic sta parsando **JSON vuoto o non valido** come service account. Controlla nell’ordine:

1. **`environment.groups`** nel workflow Play coincide con un gruppo esistente in Codemagic e quel gruppo contiene `PLAY_SERVICE_ACCOUNT_CREDENTIALS`.
2. Il **valore** è il JSON scaricato da Google (chiave **JSON**), non un file `.p12`, non una stringa vuota, non solo spazi.
3. Il **nome variabile** è esattamente `PLAY_SERVICE_ACCOUNT_CREDENTIALS` (come in `credentials: $PLAY_SERVICE_ACCOUNT_CREDENTIALS` nel YAML).
4. L’app Codemagic è quella giusta (**home-hub**): variabili definite su un’altra app non si applicano.

Il workflow nel repo include uno step **Check Play credentials** che fallisce subito con messaggio esplicito se la variabile è vuota.

### 4.4c Errore Gradle: `Failed to read key … from store "…/upload-keystore.jks": null`

Succede in **`signReleaseBundle`**: Gradle non riesce ad aprire la chiave nel keystore. Cause tipiche:

| Controllo | Cosa verificare |
|-------------|-----------------|
| **`CM_KEYSTORE`** | Deve essere il **Base64 standard** del file **`upload-keystore.jks`** (stesso file che usi in locale per firmare l’upload). Non un `.pem`, non due volte Base64, non path o testo placeholder. Il workflow **rimuove a capo e spazi** nel valore prima del decode (utile se il Base64 è stato spezzato su più righe). Se Codemagic **tronca** i secret molto lunghi, il decode produce un `.jks` invalido: in quel caso usa un gruppo variabili / file come da documentazione Codemagic o un keystore più piccolo. |
| **`CM_KEYSTORE_PASSWORD`** | Password del **keystore** (come `storePassword` in `android/key.properties` locale). Controlla che non ci siano spazi involuti per errore all’inizio/fine nel campo Secret. |
| **`CM_KEY_ALIAS`** | **Esattamente** l’alias mostrato da `keytool -list -keystore upload-keystore.jks` — la riga è tipo `upload, 1 gen 2026, PrivateKeyEntry`: l’alias è il testo **prima della prima virgola** (es. `upload`). Maiuscole/minuscole contano. Se nel keystore c’è **una sola** `PrivateKeyEntry`, il `codemagic.yaml` del repo **corregge automaticamente** l’alias; conviene comunque impostare `CM_KEY_ALIAS` uguale a quello di `key.properties` / `keytool -list`. |
| **`CM_KEY_PASSWORD`** | Password della **chiave** (`keyPassword` in `key.properties`). Se in locale è uguale alla store password, metti lo stesso valore in Codemagic. |
| **Caratteri speciali** | Se la password contiene `$`, `` ` ``, `!`, virgolette, il vecchio script con `echo` poteva corrompere `key.properties`. Il `codemagic.yaml` nel repo usa `printf` per evitarlo: aggiorna il workflow. |

**Verifica in locale** (stesso `.jks` che hai codificato in Base64):

```bash
keytool -list -keystore path/to/upload-keystore.jks
```

Annota **Alias name** e prova le stesse password che metterai in Codemagic. Dopo l’aggiornamento dello YAML, lo step **Configure Android signing** esegue `keytool` su CI: se fallisce lì, il log indica se il problema è store password / alias, prima del build Gradle.

### 4.4d Errore publish: `Package not found: com.organizedhive.app`

L’**AAB è valido** e le credenziali JSON **autenticano** l’API, ma l’**Android Publisher API** non trova un’app con `applicationId` **`com.organizedhive.app`** nel contesto autorizzato per quel service account. Succede quasi sempre se manca uno tra: **permessi app** sul service account, **primo bundle accettato**, **`applicationId` errato nel repo**.

**Controlli nell’ordine:**

| # | Controllo | Cosa fare |
|---|-----------|-----------|
| **A** | **API abilitata nel progetto del JSON** | Nel [Google Cloud Console](https://console.cloud.google.com/), seleziona il progetto il cui **`project_id`** è **dentro** il file JSON usato da Codemagic → **API e servizi** → **Libreria** → abilita **Google Play Android Developer API** (*androidpublisher*). |
| **B** | **Service account invitato in Play Console** | [Utenti e autorizzazioni](https://play.google.com/console/users-and-permissions) → l’email `…@….iam.gserviceaccount.com` del JSON deve comparire come utente attivo (non solo creata in Cloud). |
| **C** | **Permessi sull’app** | Scheda di quell’utente → **Autorizzazioni app** → aggiungi **The Organized Hive** (o il nome dell’inserzione) → permessi sulle **versioni** / **release** (traccia **internal** / test interni). Senza accesso all’app, l’API può rispondere *Package not found*. |
| **D** | **Primo `.aab` accettato da Play** | **Test e release** → **Test interno** → crea una release e carica **manualmente** l’`app-release.aab` finché Play **accetta** il bundle; verifica il package in **App bundle explorer**. Poi riprova Codemagic. |
| **E** | **Stesso `applicationId` nel repo che compila** | Il bundle deve avere **`com.organizedhive.app`**. Verifica su **home-hub** che `android/app/build.gradle.kts` non usi un altro `applicationId`. |
| **F** | *(Opzionale)* **Collegamento Cloud in Play** | Se la tua console mostra ancora **Accesso alle API** e un collegamento progetto, puoi allinearlo al `project_id` del JSON; [Google indica](https://developers.google.com/android-publisher/getting_started) che **non è più richiesto** per far funzionare l’API. |

**Workaround immediato:** disattiva temporaneamente la sezione `publishing:` in `codemagic.yaml`, scarica l’`.aab` dagli artifact, caricalo a mano in **Test interno**; quando la console mostra il package e i controlli **A–D** sono ok, riattiva il publish automatico.

**Verifica pacchetto dentro l’`.aab` (locale):** con [bundletool](https://github.com/google/bundletool) o aprendo il manifest generato; in alternativa, dopo upload in Console il package è visibile nei dettagli versione / bundle explorer.

### 4.5 Esempio `codemagic.yaml` (Android + Play internal)

Metti questo file in root repository (`codemagic.yaml`) e adatta i nomi variabili/traccia:

```yaml
workflows:
  android-play-internal:
    name: Android Play Internal
    max_build_duration: 60
    environment:
      flutter: stable
      groups:
        - google_credentials
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

Il file **`codemagic.yaml` nel repository** non imposta `instance_type`: così Codemagic usa il **default consentito dal tuo piano**. Valori come `linux_x2` richiedono di solito **fatturazione attiva** o un piano a pagamento ([pricing Codemagic](https://docs.codemagic.io/billing/pricing/)). Se vedi *The selected instance type is not available with the current billing plan*, rimuovi o non impostare `instance_type`, oppure abilita il piano che include quella macchina.

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

**Prima** di aspettarti un upload riuscito da **Codemagic**, in Play Console deve esistere l’**inserzione app** (dopo **Crea app**) e deve essere stato accettato almeno un **`.aab`** con il package giusto, oppure il service account deve avere accesso a quell’inserzione. Se manca l’inserzione, il bundle o i permessi, il publish fallisce con *Package not found* (§4.4d).

1. Accedi a [Google Play Console](https://play.google.com/console).
2. **Crea app** (o seleziona l’app se già creata).
3. Completa il wizard iniziale (app/gioco, gratuito/a pagamento, dichiarazioni, termini **Play App Signing**). **Non è anomalo se non ti chiede il nome pacchetto:** su molte console quel dato si fissa al **primo upload** del bundle.
4. Imposta nome e scheda come da **§5.1** e **§8** (es. **The Organized Hive**).
5. Quando la dashboard lo consente, in **Test interno** carica il primo **`app-release.aab`**: il package sarà quello nel file (per questo progetto: **`com.organizedhive.app`**, vedi `android/app/build.gradle.kts`). Dopo quel passaggio, l’inserzione è “legata” a quel `applicationId`.

**Attenzione:** l’**applicationId** (`com.organizedhive.app`) deve coincidere con il bundle che carichi; non è modificabile dopo la prima release pubblicata senza creare una nuova inserzione.

### 5.1 Checklist: creare e configurare l’app (da zero)

Segui l’ordine: alcuni passaggi sbloccano il caricamento del bundle o il link per i tester.

| # | Dove in Play Console | Cosa fare |
|---|----------------------|-----------|
| 1 | **Tutte le app** → **Crea app** | Nome app: **The Organized Hive**. Tipo: **App** o **Gioco**. **Gratuita** o a pagamento. Accetta dichiarazioni (policy, export USA, **Play App Signing**). *Se non compare il campo “nome pacchetto”, è atteso: vedi riga 3.* |
| 2 | **Dashboard** | Completa le voci evidenziate finché puoi aprire **Test interno** e caricare un bundle. Di solito servono: **Scheda Google Play** (titolo, testi, 2 screenshot, icona 512×512), **Valutazione dei contenuti**, target / pubblico, **Sicurezza dei dati**, **Politica sulla privacy** (URL se richiesto). |
| 3 | **Release** → **Testing** → **Test interno** → **Nuova release** | Carica **`app-release.aab`** con `applicationId` **`com.organizedhive.app`** (deve coincidere con `android/app/build.gradle.kts`). **Qui** Play associa il package all’inserzione. Se il `.aab` ha un altro package, la console lo segnala e non devi “inventare” un nome a mano. |
| 4 | Test interno → **Testers** | Aggiungi **indirizzi Google** dei tester; usa il **link** d’invito. |
| 5 | **Utenti e autorizzazioni** (per Codemagic) | Invita l’**email del service account**. **Autorizzazioni app** → questa app → permessi **versioni / release** (traccia `internal`). Vedi §4.4. |
| 6 | Dopo il primo `.aab` accettato | Verifica il package in **Test e release** → **App bundle explorer** (o dettaglio versione). Gli upload da **Codemagic** sulla traccia `internal` useranno lo stesso `applicationId`. *Package not found* (§4.4d) = inserzione senza bundle ancora accettato, account sbagliato, o service account senza accesso all’app. |

**Suggerimento:** tieni aperta la [guida ufficiale “Pubblicare un’app”](https://support.google.com/googleplay/android-developer/answer/9859348) in parallelo: le etichette dei menu cambiano leggermente nel tempo.

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

Nel repository e disponibile una bozza pronta in `docs/legal/privacy-policy.md`.

URL pratici da usare:

- **Subito (senza setup aggiuntivo):**
  - `https://github.com/<owner>/<repo>/blob/main/docs/legal/privacy-policy.md`
- **Consigliato (URL pulito):**
  - abilita GitHub Pages e pubblica dalla cartella `docs/`, poi usa:
  - `https://<owner>.github.io/<repo>/legal/privacy-policy/`

Per questo progetto, sostituisci `<owner>/<repo>` con il repository reale che pubblichi su Play (es. `edar-dev/home-hub`).

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
