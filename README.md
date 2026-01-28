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
- Git

## Quick Start

### Option 1: Automated Setup

```bash
# Clone the deploy repository
git clone https://github.com/YOUR_USERNAME/coffer-deploy.git
cd coffer-deploy

# Create your environment file
cp .env.example .env

# Edit .env and set your configuration (especially DB_PASSWORD)
nano .env

# Run the setup script
./setup.sh
```

The setup script will:
1. Clone the backend and frontend repositories
4. Build and start all containers

### Option 2: Manual Setup

```bash
# Create a directory for all Coffer repositories
mkdir coffer && cd coffer

# Clone all repositories
git clone https://github.com/YOUR_USERNAME/coffer-deploy.git
git clone https://github.com/YOUR_USERNAME/coffer2.git
git clone https://github.com/YOUR_USERNAME/coffer2-ui.git

# Enter the deploy directory
cd coffer-deploy

# Create your environment file
cp .env.example .env

# Edit .env and set your configuration (especially DB_PASSWORD)
nano .env

# Build and start
docker compose up --build -d
```

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
# Pull latest changes
cd ../coffer2 && git pull
cd ../coffer2-ui && git pull
cd ../coffer-deploy && git pull

# Rebuild and restart
docker compose up --build -d
```

## Troubleshooting

### Port already in use

Change `FRONTEND_PORT` in `.env`:
```env
FRONTEND_PORT=8080
```
