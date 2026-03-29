# Análisis del Backend y Plan de Integración Frontend

## 1. Resumen Ejecutivo

El backend fue construido con una arquitectura **distinta** a lo que el frontend actual asume. El frontend hace OAuth directamente desde la app (PKCE flow local) y llama a las APIs de Spotify/YouTube directamente. El backend centraliza **todo**: autenticación, almacenamiento de tokens, llamadas a APIs y transferencias. El frontend debe convertirse en un **cliente delgado** que solo muestra UI y se comunica con el backend.

---

## 2. Stack del Backend

| Componente | Tecnología |
|---|---|
| Runtime | **Bun** |
| Framework HTTP | **Elysia** |
| Base de datos | **SQLite** (archivo `mydb.sqlite`) |
| Streaming | **Server-Sent Events** (SSE via `@elysiajs/stream`) |
| Transferencias | **Web Workers** (Bun Workers, procesamiento async) |
| APIs externas | `@spotify/web-api-ts-sdk`, `googleapis`, `ytmusic-api` |
| Validación | **Zod** (respuestas de Spotify) |

Puerto: **3000**

---

## 3. Autenticación de Dispositivo (RSA)

El backend NO usa sessions ni JWT. Usa un esquema de **firma RSA por dispositivo**.

### Flujo:
1. La app genera un **par de llaves RSA** (pública/privada)
2. Envía la llave pública a `POST /register` → recibe un `device_id` (UUID)
3. En cada request posterior, envía 3 headers:
   - `x-device-id` — UUID del dispositivo
   - `x-timestamp` — Unix timestamp en ms
   - `x-signed-timestamp` — Firma RSA (SHA-256) del timestamp, codificada en Base64
4. El backend verifica la firma con la llave pública almacenada
5. Tolerancia de tiempo: **±5 segundos**

### Implicaciones para Flutter:
- Necesita generar keypair RSA al primer lanzamiento
- Almacenar llave privada en `flutter_secure_storage`
- Almacenar `device_id` en `flutter_secure_storage`
- Firmar cada request con la llave privada
- Crear un **HTTP interceptor/middleware** que agregue los 3 headers automáticamente

---

## 4. Endpoints del Backend

### 4.1 `POST /register` (Sin autenticación)

**Request:**
```json
{
  "public_key": "-----BEGIN PUBLIC KEY-----\nMIIBI..."
}
```

**Response:**
```json
{
  "device_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

---

### 4.2 `POST /oauth/register_code`

Intercambia un authorization code por tokens. **El backend hace el intercambio**, no la app.

**Request:**
```json
{
  "platform": "ytm" | "spotify",
  "code": "AQDk3s..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Tokens saved for spotify"
}
```

---

### 4.3 `POST /oauth/register_token`

Alternativa: registra tokens ya obtenidos directamente.

**Request:**
```json
{
  "platform": "ytm" | "spotify",
  "oauth_token": "ya29.xxx",
  "refresh_token": "1//0abc",
  "expires_in": 3600
}
```

---

### 4.4 `GET /oauth/status`

Verifica si el dispositivo tiene tokens válidos para cada plataforma.

**Response:**
```json
{
  "ytm": true,
  "spotify": false
}
```

---

### 4.5 `GET /playlists/list?platform=spotify|ytm`

Lista todas las playlists del usuario en una plataforma.

**Response:**
```json
[
  {
    "platform": "spotify",
    "id": "37i9dQZF1DXcBWIGoYBM5M",
    "title": "Today's Top Hits",
    "itemCount": 50,
    "thumbnail": {
      "url": "https://i.scdn.co/image/...",
      "height": 300,
      "width": 300
    }
  }
]
```

---

### 4.6 `GET /playlists/contents?playlist_id=xxx&platform=spotify|ytm`

Obtiene las canciones de una playlist específica.

**Response:**
```json
{
  "next": false,
  "items": [
    {
      "platform": "spotify",
      "id": "4iV5W9uYEdYUVa79Axb7Rh",
      "title": "Never Gonna Give You Up",
      "artist": "Rick Astley",
      "thumbnail": {
        "url": "https://i.scdn.co/image/...",
        "height": 300,
        "width": 300
      }
    }
  ]
}
```

**Nota:** No incluye `album` ni `durationSeconds` como el modelo `Song` del frontend.

---

### 4.7 `POST /transfer/start`

Inicia una transferencia. El backend detecta la plataforma destino automáticamente (la opuesta).

**Request:**
```json
{
  "platform_from": "spotify" | "ytm",
  "playlist_id": "37i9dQZF1DXcBWIGoYBM5M"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Transfer started"
}
```

**Response (409 — ya hay transfer activa):**
```json
{
  "error": "This device already has an ongoing transfer."
}
```

**Limitaciones importantes:**
- Solo **una playlist a la vez** por dispositivo
- No acepta lista de playlists (el frontend actual sí permite seleccionar múltiples)
- La plataforma destino es **implícita** (la opuesta a `platform_from`)

---

### 4.8 `GET /transfer/updates` (SSE)

Stream de eventos Server-Sent Events con progreso de transferencia.

**Eventos:**
```json
{
  "status": "starting" | "in_progress" | "completed" | "error",
  "totalItems": 50,
  "currentItem": 12,
  "currentSong": "Never Gonna Give You Up",
  "type": "sync"  // Solo en el primer evento (estado actual)
}
```

**Nota:** El stream termina cuando `status` es `completed` o `error`.

---

## 5. Base de Datos (SQLite)

```sql
CREATE TABLE users (
  device_id TEXT PRIMARY KEY,
  public_key TEXT NOT NULL,
  ytm_oauth_token TEXT,
  ytm_refresh_token TEXT,
  ytm_expires_at INTEGER,
  spotify_oauth_token TEXT,
  spotify_refresh_token TEXT,
  spotify_expires_at INTEGER
);
```

El backend maneja TODO el ciclo de vida de tokens: almacenamiento, refresh automático, y verificación de expiración.

---

## 6. Variables de Entorno del Backend

```env
SPOTIFY_CLIENT_ID=xxx
SPOTIFY_CLIENT_SECRET=xxx
SPOTIFY_REDIRECT_URI=xxx
GOOGLE_CLIENT_ID=xxx
GOOGLE_CLIENT_SECRET=xxx
GOOGLE_REDIRECT_URI=xxx
```

---

## 7. Diferencias Críticas: Frontend Actual vs Backend

| Aspecto | Frontend Actual | Backend Espera |
|---|---|---|
| **OAuth** | PKCE local, tokens en el dispositivo | App envía auth code, backend intercambia y guarda tokens |
| **Llamadas a APIs** | Directas a Spotify/YouTube | Todo a través del backend |
| **Autenticación de requests** | Ninguna | RSA signature en cada request |
| **Almacenamiento de tokens** | `flutter_secure_storage` local | SQLite en el servidor |
| **Transfer** | Frontend orquesta, canción por canción | Backend orquesta via Web Worker |
| **Progreso de transfer** | Stream de Dart (local) | SSE desde el servidor |
| **Múltiples playlists** | Sí (batch) | No — una a la vez |
| **Playlist destino** | Explícita (user elige src + dest) | Implícita (la opuesta a src) |
| **Modelo PlaylistItem** | `Song(id, title, artist, album, durationSeconds)` | `PlaylistItem(id, title, artist, thumbnail)` — sin album ni duración |
| **Modelo Playlist** | `Playlist(id, name, description, trackCount, imageUrl, platformId, songs)` | `Playlist(id, title, itemCount, thumbnail, platform)` — sin description |
| **Cancelación** | `cancelTransfer()` en repository | No existe endpoint de cancelación |
| **Historial** | Planeado (TransferHistoryScreen) | No existe |
| **Platform IDs** | `"spotify"`, `"youtube_music"` | `"spotify"`, `"ytm"` |

---

## 8. Plan de Integración — Cambios Necesarios en el Frontend

### 8.1 Capa de Red (NUEVO)

**Crear: `lib/services/api_client.dart`**
- Cliente HTTP base (usa `http` o `dio`)
- URL base configurable (dev: `http://localhost:3000`, prod: URL del server)
- Interceptor que agrega automáticamente los 3 headers RSA a cada request
- Métodos: `get()`, `post()`, `stream()` (para SSE)

**Crear: `lib/services/device_service.dart`**
- Genera par de llaves RSA al primer lanzamiento (usar `pointycastle` o `crypto_keys`)
- Registra dispositivo en `POST /register`
- Persiste `device_id` + llave privada en `flutter_secure_storage`
- Método `signTimestamp()` para el interceptor

---

### 8.2 Modelos — Adaptar al Backend

**`Playlist` model — Cambios:**
- `name` → aceptar `title` del JSON del backend
- `trackCount` → aceptar `itemCount`
- `imageUrl: String` → `thumbnail: Thumbnail` (nuevo objeto con url, height, width)
- `description` — hacerlo nullable (backend no lo envía en `/list`)
- `platformId` — mapear `"ytm"` ↔ `"youtube_music"`

**`Song` model — Cambios:**
- Renombrar a `PlaylistItem` o adaptar `fromJson` para aceptar `PlaylistItem` del backend
- `album` y `durationSeconds` — hacerlos nullable (backend no los provee)
- Agregar `thumbnail`

**Nuevo: `Thumbnail` model**
```dart
class Thumbnail {
  final String url;
  final int height;
  final int width;
}
```

**Nuevo: `TransferUpdate` model** (reemplaza `TransferProgress` para SSE)
```dart
class TransferUpdate {
  final String status; // starting, in_progress, completed, error
  final int? totalItems;
  final int? currentItem;
  final String? currentSong;
  final String? type; // "sync" en primer evento
}
```

---

### 8.3 Platform ID Mapping

El backend usa `"ytm"`, el frontend usa `"youtube_music"`. Opciones:

**Opción A (recomendada):** Cambiar el frontend a usar `"ytm"` internamente.
**Opción B:** Crear mapper en `api_client` que traduzca IDs.

---

### 8.4 Auth Flow — Reescribir

**Eliminar:**
- `SpotifyAuthService` (OAuth PKCE local)
- `flutter_web_auth_2` dependency (o mantener para obtener auth code)

**Nuevo flujo:**
1. App abre browser OAuth (Spotify/Google) — solo para obtener el **authorization code**
2. App envía code a `POST /oauth/register_code`
3. Backend intercambia code por tokens y los almacena
4. App verifica auth status con `GET /oauth/status`

**Crear: `lib/services/backend_auth_service.dart`** (implementa `AuthRepository`)
- `authorize(platform)`:
  1. Lanza OAuth browser (flutter_web_auth_2 o url_launcher) con redirect URI del backend
  2. Captura auth code del callback
  3. `POST /oauth/register_code { platform, code }`
  4. Retorna `AuthorizationResult`
- `isAuthorized(platformId)`: `GET /oauth/status` → lee campo de la plataforma
- `revokeAuth(platformId)`: No soportado por backend — eliminar del UI o implementar en backend

**Nota sobre redirect URI:** Necesitan coordinación. El backend tiene `SPOTIFY_REDIRECT_URI` y `GOOGLE_REDIRECT_URI`. La app necesita usar esas mismas URIs (o el backend necesita aceptar la URI de la app). Esto es un punto de coordinación crítico con el ingeniero del backend.

---

### 8.5 Playlists — Reescribir Services

**Crear: `lib/services/backend_playlist_service.dart`** (implementa `PlaylistRepository`)
- `fetchPlaylists(platformId)`:
  - `GET /playlists/list?platform={mapped_id}`
  - Parsear response a `List<Playlist>`
- `fetchPlaylistDetails(platformId, playlistId)`:
  - `GET /playlists/contents?playlist_id={id}&platform={mapped_id}`
  - Parsear items a `Playlist` con songs poblados

---

### 8.6 Transfer — Reescribir Service + Adaptar Provider

**Crear: `lib/services/backend_transfer_service.dart`** (implementa `TransferRepository`)

**Cambio fundamental:** El backend solo transfiere **una playlist a la vez**. Dos estrategias:

**Opción A — Secuencial en el frontend:**
```dart
Stream<TransferProgress> transferPlaylists(playlists, src, dest) async* {
  for (final playlist in playlists) {
    // POST /transfer/start para cada playlist
    // Escuchar SSE /transfer/updates hasta completed
    // Yield progress events
    // Esperar a que termine antes de iniciar la siguiente
  }
}
```

**Opción B — Simplificar UI a una playlist:**
Eliminar multi-select y transferir una a la vez.

**SSE Client:**
- Usar paquete `eventsource` o `http` con streaming
- Conectar a `GET /transfer/updates`
- Parsear eventos JSON a `TransferUpdate`
- Mapear a `TransferProgress` del frontend

**Cancelación:**
- El backend NO tiene endpoint de cancelación
- Opción: Solo desconectar el SSE stream (la transferencia sigue en el server)
- Opción: Pedir al ingeniero del backend agregar `POST /transfer/cancel`

---

### 8.7 Providers — Cambios

**AuthProvider:**
- Sin cambios en la interfaz pública
- Solo cambia la implementación inyectada en `main.dart`

**PlaylistProvider:**
- Sin cambios — sigue usando `PlaylistRepository`

**TransferProvider:**
- Adaptar `overallProgress` al modelo del backend (`currentItem / totalItems`)
- Manejar que `status` ahora es string (`"starting"`, `"in_progress"`) vs enum
- Considerar qué hacer con cancelación si backend no la soporta

---

### 8.8 Screens — Cambios

**PlatformAuthorizationScreen:**
- Flujo cambia ligeramente (auth code → backend) pero UI similar
- Eliminar cualquier lógica de token local

**PlatformSelectionScreen:**
- Si se mantiene la opción de elegir destino: el backend lo ignora (siempre usa la plataforma opuesta)
- Simplificar a solo elegir plataforma **origen** o validar que origen ≠ destino

**PlaylistSelectionScreen:**
- Si se mantiene multi-select, el frontend debe serializar las transferencias
- Considerar mostrar advertencia de que será secuencial

**PlaylistTransferScreen:**
- Adaptar al modelo SSE del backend
- Progress: `currentItem / totalItems` en vez de `transferredSongs / totalSongs`
- Manejar multi-playlist secuencial si se implementa Opción A

**PlaylistDetailsScreen:**
- Adaptar a que no hay `album` ni `durationSeconds` del backend
- Mostrar `thumbnail` por canción (dato nuevo del backend)

**TransferHistoryScreen:**
- Backend no tiene historial — mantener como pendiente o implementar localmente

---

### 8.9 `main.dart` — Rewiring

```dart
// Antes:
Provider<AuthRepository>(create: (_) => CompositeAuthService({...}))
Provider<PlaylistRepository>(create: (_) => CompositePlaylistService({...}))
Provider<TransferRepository>(create: (_) => MockTransferService())

// Después:
Provider<DeviceService>(create: (_) => DeviceService())  // NUEVO
Provider<ApiClient>(create: (ctx) => ApiClient(ctx.read<DeviceService>()))  // NUEVO
Provider<AuthRepository>(create: (ctx) => BackendAuthService(ctx.read<ApiClient>()))
Provider<PlaylistRepository>(create: (ctx) => BackendPlaylistService(ctx.read<ApiClient>()))
Provider<TransferRepository>(create: (ctx) => BackendTransferService(ctx.read<ApiClient>()))
```

Ya no se necesitan los CompositeServices — todo va al backend.

---

## 9. Dependencias de Flutter a Agregar/Cambiar

| Paquete | Propósito |
|---|---|
| `pointycastle` o `crypto_keys` | Generación de keypair RSA |
| `flutter_secure_storage` | Ya existe — almacenar private key + device_id |
| `flutter_web_auth_2` | Ya existe — obtener auth code (no tokens) |
| `eventsource` o `http` streaming | Cliente SSE para transfer updates |
| `dio` (opcional) | HTTP client con interceptors |

**Eliminar (ya no necesarios):**
- `@spotify/web-api-ts-sdk` equivalentes — ya no se llama a Spotify directo

---

## 10. Preguntas Abiertas para el Ingeniero del Backend

1. **Redirect URIs:** ¿Cuáles son los redirect URIs configurados? ¿Se puede usar `pullrequest://callback` (deep link) o necesita ser una URL web?
2. **Cancelación de transfer:** ¿Se puede agregar `POST /transfer/cancel`?
3. **Múltiples playlists:** ¿Se planea soportar transfer de múltiples playlists en un solo request?
4. **Historial de transfers:** ¿Se planea agregar un endpoint de historial?
5. **Platform ID:** ¿Preferencia por `"ytm"` o `"youtube_music"`?
6. **Desconexión de RSA:** ¿Hay endpoint para revocar/eliminar un dispositivo?
7. **Revocación de OAuth:** ¿Endpoint para desconectar una plataforma?
8. **Error details:** En transfer errors, ¿se incluye mensaje descriptivo?
9. **Tracks no encontrados:** Los tracks marcados "Not Found :(" — ¿se reportan en el SSE o se saltan silenciosamente?
10. **URL del servidor en producción:** ¿Dónde se desplegará?
11. **CORS:** ¿Está configurado para la app Flutter (no aplica si es mobile nativo, pero sí para Flutter web)?
12. **Rate limits:** ¿Hay rate limiting del lado del backend además del 250ms entre inserts de YouTube?

---

## 11. Orden de Implementación Sugerido

### Fase 1 — Fundamentos (Bloqueante)
1. `DeviceService` — generación RSA + registro
2. `ApiClient` — HTTP client con headers RSA
3. Modelos adaptados (`Playlist`, `Song/PlaylistItem`, `Thumbnail`, `TransferUpdate`)
4. Mapeo de platform IDs (`"youtube_music"` ↔ `"ytm"`)

### Fase 2 — Autenticación
5. `BackendAuthService` — flujo OAuth code → backend
6. Adaptar `PlatformAuthorizationScreen`
7. Coordinar redirect URIs con backend

### Fase 3 — Playlists
8. `BackendPlaylistService` — fetch playlists y contenidos
9. Adaptar screens de playlists al modelo sin album/duración
10. Agregar thumbnails por canción en la UI

### Fase 4 — Transferencias
11. `BackendTransferService` — SSE client
12. Lógica de serialización multi-playlist (si se mantiene)
13. Adaptar `PlaylistTransferScreen` al modelo SSE
14. Decidir comportamiento de cancelación

### Fase 5 — Polish
15. Manejo de errores de red (timeout, server down, etc.)
16. Retry logic para requests fallidos
17. Estado offline / reconexión SSE
18. Tests actualizados para nuevos services

---

## 12. Riesgos y Consideraciones

1. **RSA en Flutter:** La generación de llaves RSA y firma puede ser compleja. Probar en iOS y Android.
2. **SSE en Flutter:** No todos los HTTP clients de Dart soportan SSE nativamente. Evaluar `eventsource_client` o implementar con `http` + `StreamedResponse`.
3. **Redirect URI en mobile:** El backend usa redirect URIs web. Para deep links (`pullrequest://callback`), el backend necesita configurar esa URI en las apps de Spotify/Google.
4. **Un-playlist-at-a-time:** Si el usuario selecciona 10 playlists, la UX de esperar secuencialmente puede ser frustrante. Considerar progress bar agregado.
5. **Sin historial en backend:** El historial de transfers se pierde al cerrar la app, a menos que se implemente localmente.
6. **Tracks no encontrados:** El backend inserta tracks con ID `"Not Found :("` — esto podría causar errores en las APIs de destino o playlists con items rotos.
