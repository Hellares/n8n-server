#!/bin/bash

# Script para gestionar N8N
# Uso: bash manage-n8n.sh [start|stop|restart|status|logs|backup]

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

COMPOSE_FILE="docker-compose-n8n.yml"

case "$1" in
    start)
        echo -e "${GREEN}🚀 Iniciando N8N...${NC}"
        docker-compose -f $COMPOSE_FILE up -d
        echo -e "${GREEN}✅ N8N iniciado${NC}"
        ;;
        
    stop)
        echo -e "${YELLOW}⏹️ Deteniendo N8N...${NC}"
        docker-compose -f $COMPOSE_FILE down
        echo -e "${GREEN}✅ N8N detenido${NC}"
        ;;
        
    restart)
        echo -e "${YELLOW}🔄 Reiniciando N8N...${NC}"
        docker-compose -f $COMPOSE_FILE down
        docker-compose -f $COMPOSE_FILE up -d
        echo -e "${GREEN}✅ N8N reiniciado${NC}"
        ;;
        
    status)
        echo -e "${YELLOW}📊 Estado de N8N:${NC}"
        docker-compose -f $COMPOSE_FILE ps
        ;;
        
    logs)
        echo -e "${YELLOW}📋 Logs de N8N:${NC}"
        docker-compose -f $COMPOSE_FILE logs -f
        ;;
        
    backup)
        echo -e "${YELLOW}💾 Creando backup...${NC}"
        BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
        docker exec n8n-server tar -czf /backups/n8n-backup-$BACKUP_DATE.tar.gz /home/node/.n8n
        echo -e "${GREEN}✅ Backup creado: n8n-backup-$BACKUP_DATE.tar.gz${NC}"
        ;;
        
    update)
        echo -e "${YELLOW}🔄 Actualizando N8N...${NC}"
        docker-compose -f $COMPOSE_FILE pull
        docker-compose -f $COMPOSE_FILE down
        docker-compose -f $COMPOSE_FILE up -d
        echo -e "${GREEN}✅ N8N actualizado${NC}"
        ;;
        
    *)
        echo -e "${RED}❌ Uso: $0 {start|stop|restart|status|logs|backup|update}${NC}"
        echo -e "${YELLOW}Comandos disponibles:${NC}"
        echo -e "  start   - Iniciar N8N"
        echo -e "  stop    - Detener N8N"
        echo -e "  restart - Reiniciar N8N"
        echo -e "  status  - Ver estado"
        echo -e "  logs    - Ver logs"
        echo -e "  backup  - Crear backup"
        echo -e "  update  - Actualizar N8N"
        exit 1
        ;;
esac
