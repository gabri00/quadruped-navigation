# quadruped-navigation 🤖

Progetto ROS 2 per la navigazione di robot quadrupedi, con ambiente di sviluppo containerizzato tramite Docker. Funziona su **Mac**, **Windows** e **Linux** senza dover installare ROS sul proprio computer.

---

## Indice

1. [Come funziona tutto insieme](#come-funziona-tutto-insieme)
2. [Struttura della repository](#struttura-della-repository)
3. [Concetti chiave](#concetti-chiave)
4. [Prerequisiti comuni](#prerequisiti-comuni)
5. [Guida per macOS](#guida-per-macos)
6. [Guida per Windows](#guida-per-windows)
7. [Guida per Linux](#guida-per-linux)
8. [Flusso di lavoro quotidiano](#flusso-di-lavoro-quotidiano)
9. [Risoluzione dei problemi](#risoluzione-dei-problemi)

---

## Come funziona tutto insieme

```
Il tuo computer (Mac / Windows / Linux)
│
├── quadruped-navigation/     ← la tua repository Git
│   ├── src/                  ← il tuo codice ROS (modificato dal tuo editor)
│   └── ...
│
└── Docker
        └── Container Linux con ROS 2 Jazzy
                └── /home/rosuser/quadruped-navigation/  ← stessa cartella, montata
                        ├── src/       ← vede le tue modifiche in tempo reale
                        ├── build/     ← generato da colcon (non committare)
                        └── install/   ← generato da colcon (non committare)
```

**Il punto chiave:** la tua cartella `quadruped-navigation/` sul computer e quella dentro il container sono **la stessa cosa**. Docker la "monta" come un disco condiviso. Modifichi un file con VSCode fuori dal container, e il container lo vede immediatamente — senza dover riavviare nulla.

---

## Struttura della repository

```
quadruped-navigation/
├── Dockerfile          ← descrive come costruire il container
├── docker-compose.yml  ← configura come avviare il container
├── entrypoint.sh       ← script che prepara ROS all'avvio del container
├── .gitignore          ← esclude da Git le cartelle generate da colcon
├── README.md           ← questo file
└── src/                ← i tuoi package ROS vanno qui
    └── (vuota per ora, aggiungi i tuoi package qui)
```

> **Importante:** crea la cartella `src/` prima di avviare Docker:
> ```bash
> mkdir src
> ```

---

## Concetti chiave

### Cos'è Docker?

Docker crea una "scatola virtuale" (chiamata **container**) che contiene un sistema Linux completo con ROS 2 già installato. Chiunque nel team avvia la stessa identica scatola, indipendentemente dal proprio sistema operativo. Non serve installare ROS sul proprio computer.

### Container vs. immagine

- **Immagine**: la ricetta, costruita una volta dal `Dockerfile`. È come un sistema operativo "congelato".
- **Container**: un'istanza avviata dell'immagine. È come accendere un computer.

Devi ricostruire l'immagine (`docker compose build`) **solo se modifichi il `Dockerfile`**, per esempio per installare una nuova libreria di sistema. Per il codice ROS non serve.

### Cos'è colcon?

`colcon` è il **sistema di compilazione di ROS 2**. Il codice ROS (nodi, messaggi, action, ecc.) deve essere compilato prima di poter essere eseguito. `colcon build` legge tutti i package in `src/`, li compila e produce il risultato in `install/`.

```
src/         ← il tuo codice sorgente  ✅ committato su Git
build/       ← file intermedi          ❌ NON committare
install/     ← codice compilato        ❌ NON committare
log/         ← log di compilazione     ❌ NON committare
```

Le cartelle `build/`, `install/` e `log/` sono già nel `.gitignore` — vengono ricreate automaticamente ogni volta che esegui `colcon build`.

### Devo ribuildare il container ogni volta che modifico il codice?

**No.** Esistono due operazioni completamente separate:

| Operazione | Quando serve | Tempo |
|------------|-------------|-------|
| `docker compose build` | Solo se modifichi il `Dockerfile` (nuova libreria di sistema, ecc.) | Minuti |
| `colcon build` | Ogni volta che modifichi il codice in `src/` | Secondi / minuti |

Il flusso normale è: modifichi il codice → dentro il container esegui `colcon build` → lanci il tuo nodo. Il container non si tocca.

### Perché un utente non-root nel container?

Se il container girasse come `root`, tutti i file che crea (come `build/` e `install/`) apparirebbero sull'host come proprietà di `root`, e dovresti usare `sudo` per modificarli o eliminarli. Con un utente normale (stesso UID del tuo utente host) i file restano tuoi.

---

## Prerequisiti comuni

Tutti i sistemi hanno bisogno di **Docker Desktop**:

👉 https://www.docker.com/products/docker-desktop/

- **Mac**: scarica la versione per Apple Silicon (M1/M2/M3) oppure Intel
- **Windows**: richiede Windows 10/11 con WSL2
- **Linux**: puoi installare Docker Engine direttamente

Verifica che Docker funzioni:
```bash
docker --version
# Es: Docker version 27.x.x
```

---

## Guida per macOS

### Quale architettura ho?

Vai su **Menù Apple → Info su questo Mac**:
- "Chip Apple M1 / M2 / M3" → **Apple Silicon** → usa `linux/arm64`
- "Processore Intel" → usa `linux/amd64`

### Passo 1 — Installa XQuartz

ROS usa il protocollo grafico **X11** per le finestre (Rviz2, rqt). macOS non lo ha nativo, quindi serve XQuartz che fa da ponte tra il container e il tuo desktop.

👉 https://www.xquartz.org/

Installa e **riavvia il Mac**.

### Passo 2 — Configura XQuartz

1. Apri XQuartz (Applicazioni → Utility → XQuartz)
2. Vai in **XQuartz → Preferenze → Sicurezza**
3. Spunta **"Consenti connessioni da client di rete"**
4. Chiudi e riapri XQuartz

### Passo 3 — Configura docker-compose.yml

Apri `docker-compose.yml` e modifica la riga `platform`:
```yaml
# Apple Silicon (M1/M2/M3):
platform: linux/arm64

# Intel:
platform: linux/amd64
```

Aggiungi nella sezione `environment`:
```yaml
- DISPLAY=host.docker.internal:0
```

### Passo 4 — Avvia il container

Ogni volta che vuoi lavorare, esegui questi comandi nell'ordine:

```bash
# 1. Autorizza Docker ad usare XQuartz (una volta per sessione)
xhost +localhost

# 2. Imposta il display (una volta per sessione, in ogni nuovo terminale)
export DISPLAY=host.docker.internal:0

# 3. Prima volta: costruisci e avvia
docker compose up --build

# Volte successive: avvia direttamente
docker compose up
```

---

## Guida per Windows

### Prerequisiti

#### Abilita WSL2

Apri PowerShell come Amministratore:
```powershell
wsl --install
```
Riavvia quando richiesto.

#### Installa Docker Desktop

👉 https://www.docker.com/products/docker-desktop/

Durante l'installazione seleziona **"Use WSL 2 instead of Hyper-V"**. Dopo, vai in Docker Desktop → Settings → Resources → WSL Integration → abilita la tua distro.

### Opzione A — Windows 11 con WSLg (raccomandato)

Windows 11 include **WSLg**, un server grafico integrato. Non serve nulla di extra.

Da WSL2:
```bash
cd /percorso/a/quadruped-navigation
docker compose up --build   # prima volta
docker compose up           # volte successive
```

### Opzione B — Windows 10 (o Windows 11 senza WSLg)

Serve **VcXsrv** come server grafico.

👉 https://sourceforge.net/projects/vcxsrv/

**Ogni volta che vuoi usare le GUI:**
1. Avvia XLaunch → Multiple windows → Display 0 → spunta "Disable access control"
2. Trova l'IP di WSL2 da PowerShell:
   ```powershell
   wsl hostname -I
   ```
3. Da WSL2:
   ```bash
   export DISPLAY=<IP_TROVATO>:0.0
   cd /percorso/a/quadruped-navigation
   docker compose up --build   # prima volta
   docker compose up           # volte successive
   ```

Aggiungi nel `docker-compose.yml` sotto `environment`:
```yaml
- DISPLAY=<IP_TROVATO>:0.0
```

---

## Guida per Linux

Il caso più semplice: X11 è già nativo.

```bash
# Autorizza Docker ad usare il display (una volta per sessione)
xhost +local:docker

cd /percorso/a/quadruped-navigation
docker compose up --build   # prima volta
docker compose up           # volte successive
```

---

## Flusso di lavoro quotidiano

### 1. Avvia il container

Segui le istruzioni del tuo OS qui sopra. Una volta avviato, sei dentro una shell Linux con ROS pronto.

### 2. Apri ulteriori shell nel container (se servono)

Dal tuo terminale host, in una nuova finestra:
```bash
docker exec -it ros_jazzy_desktop bash
```

### 3. Modifica il codice

Usa il tuo editor preferito (VSCode, ecc.) **fuori dal container**, nella cartella `quadruped-navigation/src/` sul tuo computer. Le modifiche sono visibili nel container in tempo reale.

### 4. Compila con colcon

**Dentro il container:**
```bash
cd ~/quadruped-navigation

# Installa le dipendenze dei tuoi package (solo quando aggiungi nuove dipendenze)
rosdep install --from-paths src --ignore-src -r -y

# Compila
colcon build

# Attiva il workspace compilato (necessario in ogni nuova shell)
source install/setup.bash
```

> **Tip:** puoi compilare un solo package invece di tutto:
> ```bash
> colcon build --packages-select nome_package
> ```

### 5. Lancia i tuoi nodi

```bash
ros2 run nome_package nome_nodo
ros2 launch nome_package nome_launch.py
```

### 6. Strumenti grafici

```bash
rviz2       # visualizzatore 3D
rqt         # suite di strumenti grafici ROS
```

### 7. Spegni il container

```bash
# Dal terminale host
docker compose down

# Oppure Ctrl+C se è in foreground
```

---

## Risoluzione dei problemi

### "Cannot open display" — Rviz2 non si apre

| Sistema | Soluzione |
|---------|-----------|
| Mac | Verifica che XQuartz sia aperto e `DISPLAY=host.docker.internal:0` sia impostato |
| Windows | Verifica che VcXsrv sia avviato con "Disable access control" |
| Linux | Esegui `xhost +local:docker` prima di avviare il container |

### Schermo nero in Rviz2

Aggiungi nell'`environment` del `docker-compose.yml`:
```yaml
- LIBGL_ALWAYS_SOFTWARE=1
```
Disabilita l'accelerazione GPU (più lento ma funziona sempre).

### Il container è lento su Mac Apple Silicon

Se stai usando `platform: linux/amd64` su un Mac ARM, Docker emula l'architettura x86. Usa `linux/arm64` per le prestazioni native.

### I file generati da colcon hanno permessi sbagliati (Linux)

Il `USER_UID` nel Dockerfile deve corrispondere al tuo UID utente. Controlla:
```bash
id -u   # di solito 1000
```
Se è diverso, esegui il build con:
```bash
docker compose build --build-arg USER_UID=$(id -u)
```

### "colcon: command not found"

Sei fuori dal container. Entra con:
```bash
docker exec -it ros_jazzy_desktop bash
```

### Modifiche al codice non si vedono nel container

Verifica che il volume sia montato correttamente. Dentro il container:
```bash
ls ~/quadruped-navigation/src/
```
Dovresti vedere gli stessi file che hai sul tuo computer.
