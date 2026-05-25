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

### 1. mpv

```bash
sudo apt install -y mpv
```

### 2. yt-dlp (binario standalone, recomendado)

El binario `yt-dlp_linux` empaqueta su propio Python, así que funciona aunque tu sistema tenga Python 3.8:

```bash
mkdir -p ~/.local/bin
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux \
  -o ~/.local/bin/yt-dlp
chmod +x ~/.local/bin/yt-dlp
```

Asegúrate de que `~/.local/bin` está en tu `PATH` antes que `/usr/bin` (lo normal en Ubuntu).

> Si tu sistema tiene Python 3.10+ ya instalado, también vale `pipx install yt-dlp` o `pip install --user yt-dlp`. El binario `yt-dlp_linux` es la opción más a prueba de balas.

### 3. claudefm

```bash
git clone https://github.com/sanhuaaan/claudefm.git ~/claudefm
chmod +x ~/claudefm/claudefm
# Opcional: añade un alias
echo 'alias claudefm="~/claudefm/claudefm"' >> ~/.bashrc
```

## Uso

```bash
./claudefm
```

Verás:

```
→ resolving stream...
♪ Claude FM 🎵 music for thinking and building 2026-05-25 13:39  ·  00:00:29  ·  vol 100%
```

La línea inferior se actualiza en sitio mientras suena.

### Controles (de mpv)

| Tecla | Acción |
|-------|--------|
| `space` | Pausa / reanuda |
| `9` / `0` | Baja / sube volumen |
| `m` | Mute |
| `q` o `Ctrl+C` | Salir |

## Configuración

### Cambiar el stream

Edita `.claudefm.url`:

```
https://www.youtube.com/watch?v=OTRO_VIDEO_ID
```

Cualquier live de YouTube vale. Cuando YouTube tire el live actual de claudeFM y suban uno nuevo, solo cambias esta línea.

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
