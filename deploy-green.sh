#!/bin/bash
set -e # Salir inmediatamente si un comando falla

# --- Configuración ---
DOCKER_IMAGE="$1"      # La imagen de Docker a desplegar
CONTAINER_PORT="80"    # El puerto INTERNO en el que corre tu app (el EXPOSE del Dockerfile)

NGINX_CONF="/etc/nginx/current_app.conf"
UPSTREAM_BLUE="http://127.0.0.1:8001;"
UPSTREAM_GREEN="http://127.0.0.1:8002;"
# --- Fin Configuración ---

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# 0. Validar entrada
if [ -z "$DOCKER_IMAGE" ]; then
  print_error "Debes pasar el nombre de la imagen de Docker como argumento."
  echo "Ejemplo: ./deploy-green.sh tu-usuario/tu-imagen:latest"
  echo "O usa la imagen local: ./deploy-green.sh sports-portal:latest"
  exit 1
fi

print_header "Blue-Green Deployment Script"

# 1. Identificar entorno actual y próximo
print_message "Identificando entorno actual..."
if [ -f "$NGINX_CONF" ]; then
    CURRENT_UPSTREAM=$(sudo cat $NGINX_CONF 2>/dev/null || cat $NGINX_CONF)
else
    print_message "Archivo $NGINX_CONF no existe. Asumiendo Blue como activo."
    CURRENT_UPSTREAM="set \$upstream $UPSTREAM_BLUE"
fi

if [[ $CURRENT_UPSTREAM == *"$UPSTREAM_BLUE"* ]]; then
  print_message "Entorno actual: BLUE (8001). Desplegando en GREEN (8002)."
  TARGET_COLOR="GREEN"
  TARGET_PORT="8002"
  TARGET_UPSTREAM=$UPSTREAM_GREEN
  OLD_COLOR="BLUE"
  OLD_PORT="8001"
else
  print_message "Entorno actual: GREEN (8002). Desplegando en BLUE (8001)."
  TARGET_COLOR="BLUE"
  TARGET_PORT="8001"
  TARGET_UPSTREAM=$UPSTREAM_BLUE
  OLD_COLOR="GREEN"
  OLD_PORT="8002"
fi

# 2. Hacer "docker pull" de la nueva imagen (o usar local)
print_message "Verificando imagen: $DOCKER_IMAGE..."
if docker pull $DOCKER_IMAGE 2>/dev/null; then
    print_message "Imagen descargada desde registro."
else
    print_message "Usando imagen local (no se pudo descargar, esto es normal si es local)."
fi

# 3. Limpiar contenedor inactivo anterior (si existe)
print_message "Limpiando contenedor inactivo anterior 'app-$TARGET_COLOR'..."
docker stop "app-$TARGET_COLOR" 2>/dev/null || true
docker rm "app-$TARGET_COLOR" 2>/dev/null || true

# 4. Iniciar nuevo contenedor (el nuevo entorno "Green" o "Blue")
print_message "Iniciando nuevo contenedor 'app-$TARGET_COLOR' en puerto $TARGET_PORT..."
docker run -d \
  --name "app-$TARGET_COLOR" \
  -p $TARGET_PORT:$CONTAINER_PORT \
  -e APP_COLOR="$TARGET_COLOR" \
  --restart always \
  $DOCKER_IMAGE

# 5. Esperar y hacer "Smoke Test" (Prueba de Humo)
print_message "Esperando 10s para que el contenedor inicie..."
sleep 10

print_header "Ejecutando Smoke Test"
print_message "Probando http://127.0.0.1:$TARGET_PORT..."

# Usamos curl para el smoke test
if ! curl --fail --silent --show-error "http://127.0.0.1:$TARGET_PORT/" > /dev/null; then
    echo "*****************************************************"
    print_error "¡El Smoke Test falló para 'app-$TARGET_COLOR'!"
    print_error "Despliegue cancelado. Revirtiendo..."
    print_message "Eliminando contenedor fallido: 'app-$TARGET_COLOR'"
    docker stop "app-$TARGET_COLOR" || true
    docker rm "app-$TARGET_COLOR" || true
    echo "*****************************************************"
    exit 1
else
    print_message "✓ Smoke Test exitoso."
fi

# 6. El "Switch": Cambiar Nginx al nuevo contenedor
print_header "Cambiando tráfico de producción"
print_message "Actualizando Nginx para apuntar a 'app-$TARGET_COLOR'..."

# Crear o actualizar el archivo de configuración
echo "set \$upstream $TARGET_UPSTREAM" | sudo tee $NGINX_CONF 2>/dev/null || echo "set \$upstream $TARGET_UPSTREAM" > current_app.conf

print_message "Recargando configuración de Nginx..."
if command -v systemctl &> /dev/null; then
    sudo systemctl reload nginx 2>/dev/null || print_message "Nginx no está usando systemctl (OK para Docker)"
else
    print_message "Systemctl no disponible (OK para entorno Docker)"
fi

echo "*****************************************************"
print_message "¡Despliegue completado! El tráfico ahora va a $TARGET_COLOR."
print_message "URL: http://127.0.0.1:$TARGET_PORT/"
echo "*****************************************************"

# 7. Limpieza del contenedor viejo (ahora inactivo) - OPCIONAL
read -p "¿Desea eliminar el contenedor anterior 'app-$OLD_COLOR'? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    print_message "Deteniendo el contenedor anterior 'app-$OLD_COLOR'..."
    docker stop "app-$OLD_COLOR" || true
    docker rm "app-$OLD_COLOR" || true
    print_message "Contenedor anterior eliminado."
else
    print_message "Contenedor anterior 'app-$OLD_COLOR' mantenido como backup (puerto $OLD_PORT)."
fi

print_header "Script finalizado"
print_message "Ambiente $TARGET_COLOR activo en puerto $TARGET_PORT"
print_message "Ambiente $OLD_COLOR en puerto $OLD_PORT (backup)"
