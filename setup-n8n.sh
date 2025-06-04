#!/bin/bash

# Script para configurar N8N en VPS
# Ejecutar como: bash setup-n8n.sh

echo "🚀 Configurando servidor N8N..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    exit 1
fi

# Verificar si Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}❌ Docker Compose no está instalado${NC}"
    exit 1
fi

# Crear directorios necesarios
echo -e "${YELLOW}📁 Creando directorios...${NC}"
sudo mkdir -p /opt/n8n/data
sudo mkdir -p /opt/n8n/backups
sudo mkdir -p /opt/n8n/logs

# Configurar permisos
echo -e "${YELLOW}🔐 Configurando permisos...${NC}"
sudo chown -R 1000:1000 /opt/n8n/
sudo chmod -R 755 /opt/n8n/

# Crear directorio de trabajo
mkdir -p n8n-server
cd n8n-server

# Crear carpetas locales
mkdir -p n8n-backups
mkdir -p n8n-logs

# Obtener IP del VPS
VPS_IP=$(curl -s ifconfig.me)
echo -e "${GREEN}🌐 IP del VPS detectada: $VPS_IP${NC}"

# Crear archivo .env
echo -e "${YELLOW}⚙️ Creando archivo de configuración...${NC}"
cat > .env << EOF
# Configuración N8N
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=Admin123!
WEBHOOK_URL=http://$VPS_IP:5678
VPS_IP=$VPS_IP

# Configuración de la base de datos
DB_TYPE=sqlite
DB_SQLITE_DATABASE=/home/node/.n8n/database.sqlite

# Zona horaria (Perú)
GENERIC_TIMEZONE=America/Lima
N8N_DEFAULT_LOCALE=es
EOF

# Verificar que la red elastika-network existe
echo -e "${YELLOW}🔍 Verificando red elastika-network...${NC}"
if docker network ls | grep -q elastika-network; then
    echo -e "${GREEN}✅ Red elastika-network encontrada${NC}"
else
    echo -e "${RED}❌ Red elastika-network no encontrada${NC}"
    echo -e "${YELLOW}Creando red elastika-network...${NC}"
    docker network create elastika-network
fi

# Configurar firewall (si ufw está activo)
if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
    echo -e "${YELLOW}🔥 Configurando firewall...${NC}"
    sudo ufw allow 5678/tcp
    echo -e "${GREEN}✅ Puerto 5678 abierto en firewall${NC}"
fi

echo -e "${GREEN}✅ Configuración completada${NC}"
echo -e "${YELLOW}📋 Información de acceso:${NC}"
echo -e "   URL: http://$VPS_IP:5678"
echo -e "   Usuario: admin"
echo -e "   Contraseña: Admin123!"
echo -e ""
echo -e "${YELLOW}🚀 Para iniciar N8N, ejecuta:${NC}"
echo -e "   docker-compose -f docker-compose-n8n.yml up -d"
echo -e ""
echo -e "${YELLOW}📊 Para ver logs:${NC}"
echo -e "   docker-compose -f docker-compose-n8n.yml logs -f"
