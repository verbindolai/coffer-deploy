<p align="center">
  <img src="https://raw.githubusercontent.com/verbindolai/coffer-ui/refs/heads/master/public/favicon.svg" width="80" alt="Coffer Logo">
</p>

<h1 align="center">Coffer Deploy</h1>

<p align="center">
  <strong>Self-host your coin collection manager with Docker</strong>
</p>

<p align="center">
  <a href="#quick-start">Quick Start</a> •
  <a href="#configuration">Configuration</a> •
  <a href="#architecture">Architecture</a> •
  <a href="#common-commands">Commands</a>
</p>

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)

## Quick Start

```bash
# Clone the deploy repository
git clone https://github.com/verbindolai/coffer-deploy.git
cd coffer-deploy

# Create your environment file
cp .env.example .env

# Edit .env and set your configuration (especially DB_PASSWORD)
nano .env

# Start all services
docker compose up -d
```

Pre-built images are pulled automatically from GitHub Container Registry.

## Configuration

Edit `.env` to customize your deployment:

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_NAME` | `coffer` | PostgreSQL database name |
| `DB_USER` | `coffer` | PostgreSQL username |
| `DB_PASSWORD` | (required) | PostgreSQL password |
| `NUMISTA_API_KEY` | (optional) | API key for [Numista](https://en.numista.com/api/) coin catalog |
| `FRONTEND_PORT` | `80` | Port to access the web interface |
| `JAVA_OPTS` | `-Xmx512m` | JVM memory settings |

## Accessing Coffer

Once running, access:

- **Web Interface:** http://localhost (or your configured port)
- **API Documentation:** http://localhost/swagger-ui/

**Services:**
- **Frontend (nginx):** Serves the Angular UI and proxies `/api/*` requests to backend
- **Backend (Spring Boot):** REST API, business logic, scheduled tasks
- **Database (PostgreSQL):** Persistent data storage

**Volumes:**
- `coffer-db-data`: PostgreSQL data files
- `coffer-images`: Uploaded coin images

## Updating

```bash
docker compose pull
docker compose up -d
```

## Troubleshooting

### Port already in use

Change `FRONTEND_PORT` in `.env`:
```env
FRONTEND_PORT=8080
```
