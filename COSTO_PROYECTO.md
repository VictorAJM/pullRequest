# Documento de Costo del Proyecto — PullRequest

**Proyecto:** PullRequest — Transferencia de playlists entre plataformas musicales
**Tipo:** Proyecto universitario
**Equipo:** 3 ingenieros de software junior
**Versión:** 2.0
**Fecha:** 18 de marzo de 2026
**Repositorio:** https://github.com/VictorAJM/pullRequest
**Fuente de cronograma:** `PullRequest - Gantt Diagram.xlsx`

---

## 1. Resumen Ejecutivo

PullRequest es una aplicación móvil desarrollada en Flutter con un backend dedicado, creada como proyecto universitario por un equipo de 3 ingenieros de software junior. La aplicación permite transferir playlists entre Spotify y YouTube Music mediante autenticación OAuth 2.0, un backend con API REST y Server-Sent Events (SSE) para seguimiento en tiempo real, y una librería de traducción de IDs de canciones entre plataformas.

**Alcance del proyecto (según Gantt):**
- **App móvil (Flutter):** 7 pantallas, autenticación OAuth para ambas plataformas, integración con backend, UX de transferencia con SSE
- **Backend:** API REST con endpoints de autenticación, playlists y transferencia; SSE para estado en tiempo real; lógica de retry con backoff exponencial
- **Librería de traducción:** Mapeo de IDs de canciones entre Spotify y YouTube Music
- **QA:** Testing unitario + End-to-end manual (500+ canciones)
- **Infraestructura:** Despliegue en VPS dedicado

**Ruta crítica:** 44 días laborales (~9 semanas)

---

## 2. Equipo de Desarrollo

### Asignación de roles

| Integrante | Rol | Áreas de responsabilidad |
|:----------:|-----|--------------------------|
| **Ingeniero 1** | Frontend / UX | Setup del proyecto, diseño UX, desarrollo de pantallas, integración SSE en UI, pantalla de resumen de transferencia |
| **Ingeniero 2** | Backend | Diseño de API, librería de traducción de IDs, endpoints (auth, playlists, transfer), SSE servidor, backoff/retry |
| **Ingeniero 3** | Auth / Integración / QA / DevOps | Registro OAuth, autenticación Spotify y YTM, integración con backend, testing unitario y E2E, despliegue en VPS |

### Tarifa de referencia

Para la estimación de costos se utiliza la tarifa de mercado para un **ingeniero de software junior en México**:

| Concepto | Valor |
|----------|------:|
| Tarifa por hora | $150 MXN |
| Equivalente USD (~20 MXN/USD) | ~$7.50 USD |
| Jornada laboral | 8 horas/día |

---

## 3. Desglose por Área de Trabajo (según Gantt Diagram)

### 3.1 Project SetUp

| Actividad | Duración | Horas | Responsable |
|-----------|:--------:|:-----:|:-----------:|
| Configure Flutter Dev Env | 1d | 8 | Ing. 1 |
| OAuth Application Registration | 1d | 8 | Ing. 3 |
| Source Control Repository SetUp | 1d | 8 | Ing. 1 |
| **Subtotal** | **3d** | **24** | |

### 3.2 APP (Frontend Flutter)

| Actividad | Duración | Horas | Responsable |
|-----------|:--------:|:-----:|:-----------:|
| UX Design | 1w (5d) | 40 | Ing. 1 |
| Home Screen | 1d | 8 | Ing. 1 |
| Playlist Selection Screen | 1d | 8 | Ing. 1 |
| Playlist Details Screen | 1d | 8 | Ing. 1 |
| Playlist Transfer Screen | 1d | 8 | Ing. 1 |
| Transfer History Screen | 1d | 8 | Ing. 1 |
| Spotify Authentication | 1w (5d) | 40 | Ing. 3 |
| YTM Authentication | 1w (5d) | 40 | Ing. 3 |
| Backend Integration | 3d | 24 | Ing. 3 |
| Transfer status SSE UX integration | 2d | 16 | Ing. 1 |
| Transfer Summary Screen | 3d | 24 | Ing. 1 |
| **Subtotal** | **28d** | **224** | |

### 3.3 Backend

| Actividad | Duración | Horas | Responsable |
|-----------|:--------:|:-----:|:-----------:|
| API Endpoint Design | 1w (5d) | 40 | Ing. 2 |
| Library to translate song IDs YTM <-> Spotify | 1w (5d) | 40 | Ing. 2 |
| Endpoint to receive and store auth tokens | 3d | 24 | Ing. 2 |
| Endpoint to list all user's playlists | 3d | 24 | Ing. 2 |
| Endpoint to transfer a playlist | 4d | 32 | Ing. 2 |
| Transfer status SSE | 4d | 32 | Ing. 2 |
| Exponential Backoff / Retry Logic | 1d | 8 | Ing. 2 |
| **Subtotal** | **25d** | **200** | |

### 3.4 QA

| Actividad | Duración | Horas | Responsable |
|-----------|:--------:|:-----:|:-----------:|
| Song translation Unit Testing | 3d | 24 | Ing. 3 |
| API Endpoint Unit Testing | 3d | 24 | Ing. 3 |
| End to End manual testing (500+ songs) | 1d | 8 | Ing. 3 |
| **Subtotal** | **7d** | **56** | |

### 3.5 Deployment

| Actividad | Duración | Horas | Responsable |
|-----------|:--------:|:-----:|:-----------:|
| Move backend to a dedicated VPS | 4d | 32 | Ing. 3 |
| **Subtotal** | **4d** | **32** | |

---

## 4. Distribución de Carga por Ingeniero

| Integrante | Rol | Horas | % del total | Costo ($150 MXN/h) |
|:----------:|-----|:-----:|:-----------:|--------------------:|
| Ingeniero 1 | Frontend / UX | 136 | 25.4% | $20,400 MXN |
| Ingeniero 2 | Backend | 200 | 37.3% | $30,000 MXN |
| Ingeniero 3 | Auth / Integración / QA / DevOps | 200 | 37.3% | $30,000 MXN |
| **TOTAL** | | **536** | **100%** | **$80,400 MXN** |

### Detalle por ingeniero

**Ingeniero 1 — Frontend / UX (136 h)**
- Configure Flutter Dev Env (8h)
- Source Control Repository SetUp (8h)
- UX Design (40h)
- Home Screen (8h)
- Playlist Selection Screen (8h)
- Playlist Details Screen (8h)
- Playlist Transfer Screen (8h)
- Transfer History Screen (8h)
- Transfer status SSE UX integration (16h)
- Transfer Summary Screen (24h)

**Ingeniero 2 — Backend (200 h)**
- API Endpoint Design (40h)
- Library to translate song IDs YTM <-> Spotify (40h)
- Endpoint to receive and store auth tokens (24h)
- Endpoint to list all user's playlists (24h)
- Endpoint to transfer a playlist (32h)
- Transfer status SSE (32h)
- Exponential Backoff / Retry Logic (8h)

**Ingeniero 3 — Auth / Integración / QA / DevOps (200 h)**
- OAuth Application Registration (8h)
- Spotify Authentication (40h)
- YTM Authentication (40h)
- Backend Integration (24h)
- Song translation Unit Testing (24h)
- API Endpoint Unit Testing (24h)
- End to End manual testing (8h)
- Move backend to a dedicated VPS (32h)

---

## 5. Resumen de Horas por Área

| Área | Días | Horas | % del proyecto | Costo |
|------|:----:|:-----:|:--------------:|------:|
| Project SetUp | 3d | 24 | 4.5% | $3,600 MXN |
| APP (Frontend Flutter) | 28d | 224 | 41.8% | $33,600 MXN |
| Backend | 25d | 200 | 37.3% | $30,000 MXN |
| QA | 7d | 56 | 10.4% | $8,400 MXN |
| Deployment | 4d | 32 | 6.0% | $4,800 MXN |
| **TOTAL** | **67d** | **536** | **100%** | **$80,400 MXN** |

**Ruta crítica:** 44 días laborales (tareas en paralelo entre APP y Backend)
**Duración total del proyecto:** 9 semanas (según Gantt)

---

## 6. Cronograma Gantt (9 semanas)

| Semana | Ing. 1 (Frontend/UX) | Ing. 2 (Backend) | Ing. 3 (Auth/QA/DevOps) |
|:------:|----------------------|------------------|-------------------------|
| **1** | Setup + UX Design | — | OAuth App Registration |
| **2** | UX Design + Pantallas | API Endpoint Design | — |
| **3** | Pantallas (continuación) | API Design + Librería traducción IDs | — |
| **4** | Pantallas finales | Librería traducción IDs + Endpoint auth | Spotify Authentication |
| **5** | — | Endpoint playlists + Endpoint transfer | Spotify Auth + YTM Auth |
| **6** | SSE UX integration | Endpoint transfer + Transfer status SSE | YTM Auth + Backend Integration |
| **7** | SSE UX + Transfer Summary | Transfer status SSE + Backoff/Retry | Backend Integration + Unit Testing |
| **8** | Transfer Summary Screen | — | Unit Testing + E2E manual |
| **9** | — | — | E2E testing + Deployment VPS |

---

## 7. Costos de Desarrollo (Recursos Humanos)

### Costo total del equipo

| Concepto | Valor |
|----------|------:|
| Horas totales del proyecto | 536 h |
| Tarifa por hora (Ing. Junior) | $150 MXN |
| **Costo total de desarrollo** | **$80,400 MXN** |
| Equivalente en USD (~20 MXN/USD) | **~$4,020 USD** |

### Costo por ingeniero

| Integrante | Horas | Costo MXN | Costo USD |
|:----------:|:-----:|----------:|----------:|
| Ingeniero 1 (Frontend/UX) | 136 | $20,400 | ~$1,020 |
| Ingeniero 2 (Backend) | 200 | $30,000 | ~$1,500 |
| Ingeniero 3 (Auth/QA/DevOps) | 200 | $30,000 | ~$1,500 |
| **Total** | **536** | **$80,400** | **~$4,020** |

### Costo por área

| Área | Horas | Costo MXN | Costo USD |
|------|:-----:|----------:|----------:|
| Project SetUp | 24 | $3,600 | ~$180 |
| APP (Frontend) | 224 | $33,600 | ~$1,680 |
| Backend | 200 | $30,000 | ~$1,500 |
| QA | 56 | $8,400 | ~$420 |
| Deployment | 32 | $4,800 | ~$240 |
| **Total** | **536** | **$80,400** | **~$4,020** |

---

## 8. Costos de Infraestructura y Servicios de Terceros

### APIs y Plataformas (costo mensual)

| Servicio | Costo | Notas |
|----------|------:|-------|
| Spotify Web API | $0 | Gratuita (rate limits aplicables) |
| YouTube Data API v3 | $0 | Capa gratuita suficiente para uso académico (10,000 unidades/día) |
| Google Cloud Platform (OAuth) | $0 | Capa gratuita suficiente |

### VPS Dedicado (Backend)

| Proveedor (referencia) | Costo mensual | Specs mínimos |
|------------------------|:------------:|---------------|
| DigitalOcean / Hetzner / Linode | $10 — $25 USD/mes | 2 vCPU, 4GB RAM, 80GB SSD |
| Railway / Render | $5 — $20 USD/mes | Serverless / managed |

### Publicación en Tiendas (opcional para entrega académica)

| Concepto | Costo | Frecuencia | Notas |
|----------|------:|------------|-------|
| Google Play Developer Account | $25 USD | Único | Requerido solo si se publica en Play Store |
| Apple Developer Program | $99 USD | Anual | Requerido solo si se publica en App Store |

### Herramientas de Desarrollo

| Herramienta | Costo | Notas |
|-------------|------:|-------|
| GitHub (repositorio) | $0 | Plan gratuito suficiente |
| GitHub Actions (CI/CD) | $0 | 2,000 min/mes gratis |
| Flutter SDK | $0 | Open source |
| Android Studio / VS Code | $0 | Gratuitos |
| Dominio (DNS para backend) | $10 — $15 USD/año | Opcional si se usa IP directa |

### Resumen de Infraestructura

| Concepto | Costo mínimo | Costo máximo | Periodo |
|----------|:-----------:|:-----------:|:-------:|
| VPS Backend | $60 USD | $150 USD | 6 meses (duración del curso) |
| APIs de terceros | $0 | $0 | Capa gratuita |
| Tiendas (opcional) | $0 | $124 USD | Único/Anual |
| Dominio + SSL | $0 | $15 USD | Anual |
| Herramientas | $0 | $0 | — |
| **Total infraestructura** | **$60 USD** | **$289 USD** | |
| **Equivalente MXN** | **~$1,200 MXN** | **~$5,780 MXN** | |

---

## 9. Resumen de Costo Total del Proyecto

### Costo total (Desarrollo + Infraestructura)

| Concepto | Costo MXN | Costo USD |
|----------|----------:|----------:|
| Desarrollo (536 h x $150 MXN/h) | $80,400 | ~$4,020 |
| Infraestructura (mínimo) | ~$1,200 | $60 |
| Infraestructura (máximo) | ~$5,780 | $289 |
| **Total mínimo** | **$81,600 MXN** | **~$4,080 USD** |
| **Total máximo** | **$86,180 MXN** | **~$4,309 USD** |

### Buffer de contingencia recomendado (15-20%)

| Buffer | Costo adicional MXN | Costo adicional USD |
|:------:|---------------------:|--------------------:|
| 15% | +$12,060 MXN | +$603 USD |
| 20% | +$16,080 MXN | +$804 USD |

### Costo total con contingencia

| Escenario | Costo MXN | Costo USD |
|-----------|----------:|----------:|
| Sin contingencia | $81,600 — $86,180 | ~$4,080 — $4,309 |
| Con 15% contingencia | $93,660 — $98,240 | ~$4,683 — $4,912 |
| Con 20% contingencia | $97,680 — $102,260 | ~$4,884 — $5,113 |

---

## 10. Costos de Mantenimiento Post-Lanzamiento (mensual)

*Aplicable si el proyecto continúa después de la entrega académica.*

| Actividad | Horas/mes | Costo/mes MXN | Costo/mes USD |
|-----------|:---------:|--------------:|--------------:|
| Corrección de bugs (app + backend) | 10 | $1,500 | ~$75 |
| Actualizaciones de dependencias Flutter | 4 | $600 | ~$30 |
| Mantenimiento de backend y VPS | 6 | $900 | ~$45 |
| Cambios en APIs de Spotify/YouTube | 6 | $900 | ~$45 |
| Actualización de librería de traducción de IDs | 4 | $600 | ~$30 |
| Nuevas features menores | 8 | $1,200 | ~$60 |
| **Total mensual** | **38** | **$5,700 MXN** | **~$285 USD** |
| **Total anual** | **456** | **$68,400 MXN** | **~$3,420 USD** |

---

## 11. Riesgos y Contingencias

| Riesgo | Impacto | Mitigación | Costo contingencia |
|--------|---------|------------|-------------------:|
| Cambios en API de Spotify/YouTube | Alto | Monitoreo de changelogs, versionado de endpoints | +$6,000 MXN (+1w) |
| Precisión de traducción de IDs entre plataformas | Alto | Algoritmo de fuzzy matching + fallback manual | +$6,000 MXN (+1w) |
| Cuotas de YouTube API excedidas | Bajo | Capa gratuita suficiente para uso académico | $0 |
| Caída o latencia del VPS | Medio | Health checks + monitoreo + auto-restart | Incluido en mantenimiento |
| Rate limiting de APIs | Bajo | Exponential Backoff / Retry Logic (incluido en Gantt) | Ya incluido |
| Carga académica del equipo | Alto | Planificación con holgura, tareas paralelas entre 3 ingenieros | +2 semanas al cronograma |

---

## 12. Stack Tecnológico

### Frontend (App Flutter)

| Categoría | Tecnología | Versión |
|-----------|-----------|---------|
| Framework | Flutter | SDK ^3.10.8 |
| Estado | provider | ^6.1.2 |
| Navegación | go_router | ^14.6.3 |
| OAuth | flutter_web_auth_2 | ^4.0.1 |
| Storage seguro | flutter_secure_storage | ^9.2.2 |
| HTTP | http | ^1.2.0 |
| Criptografía | crypto | ^3.0.3 |
| UI | cupertino_icons | ^1.0.8 |
| Linting | flutter_lints | ^6.0.0 |

### Backend (por definir en diseño de API)

| Categoría | Opciones sugeridas |
|-----------|-------------------|
| Lenguaje/Framework | Node.js (Express), Python (FastAPI), Go, Dart (Shelf) |
| Base de datos | PostgreSQL, SQLite, Redis (caché) |
| SSE | EventSource nativo del framework |
| Autenticación | JWT / OAuth token relay |
| Hosting | VPS dedicado (según Gantt) |

---

## 13. Métricas del Proyecto Actual (Código Existente)

| Métrica | Valor |
|---------|-------|
| Archivos Dart (lib/) | 41 |
| Líneas de código (lib/) | ~3,872 |
| Pantallas implementadas | 7 de 7 (Transfer Summary pendiente) |
| Servicios/Implementaciones | 8 |
| Repositorios (Abstract) | 3 |
| Providers | 3 |
| Modelos | 6 |
| Widgets reutilizables | 7 |
| Archivos de test | 14 |
| Tests unitarios/widget | ~66 (todos pasando) |
| Integración Spotify OAuth | Completada |
| Integración Spotify Playlists API | Completada |
| Backend | Pendiente |
| Integración YouTube Music | Pendiente |

---

*Documento generado el 18 de marzo de 2026.*
*Proyecto universitario — Equipo de 3 ingenieros de software junior.*
*Basado en el cronograma del archivo `PullRequest - Gantt Diagram.xlsx`.*
*Todas las estimaciones están sujetas a revisión según cambios de alcance.*
