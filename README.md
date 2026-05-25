# claudefm

Reproductor CLI mínimo para [claudeFM](https://www.youtube.com/watch?v=YmQ7jRgf4f0), la radio de YouTube curada por Claude para programar y pensar. Sin abrir el navegador.

```
♪ Claude FM 🎵 music for thinking and building 2026-05-25 13:39  ·  00:00:29  ·  vol 100%
```

## Cómo funciona

Es un script bash de ~30 líneas que orquesta dos herramientas:

1. `yt-dlp` resuelve el live de YouTube a una URL HLS reproducible.
2. `mpv` reproduce esa URL en modo solo-audio, con una línea de estado personalizada.

El script no descarga, no cachea, no abre ventana. Solo suena.

## Requisitos

- `mpv` — reproductor.
- `yt-dlp` — extractor de YouTube. **Importante:** la versión del paquete `apt` suele ir meses por detrás del API actual de YouTube y falla con "Precondition check failed". Usa el binario standalone (ver más abajo).

## Instalación

### Opción A — One-liner (recomendado)

Descarga `claudefm`, le siembra una config por defecto en `~/.config/claudefm/url`, y si no tienes `yt-dlp` te baja el binario standalone:

```bash
curl -fsSL https://raw.githubusercontent.com/sanhuaaan/claudefm/main/install.sh | bash
```

Variables opcionales:

```bash
# Instalar en /usr/local en lugar de ~/.local
PREFIX=/usr/local curl -fsSL .../install.sh | sudo bash
```

Después solo necesitas `mpv` instalado a través del gestor de paquetes:

```bash
sudo apt install -y mpv     # Debian / Ubuntu
brew install mpv            # macOS
```

### Opción B — Clone + make install

```bash
git clone https://github.com/sanhuaaan/claudefm.git
cd claudefm
make check      # verifica que mpv y yt-dlp están disponibles
make install    # copia claudefm a ~/.local/bin y siembra ~/.config/claudefm/url
```

Para desinstalar: `make uninstall` (deja la config intacta).

Variables del Makefile (`make help` las lista): `PREFIX`, `BINDIR`, `CONFIG_DIR`.

### Sobre yt-dlp

`yt-dlp` cambia cada pocas semanas porque YouTube rota tokens y endpoints internos. Tres formas de tenerlo:

- **Binario standalone** (lo que hace `install.sh`): un solo ejecutable autosuficiente con Python embebido.
  ```bash
  curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux \
    -o ~/.local/bin/yt-dlp && chmod +x ~/.local/bin/yt-dlp
  ```
- **pipx** (si tienes Python ≥ 3.10): `pipx install yt-dlp`. Actualiza con `pipx upgrade yt-dlp`.
- **apt**: **NO recomendado**. La versión del paquete suele ir meses por detrás y falla con "Precondition check failed".

## Uso

```bash
claudefm              # solo audio (default)
claudefm --video      # renderiza el vídeo en la terminal (auto: kitty o bloques)
claudefm --blocks     # fuerza modo bloques (tct) incluso dentro de kitty
claudefm --help       # opciones y controles
```

Verás:

```
→ resolving stream...
♪ claudeFM  ·  🎧 556 ▁▂▃▅▇▆▅  ·  on for 23h 14m  ·  00:00:29
```

La línea inferior se actualiza en sitio mientras suena. `🎧 N` es la audiencia en directo y la sparkline `▁▂▃▅▇▆▅` muestra cómo ha ido subiendo o bajando durante tu sesión (rolling de los últimos 8 muestreos).

Cómo funciona por dentro:

- Un poller en background relanza `yt-dlp --print '%(concurrent_view_count)s'` cada 30 segundos.
- Mantiene un buffer rolling de los últimos 8 valores y los mapea a 8 alturas de bloques Unicode (`▁`…`█`).
- Un script Lua dentro de mpv (`stats.lua`) lee el fichero de status cada segundo y actualiza `force-media-title`, que es lo que aparece en `${media-title}` del status line.

En **modo `--video`** el poller se desactiva: ya estás viendo el live, no hace falta resumirlo.

### Modo vídeo

Con `--video`, claudefm pinta el live dentro de la terminal. El driver de mpv se elige automáticamente:

- **kitty terminal** (`$TERM=xterm-kitty`): usa `--vo=kitty`, render pixel-perfect via el [kitty graphics protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/). Cada frame se envía como PNG codificado en escape sequences. Calidad cercana al vídeo nativo.
- **Otras terminales truecolor**: usa `--vo=tct`, dibuja cada par de píxeles como un bloque `▀` con dos colores ANSI. Más blocky pero funciona en cualquier emulador moderno.

Con `--blocks` fuerzas `--vo=tct` aunque estés en kitty. Útil sobre **SSH lento** (cada frame del modo kitty es un PNG completo, y los bloques suelen mandar menos bytes en escenas planas) o si simplemente prefieres la estética blocky.

Caveats:

- En `--video` el stream se sirve a 480p (en lugar de 144p del modo audio). Más bandwidth, más CPU, pero la diferencia visual en kitty graphics protocol es notable.
- Requiere mpv ≥ 0.36 para `--vo=kitty`. El paquete `apt mpv` en Ubuntu 20.04 va por 0.32 — instala el snap (`sudo snap install mpv`) para tener una versión moderna con todos los VOs.
- Si mpv es del snap, claudefm detecta automáticamente las restricciones de filesystem (private /tmp, sin acceso a dotfiles) y enruta los ficheros de runtime a través de `~/snap/mpv/common/claudefm/`.

### Controles (de mpv)

| Tecla | Acción |
|-------|--------|
| `space` | Pausa / reanuda |
| `↑` / `↓` o `+` / `-` | Sube / baja volumen |
| Rueda del ratón | Sube / baja volumen |
| `m` | Mute |
| `q` o `Ctrl+C` | Salir |

> Estos bindings los carga claudefm desde `input.conf` (en `~/.config/claudefm/` tras instalar, o en la raíz del repo en modo dev). El `9`/`0` por defecto de mpv también debería funcionar en versiones modernas, pero algunas builds antiguas lo tienen roto — por eso enviamos los nuestros.

## Configuración

### Cambiar el stream

Tras instalar, edita `~/.config/claudefm/url`:

```bash
$EDITOR ~/.config/claudefm/url
```

El fichero contiene una sola línea con la URL del live de YouTube. Cualquier live vale. Si claudeFM tira el live actual y suben uno nuevo, solo cambias esta línea.

> En modo dev (desde el clone, sin `make install`), el script lee `./.claudefm.url` del propio repo como fallback.

### Personalizar la línea de estado

En el script, la variable `STATUS_MSG` controla qué se muestra. Usa la sintaxis de [property expansion de mpv](https://mpv.io/manual/master/#property-expansion):

```bash
STATUS_MSG='${?pause==yes:[paused]  }♪ ${media-title}  ·  ${playback-time}  ·  vol ${volume}%'
```

Propiedades útiles:

| Propiedad | Qué muestra |
|-----------|-------------|
| `${media-title}` | Título del vídeo |
| `${playback-time}` | Tiempo desde que arrancaste tu sesión |
| `${audio-bitrate}` | Bitrate actual |
| `${volume}` | Volumen (0–100) |
| `${?pause==yes:TEXTO}` | TEXTO solo si está pausado |

## Limitaciones conocidas

- **No muestra la canción que suena**, solo el título del vídeo (el "nombre del show"). YouTube no expone metadata por pista como Icecast/Shoutcast — un live es siempre el mismo título. Para identificar canciones concretas haría falta audio fingerprinting (AcoustID, Shazam) o scraping del chat en directo.
- **JS runtime opcional**: sin `deno` instalado, yt-dlp solo extrae streams HLS muxed (audio+vídeo a 144p). mpv descarta el vídeo con `--no-video`, así que suena bien, pero gastas algo más de ancho de banda. Si lo quieres óptimo, instala `deno` y yt-dlp lo detectará automáticamente:
  ```bash
  curl -fsSL https://deno.land/install.sh | sh
  ```
- **yt-dlp envejece rápido**: YouTube cambia su API interna cada pocas semanas. Si un día deja de funcionar, actualiza yt-dlp y normalmente se arregla solo:
  ```bash
  curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux \
    -o ~/.local/bin/yt-dlp && chmod +x ~/.local/bin/yt-dlp
  ```
