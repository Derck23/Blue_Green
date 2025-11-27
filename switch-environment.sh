#!/bin/bash
set -e

# Script para hacer switching entre ambientes Blue y Green
TARGET_ENV=$1

if [ -z "$TARGET_ENV" ]; then
    echo "Error: Debes especificar el ambiente (blue o green)"
    echo "Uso: ./switch-environment.sh [blue|green]"
    exit 1
fi

TARGET_ENV=$(echo "$TARGET_ENV" | tr '[:upper:]' '[:lower:]')

if [ "$TARGET_ENV" != "blue" ] && [ "$TARGET_ENV" != "green" ]; then
    echo "Error: Ambiente inválido. Usa 'blue' o 'green'"
    exit 1
fi

echo "================================"
echo "Switching to $TARGET_ENV environment"
echo "================================"

# Detener el proxy actual si existe
docker stop app-proxy 2>/dev/null || true
docker rm app-proxy 2>/dev/null || true

# Determinar el puerto del ambiente objetivo
if [ "$TARGET_ENV" == "blue" ]; then
    TARGET_PORT=8081
    TARGET_CONTAINER="app-blue"
else
    TARGET_PORT=8082
    TARGET_CONTAINER="app-green"
fi

# Verificar que el contenedor objetivo existe y está corriendo
if ! docker ps | grep -q "$TARGET_CONTAINER"; then
    echo "Error: El contenedor $TARGET_CONTAINER no está corriendo"
    exit 1
fi

# Crear configuración de Nginx para el proxy
cat > /tmp/nginx-proxy.conf << EOF
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server localhost:$TARGET_PORT;
    }

    server {
        listen 80;
        
        location / {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
        }
        
        location /health {
            access_log off;
            return 200 "healthy - routing to $TARGET_ENV\n";
            add_header Content-Type text/plain;
        }
    }
}
EOF

# Iniciar el proxy apuntando al ambiente objetivo
echo "Iniciando proxy en puerto 80 apuntando a $TARGET_ENV (puerto $TARGET_PORT)..."
docker run -d \
    --name app-proxy \
    --network host \
    -v /tmp/nginx-proxy.conf:/etc/nginx/nginx.conf:ro \
    --restart always \
    nginx:alpine

sleep 3

# Verificar que el proxy está funcionando
if curl -f http://localhost/ > /dev/null 2>&1; then
    echo "✓ Switch completado exitosamente"
    echo "✓ Producción ahora apunta a: $TARGET_ENV"
    echo ""
    echo "Estado de contenedores:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo "Error: El proxy no responde correctamente"
    docker logs app-proxy
    exit 1
fi
