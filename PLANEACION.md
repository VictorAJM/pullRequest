# Planeación del Proyecto — PullRequest

**Proyecto:** PullRequest — Transferencia de playlists entre plataformas musicales
**Equipo:** 3 ingenieros de software junior
**Duración:** 9 semanas (44 días laborales — ruta crítica)
**Fecha de inicio estimada:** Semana 1
**Fuente:** `PullRequest - Gantt Diagram.xlsx`

---

## 1. Objetivos del Proyecto

Desarrollar una aplicación móvil en Flutter que permita a los usuarios transferir playlists entre Spotify y YouTube Music, con las siguientes capacidades:

- Autenticación OAuth 2.0 contra ambas plataformas
- Visualización y selección de playlists del usuario
- Transferencia de playlists con seguimiento en tiempo real (SSE)
- Traducción de IDs de canciones entre plataformas
- Backend dedicado con API REST desplegado en VPS

---

## 2. Asignación de Roles

| Integrante | Rol | Áreas |
|:----------:|-----|-------|
| **Ingeniero 1** | Frontend / UX | Setup proyecto, diseño UX, pantallas, integración SSE en UI, pantalla de resumen |
| **Ingeniero 2** | Backend | Diseño API, librería traducción IDs, endpoints, SSE servidor, retry logic |
| **Ingeniero 3** | Auth / Integración / QA / DevOps | Registro OAuth, autenticación Spotify y YTM, integración backend, testing, deploy |

---

## 3. Planeación Semana a Semana

### Semana 1 — Setup del Proyecto + Diseño UX

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L** | Configurar entorno Flutter | — | — |
| **Ma** | — | — | Registro de aplicaciones OAuth (Spotify + YTM) |
| **Mi** | Setup repositorio (Git, CI) | — | — |
| **J** | — | — | — |
| **V** | — | — | — |

**Tarea paralela toda la semana (Ing. 1):** Diseño UX completo de las 7 pantallas (wireframes, flujo de navegación, paleta de colores, componentes reutilizables).

**Entregables:**
- Entorno de desarrollo Flutter funcional
- Repositorio configurado con estructura base
- Aplicaciones OAuth registradas en Spotify Developer y Google Cloud Console
- Diseño UX completo (mockups/wireframes de todas las pantallas)

**Dependencias:** El diseño UX debe completarse antes de iniciar la implementación de pantallas en Semana 2.

---

### Semana 2 — Implementación de Pantallas (UI)

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L** | Home Screen | — | — |
| **Ma** | Playlist Selection Screen | — | — |
| **Mi** | Playlist Details Screen | — | — |
| **J** | Playlist Transfer Screen | — | — |
| **V** | Transfer History Screen | — | — |

**Entregables:**
- 5 pantallas implementadas con datos mock
- Navegación funcional con GoRouter
- Widgets reutilizables extraídos (cards, listas, botones)

**Dependencias:** Requiere UX Design terminado (Semana 1). Pantallas usan datos mock hasta integración en Semana 7.

**Nota:** Ingeniero 2 e Ingeniero 3 no tienen tareas asignadas esta semana según el Gantt. Pueden adelantar investigación de APIs o documentación.

---

### Semana 3 — Autenticación Spotify + Diseño API Backend

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L–V** | — | Diseño de API Endpoints | Autenticación Spotify (OAuth 2.0 PKCE) |

**Ing. 2 — Diseño de API (toda la semana):**
- Definir esquema de endpoints REST (OpenAPI/Swagger)
- Diseñar modelos de datos (auth tokens, playlists, tracks, transfers)
- Definir contratos de request/response para cada endpoint
- Diseñar protocolo SSE para seguimiento de transferencia
- Seleccionar stack backend (lenguaje, framework, BD)

**Ing. 3 — Spotify Authentication (toda la semana):**
- Implementar flujo OAuth 2.0 PKCE con Spotify
- Integrar `flutter_web_auth_2` para el flujo en-app
- Manejo de tokens (access, refresh)
- Persistencia segura con `flutter_secure_storage`
- Implementar `SpotifyAuthService` conforme a `AuthRepository`

**Entregables:**
- Documento de diseño de API con todos los endpoints especificados
- Autenticación Spotify funcional en la app (login/logout/refresh)

**Dependencias:** El diseño de API es prerequisito para todas las tareas de backend de Semanas 4–7.

---

### Semana 4 — Autenticación YTM + Librería de Traducción de IDs

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L–V** | — | Librería traducción IDs YTM ↔ Spotify | Autenticación YouTube Music (OAuth 2.0) |

**Ing. 2 — Librería de Traducción de IDs (toda la semana):**
- Investigar APIs de búsqueda de ambas plataformas
- Implementar algoritmo de matching (título + artista + duración)
- Manejar casos edge: covers, remixes, versiones live
- Implementar fuzzy matching como fallback
- Tests unitarios del algoritmo de traducción

**Ing. 3 — YTM Authentication (toda la semana):**
- Implementar flujo OAuth 2.0 con YouTube/Google
- Integrar `flutter_web_auth_2` con scopes de YouTube Music
- Manejo de tokens (access, refresh) para Google APIs
- Implementar `YtMusicAuthService` conforme a `AuthRepository`

**Entregables:**
- Librería de traducción de IDs funcional con tests
- Autenticación YouTube Music funcional en la app

**Dependencias:** La librería de traducción es componente crítico para el endpoint de transferencia (Semana 6).

---

### Semana 5 — Endpoints de Auth y Playlists

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L** | — | Endpoint auth tokens | — |
| **Ma** | — | Endpoint auth tokens | — |
| **Mi** | — | Endpoint auth tokens | — |
| **J** | — | Endpoint list playlists | — |
| **V** | — | Endpoint list playlists | — |

**Ing. 2 — Endpoint Auth Tokens (L–Mi):**
- Endpoint para recibir y almacenar tokens OAuth del cliente
- Validación de tokens
- Almacenamiento seguro en base de datos
- Endpoint de refresh de tokens

**Ing. 2 — Endpoint List Playlists (J–V, continúa S6):**
- Endpoint para listar playlists del usuario
- Integración con Spotify API y YouTube Data API
- Paginación y caché de resultados
- Normalización de datos entre plataformas

**Entregables:**
- Endpoint `/auth/tokens` funcional
- Endpoint `/playlists` en progreso (se completa en Semana 6)

**Dependencias:** Requiere diseño de API (Semana 3). Los endpoints de auth son prerequisito para endpoints de playlists y transfer.

---

### Semana 6 — Endpoint de Playlists (fin) + Endpoint de Transferencia

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L** | — | Endpoint list playlists (fin) | — |
| **Ma** | — | Endpoint transfer playlist | — |
| **Mi** | — | Endpoint transfer playlist | — |
| **J** | — | Endpoint transfer playlist | — |
| **V** | — | Endpoint transfer playlist | — |

**Ing. 2 — Endpoint Transfer Playlist (Ma–V):**
- Endpoint para iniciar transferencia de playlist
- Orquestación: obtener tracks → traducir IDs → crear playlist destino → agregar tracks
- Manejo de errores parciales (tracks no encontrados)
- Registro de resultados por track (éxito/fallo/no encontrado)

**Entregables:**
- Endpoint `/playlists` completado
- Endpoint `/transfer` funcional (sin SSE aún)

**Dependencias:** Requiere librería de traducción de IDs (Semana 4) y endpoint de auth (Semana 5).

---

### Semana 7 — SSE + Integración Backend + Retry Logic + QA Inicio

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L** | Backend Integration | Transfer status SSE | — |
| **Ma** | Backend Integration | Transfer status SSE | — |
| **Mi** | Backend Integration | Transfer status SSE | — |
| **J** | — | Transfer status SSE | Song translation Unit Testing |
| **V** | SSE UX Integration | Backoff / Retry Logic | Song translation Unit Testing |

**Ing. 1 — Backend Integration (L–Mi):**
- Conectar pantallas con API REST real (reemplazar mocks)
- Implementar `SpotifyPlaylistService` / `YtMusicPlaylistService` con llamadas HTTP reales
- Implementar `RealTransferService` conforme a `TransferRepository`
- Pruebas de flujo completo con backend

**Ing. 1 — SSE UX Integration (V, continúa S8):**
- Integrar EventSource en Flutter para recibir eventos SSE
- Actualizar UI de transferencia con progreso en tiempo real
- Manejar reconexión y estados de error

**Ing. 2 — Transfer Status SSE (L–J):**
- Implementar Server-Sent Events para progreso de transferencia
- Emitir eventos por cada track procesado (% completado, track actual, errores)
- Manejar conexiones múltiples y cleanup

**Ing. 2 — Exponential Backoff / Retry Logic (V):**
- Implementar retry con backoff exponencial para llamadas a APIs externas
- Configurar límites de reintentos y timeouts
- Manejar rate limiting de Spotify y YouTube APIs

**Ing. 3 — Song Translation Unit Testing (J–V, continúa S8):**
- Tests unitarios de la librería de traducción de IDs
- Casos: match exacto, fuzzy match, no match, duplicados
- Tests de rendimiento con datasets grandes

**Entregables:**
- App conectada al backend real
- SSE funcionando extremo a extremo
- Retry logic implementado
- Tests de traducción en progreso

**Dependencias:** Semana crítica — requiere que endpoints de backend (Semanas 5-6) estén completos. La integración SSE en UI requiere SSE del servidor funcional.

---

### Semana 8 — SSE UX (fin) + Transfer Summary + Testing + Deploy Inicio

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L** | SSE UX Integration (fin) | — | Song translation Unit Testing (fin) |
| **Ma** | Transfer Summary Screen | — | API Endpoint Unit Testing |
| **Mi** | Transfer Summary Screen | — | API Endpoint Unit Testing |
| **J** | Transfer Summary Screen | — | API Endpoint Unit Testing |
| **V** | — | — | Move backend to VPS |

**Ing. 1 — Transfer Summary Screen (Ma–J):**
- Pantalla de resumen post-transferencia
- Mostrar: tracks transferidos, fallidos, no encontrados
- Opción de reintentar tracks fallidos
- Historial de transferencias

**Ing. 3 — API Endpoint Unit Testing (Ma–J):**
- Tests unitarios de todos los endpoints del backend
- Tests de validación de inputs
- Tests de manejo de errores
- Tests de integración con APIs externas (mocked)

**Ing. 3 — Deploy VPS Inicio (V):**
- Provisionar VPS (DigitalOcean/Hetzner/Linode)
- Configurar sistema operativo y dependencias
- Configurar firewall y seguridad básica

**Entregables:**
- Integración SSE en UI completada
- Pantalla Transfer Summary funcional
- Tests unitarios de traducción completados
- Tests de API completados
- VPS provisionado y configurado

---

### Semana 9 — Deployment + Testing End-to-End

| Día | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:---:|----------------------|-------------------|--------------------------|
| **L** | — | — | Deploy backend en VPS |
| **Ma** | — | — | Deploy backend en VPS |
| **Mi** | — | — | Deploy backend en VPS |
| **J** | — | — | E2E manual testing (500+ songs) |
| **V** | — | — | — (buffer) |

**Ing. 3 — Deploy Backend en VPS (L–Mi):**
- Desplegar aplicación backend en VPS
- Configurar dominio/DNS o IP estática
- Configurar SSL/TLS (Let's Encrypt)
- Configurar proceso de startup (systemd / Docker)
- Monitoreo y logging básico
- Validar conectividad desde la app

**Ing. 3 — End-to-End Manual Testing (J):**
- Test completo de flujo: login → seleccionar playlist → transferir → verificar resultado
- Test con playlist de 500+ canciones
- Verificar precisión de traducción de IDs
- Verificar manejo de errores y reconexión SSE
- Documentar bugs encontrados

**Entregables finales:**
- Backend desplegado y accesible desde la app
- Prueba E2E exitosa con 500+ canciones
- Proyecto listo para entrega

---

## 4. Diagrama de Dependencias

```
Semana 1                    Semana 2              Semana 3
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────────┐
│ Setup Proyecto   │───▶│ Pantallas (UI)   │    │ Spotify Auth          │
│ UX Design        │    │ (5 screens)      │    │ API Endpoint Design   │
└─────────────────┘    └──────────────────┘    └───────────┬───────────┘
                                                           │
Semana 4                    Semana 5                  Semana 6
┌─────────────────┐    ┌──────────────────┐    ┌───────────────────────┐
│ YTM Auth         │    │ Endpoint Auth    │───▶│ Endpoint Playlists    │
│ Lib Traducción   │──┐ │ Endpoint Lists   │    │ Endpoint Transfer     │
└─────────────────┘  │ └──────────────────┘    └───────────┬───────────┘
                     │                                      │
                     │  Semana 7                        Semana 8
                     │ ┌──────────────────┐    ┌───────────────────────┐
                     └▶│ Backend Integr.  │───▶│ Transfer Summary      │
                       │ SSE (server+UI)  │    │ Unit Testing APIs     │
                       │ Retry Logic      │    │ Deploy VPS (inicio)   │
                       │ Unit Test Trad.  │    └───────────┬───────────┘
                       └──────────────────┘                │
                                                      Semana 9
                                               ┌───────────────────────┐
                                               │ Deploy VPS (fin)      │
                                               │ E2E Testing 500+ songs│
                                               └───────────────────────┘
```

---

## 5. Ruta Crítica (44 días)

La ruta crítica define la secuencia más larga de tareas dependientes que determina la duración mínima del proyecto:

```
API Endpoint Design (5d) → Lib Traducción IDs (5d) → Endpoint Auth (3d) →
Endpoint Playlists (3d) → Endpoint Transfer (4d) → Transfer SSE (4d) →
Backoff/Retry (1d) → Song Translation Testing (3d) → API Testing (3d) →
E2E Testing (1d) + Deploy VPS (4d)
```

**Total ruta crítica:** 44 días laborales

**Tareas paralelas fuera de ruta crítica:**
- UX Design + Pantallas (Semanas 1–2) — pueden avanzar independientemente
- Autenticación Spotify y YTM (Semanas 3–4) — paralelas al backend
- Backend Integration y SSE UX (Semana 7) — dependen de SSE servidor

---

## 6. Hitos (Milestones)

| Semana | Hito | Criterio de Aceptación |
|:------:|------|------------------------|
| **1** | Proyecto configurado | Entorno Flutter, repo, OAuth apps registradas, UX diseñado |
| **2** | UI completa (mock) | 5 pantallas navegables con datos ficticios |
| **3** | Auth Spotify + API diseñada | Login Spotify funcional, documento de API aprobado |
| **4** | Auth YTM + Lib traducción | Login YTM funcional, traducción de IDs con tests |
| **5** | Backend core funcional | Endpoints de auth y playlists operativos |
| **6** | Transferencia funcional | Endpoint de transferencia probado end-to-end |
| **7** | Integración completa | App conectada a backend real, SSE funcionando, retry logic |
| **8** | Testing + Deploy inicio | Tests unitarios completos, Transfer Summary, VPS provisionado |
| **9** | **Entrega final** | Backend desplegado, E2E 500+ canciones exitoso |


---

## 7. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|:------------:|:-------:|------------|
| Cambios en API Spotify/YouTube | Media | Alto | Monitorear changelogs, abstraer llamadas tras interfaces |
| Baja precisión traducción IDs | Media | Alto | Fuzzy matching + fallback manual + tests extensivos |
| Rate limiting APIs externas | Baja | Medio | Backoff exponencial (incluido en Gantt S7) |
| Retrasos por carga académica | Alta | Alto | Tareas paralelas, buffer en Semana 9 (viernes libre) |
| Problemas de deploy en VPS | Baja | Medio | Usar Docker para reproducibilidad, documentar proceso |

---

## 8. Criterios de Éxito

1. La app permite login con Spotify y YouTube Music
2. El usuario puede ver sus playlists de ambas plataformas
3. La transferencia de una playlist de 500+ canciones se completa con >90% de precisión
4. El progreso de transferencia se muestra en tiempo real (SSE)
5. El backend está desplegado en un VPS dedicado y accesible
6. Todos los tests unitarios pasan (traducción de IDs + endpoints API)
7. El proyecto se entrega dentro de las 9 semanas planificadas

---
