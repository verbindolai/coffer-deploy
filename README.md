<p align="center">
  <img src="https://raw.githubusercontent.com/YOUR_USERNAME/coffer2-ui/main/public/favicon.svg" width="80" alt="Coffer Logo">
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
- 2GB+ RAM available for containers

## Quick Start

### Option 1: Automated Setup

```bash
# Clone the deploy repository
git clone https://github.com/YOUR_USERNAME/coffer-deploy.git
cd coffer-deploy

# Run the setup script
./setup.sh
```

The setup script will:
1. Clone the backend and frontend repositories
2. Generate a secure database password
3. Create your `.env` configuration file
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

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Network                           │
│                                                             │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Frontend   │    │   Backend   │    │  PostgreSQL │     │
│  │   (nginx)   │───▶│ (Spring Boot)│───▶│    (DB)     │     │
│  │   :80       │    │    :8080    │    │   :5432     │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│        │                   │                  │             │
│        ▼                   ▼                  ▼             │
│   Port 80 exposed    coffer-images      coffer-db-data     │
│   to host            volume             volume              │
└─────────────────────────────────────────────────────────────┘
```

**Services:**
- **Frontend (nginx):** Serves the Angular UI and proxies `/api/*` requests to backend
- **Backend (Spring Boot):** REST API, business logic, scheduled tasks
- **Database (PostgreSQL):** Persistent data storage

**Volumes:**
- `coffer-db-data`: PostgreSQL data files
- `coffer-images`: Uploaded coin images

## Common Commands

```bash
# View logs
docker compose logs -f

# View logs for specific service
docker compose logs -f backend

# Stop all containers
docker compose down

# Stop and remove volumes (WARNING: deletes all data)
docker compose down -v

# Restart a specific service
docker compose restart backend

# Rebuild and restart
docker compose up --build -d

# Check container status
docker compose ps

# Enter a container shell
docker compose exec backend sh
docker compose exec db psql -U coffer -d coffer
```

## Backup & Restore

### Backup Database

```bash
# Create a backup
docker compose exec db pg_dump -U coffer coffer > backup_$(date +%Y%m%d).sql
```

### Restore Database

```bash
# Restore from backup
docker compose exec -T db psql -U coffer coffer < backup_20240101.sql
```

### Backup Coin Images

```bash
# Copy images from volume to local directory
docker cp coffer-backend:/app/data/images ./images_backup
```

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

### Container won't start

Check logs for the specific container:
```bash
docker compose logs backend
```

### Database connection issues

Ensure the database is healthy:
```bash
docker compose ps
docker compose logs db
```

### Out of memory

Increase `JAVA_OPTS` in `.env`:
```env
JAVA_OPTS=-Xmx1g
```

### Port already in use

Change `FRONTEND_PORT` in `.env`:
```env
FRONTEND_PORT=8080
```

### Reset everything

```bash
# Stop and remove all containers, networks, and volumes
docker compose down -v

# Remove built images
docker compose down --rmi all

# Start fresh
./setup.sh
```

## Production Considerations

For production deployments:

1. **Use strong passwords** - The setup script generates one, but verify it's secure
2. **Enable HTTPS** - Put a reverse proxy (Traefik, Caddy, nginx) in front with SSL
3. **Regular backups** - Set up automated database and image backups
4. **Resource limits** - Configure container resource limits in docker-compose.yml
5. **Monitoring** - Add health checks and monitoring (Prometheus, Grafana)

### Example: HTTPS with Traefik

Add a `docker-compose.override.yml`:

```yaml
services:
  frontend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.coffer.rule=Host(`coffer.yourdomain.com`)"
      - "traefik.http.routers.coffer.tls.certresolver=letsencrypt"
```

## License

MIT License - See LICENSE file for details.
