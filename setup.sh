#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Coffer Self-Hosted Setup Script${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Configuration - Update these URLs to your actual repositories
BACKEND_REPO="https://github.com/YOUR_USERNAME/coffer2.git"
FRONTEND_REPO="https://github.com/YOUR_USERNAME/coffer2-ui.git"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check for Docker Compose
if ! docker compose version &> /dev/null; then
    echo -e "${RED}Error: Docker Compose is not available. Please install Docker Compose.${NC}"
    exit 1
fi

echo -e "${YELLOW}Checking repository status...${NC}"

# Clone backend if not exists
if [ ! -d "$PARENT_DIR/coffer2" ]; then
    echo -e "${YELLOW}Cloning backend repository...${NC}"
    git clone "$BACKEND_REPO" "$PARENT_DIR/coffer2"
    echo -e "${GREEN}Backend repository cloned.${NC}"
else
    echo -e "${GREEN}Backend repository already exists.${NC}"
fi

# Clone frontend if not exists
if [ ! -d "$PARENT_DIR/coffer2-ui" ]; then
    echo -e "${YELLOW}Cloning frontend repository...${NC}"
    git clone "$FRONTEND_REPO" "$PARENT_DIR/coffer2-ui"
    echo -e "${GREEN}Frontend repository cloned.${NC}"
else
    echo -e "${GREEN}Frontend repository already exists.${NC}"
fi

# Setup .env file
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp "$SCRIPT_DIR/.env.example" "$SCRIPT_DIR/.env"

    # Generate a random password
    RANDOM_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 24)

    # Replace the placeholder password (works on both Linux and macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/changeme_use_a_strong_password/$RANDOM_PASSWORD/" "$SCRIPT_DIR/.env"
    else
        sed -i "s/changeme_use_a_strong_password/$RANDOM_PASSWORD/" "$SCRIPT_DIR/.env"
    fi

    echo -e "${GREEN}.env file created with a generated database password.${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Please edit .env to configure:${NC}"
    echo -e "  - NUMISTA_API_KEY (optional, for coin catalog lookups)"
    echo -e "  - FRONTEND_PORT (default: 80)"
    echo -e "  - JAVA_OPTS (adjust memory if needed)"
    echo ""
    read -p "Press Enter to open .env in your default editor, or Ctrl+C to edit manually later..."
    ${EDITOR:-nano} "$SCRIPT_DIR/.env"
else
    echo -e "${GREEN}.env file already exists.${NC}"
fi

echo ""
echo -e "${YELLOW}Starting Coffer with Docker Compose...${NC}"
echo ""

cd "$SCRIPT_DIR"

# Build and start containers
docker compose up --build -d

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Coffer is starting up!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Frontend will be available at: ${GREEN}http://localhost:${FRONTEND_PORT:-80}${NC}"
echo -e "API documentation at: ${GREEN}http://localhost:${FRONTEND_PORT:-80}/swagger-ui/${NC}"
echo ""
echo -e "${YELLOW}Useful commands:${NC}"
echo -e "  View logs:        docker compose logs -f"
echo -e "  Stop:             docker compose down"
echo -e "  Restart:          docker compose restart"
echo -e "  Rebuild:          docker compose up --build -d"
echo ""
echo -e "${YELLOW}Checking container status...${NC}"
docker compose ps
