#!/bin/bash
set -e # Salir inmediatamente si un comando falla

# Script principal de despliegue Blue-Green
# Usa la plantilla estándar con smoke tests integrados

# --- Configuración ---
DOCKER_IMAGE="${1:-sports-portal:latest}"  # Imagen por defecto o la que se pase como argumento
CONTAINER_PORT="80"    # El puerto INTERNO en el que corre tu app (Nginx en el contenedor)

NGINX_CONF="current_app.conf"  # Archivo local de configuración
UPSTREAM_BLUE="http://127.0.0.1:8001;"
UPSTREAM_GREEN="http://127.0.0.1:8002;"
# --- Fin Configuración ---

# Colores
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

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Verificar Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado."
        exit 1
    fi
    print_message "Docker detectado: $(docker --version)"
}

# Construir imagen local
build_image() {
    print_header "Construyendo imagen Docker"
    print_message "Imagen: $DOCKER_IMAGE"
    
    docker build -t $DOCKER_IMAGE . --no-cache
    
    if [ $? -eq 0 ]; then
        print_message "✓ Imagen construida exitosamente"
    else
        print_error "Error al construir la imagen"
        exit 1
    fi
}

# Identificar entorno actual
get_current_environment() {
    if [ -f "$NGINX_CONF" ]; then
        CURRENT_UPSTREAM=$(cat $NGINX_CONF)
        if [[ $CURRENT_UPSTREAM == *"$UPSTREAM_BLUE"* ]]; then
            echo "BLUE"
        else
            echo "GREEN"
        fi
    else
        echo "NONE"
    fi
}

# Desplegar en ambiente específico
deploy_to_environment() {
    local COLOR=$1
    local PORT=$2
    
    print_header "Desplegando en $COLOR"
    
    # Limpiar contenedor anterior
    print_message "Limpiando contenedor 'app-$COLOR'..."
    docker stop "app-$COLOR" 2>/dev/null || true
    docker rm "app-$COLOR" 2>/dev/null || true
    
    # Iniciar nuevo contenedor
    print_message "Iniciando contenedor 'app-$COLOR' en puerto $PORT..."
    docker run -d \
      --name "app-$COLOR" \
      -p $PORT:$CONTAINER_PORT \
      -e APP_COLOR="$COLOR" \
      --restart always \
      $DOCKER_IMAGE
    
    # Esperar inicio
    print_message "Esperando 10s para que el contenedor inicie..."
    sleep 10
    
    # Smoke Test
    print_header "Ejecutando Smoke Test"
    print_message "Probando http://127.0.0.1:$PORT..."
    
    if ! curl --fail --silent --show-error "http://127.0.0.1:$PORT/" > /dev/null; then
        print_error "¡Smoke Test falló para 'app-$COLOR'!"
        print_message "Eliminando contenedor fallido..."
        docker stop "app-$COLOR" || true
        docker rm "app-$COLOR" || true
        return 1
    else
        print_message "✓ Smoke Test exitoso"
        return 0
    fi
}

# Switch de tráfico
switch_traffic() {
    local TARGET_COLOR=$1
    local TARGET_UPSTREAM=""
    
    if [ "$TARGET_COLOR" == "BLUE" ]; then
        TARGET_UPSTREAM=$UPSTREAM_BLUE
    else
        TARGET_UPSTREAM=$UPSTREAM_GREEN
    fi
    
    print_header "Cambiando tráfico a $TARGET_COLOR"
    echo "set \$upstream $TARGET_UPSTREAM" > $NGINX_CONF
    print_message "✓ Configuración actualizada"
}

# Despliegue inicial (ambos ambientes)
initial_deployment() {
    print_header "Despliegue Inicial Completo"
    
    check_docker
    build_image
    
    print_message "Desplegando ambos ambientes..."
    
    # Desplegar Blue
    if deploy_to_environment "BLUE" "8001"; then
        print_message "✓ Blue desplegado exitosamente"
    else
        print_error "Fallo al desplegar Blue"
        exit 1
    fi
    
    # Desplegar Green
    if deploy_to_environment "GREEN" "8002"; then
        print_message "✓ Green desplegado exitosamente"
    else
        print_error "Fallo al desplegar Green"
        exit 1
    fi
    
    # Configurar Blue como activo por defecto
    switch_traffic "BLUE"
    
    print_header "Despliegue Inicial Completado"
    show_status
}

# Despliegue Blue-Green (a ambiente inactivo)
bluegreen_deployment() {
    print_header "Blue-Green Deployment"
    
    check_docker
    
    # Identificar ambiente actual
    CURRENT_ENV=$(get_current_environment)
    
    if [ "$CURRENT_ENV" == "NONE" ]; then
        print_error "No hay ambiente activo. Ejecuta despliegue inicial primero."
        exit 1
    fi
    
    print_message "Ambiente actual: $CURRENT_ENV"
    
    # Determinar ambiente objetivo
    if [ "$CURRENT_ENV" == "BLUE" ]; then
        TARGET_COLOR="GREEN"
        TARGET_PORT="8002"
        OLD_COLOR="BLUE"
    else
        TARGET_COLOR="BLUE"
        TARGET_PORT="8001"
        OLD_COLOR="GREEN"
    fi
    
    print_message "Desplegando nueva versión en: $TARGET_COLOR"
    
    # Construir nueva imagen
    build_image
    
    # Desplegar en ambiente objetivo
    if deploy_to_environment "$TARGET_COLOR" "$TARGET_PORT"; then
        print_message "✓ Nueva versión desplegada en $TARGET_COLOR"
        
        # Preguntar si hacer switch
        echo ""
        read -p "¿Cambiar tráfico a $TARGET_COLOR? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            switch_traffic "$TARGET_COLOR"
            print_message "✓ Tráfico cambiado a $TARGET_COLOR"
            
            # Preguntar si eliminar viejo
            echo ""
            read -p "¿Eliminar contenedor $OLD_COLOR? (s/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Ss]$ ]]; then
                docker stop "app-$OLD_COLOR" || true
                docker rm "app-$OLD_COLOR" || true
                print_message "Contenedor $OLD_COLOR eliminado"
            else
                print_message "Contenedor $OLD_COLOR mantenido como backup"
            fi
        else
            print_message "$TARGET_COLOR está listo pero $OLD_COLOR sigue activo"
            print_message "Para cambiar: ./blue-green-deploy.sh switch"
        fi
    else
        print_error "Fallo al desplegar en $TARGET_COLOR"
        print_message "$OLD_COLOR sigue activo"
        exit 1
    fi
    
    print_header "Despliegue Completado"
    show_status
}

# Cambiar tráfico manualmente
manual_switch() {
    CURRENT_ENV=$(get_current_environment)
    
    if [ "$CURRENT_ENV" == "NONE" ]; then
        print_error "No hay ambiente configurado"
        exit 1
    fi
    
    if [ "$CURRENT_ENV" == "BLUE" ]; then
        TARGET="GREEN"
    else
        TARGET="BLUE"
    fi
    
    print_message "Cambiando de $CURRENT_ENV a $TARGET"
    switch_traffic "$TARGET"
    print_message "✓ Cambio completado"
    show_status
}

# Mostrar estado actual
show_status() {
    print_header "Estado Actual"
    
    CURRENT_ENV=$(get_current_environment)
    
    echo ""
    echo "Ambiente activo: $CURRENT_ENV"
    echo ""
    echo "Contenedores en ejecución:"
    docker ps --filter "name=app-" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "URLs de acceso:"
    echo "  - Blue:  http://127.0.0.1:8001"
    echo "  - Green: http://127.0.0.1:8002"
    echo ""
}

# Detener todo
stop_all() {
    print_header "Deteniendo todos los contenedores"
    docker stop app-BLUE app-GREEN 2>/dev/null || true
    docker rm app-BLUE app-GREEN 2>/dev/null || true
    rm -f $NGINX_CONF
    print_message "✓ Todo detenido"
}

# Menú principal
show_menu() {
    echo ""
    print_header "Blue-Green Deployment Script"
    echo "1) Despliegue inicial (ambos ambientes)"
    echo "2) Despliegue Blue-Green (nueva versión)"
    echo "3) Switch manual de tráfico"
    echo "4) Ver estado actual"
    echo "5) Detener todo"
    echo "6) Salir"
    echo ""
    read -p "Selecciona una opción: " choice
    
    case $choice in
        1)
            initial_deployment
            ;;
        2)
            bluegreen_deployment
            ;;
        3)
            manual_switch
            ;;
        4)
            show_status
            ;;
        5)
            stop_all
            ;;
        6)
            print_message "Saliendo..."
            exit 0
            ;;
        *)
            print_error "Opción inválida"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
    show_menu
}

# Punto de entrada
if [ $# -eq 0 ]; then
    show_menu
else
    case $1 in
        init|initial)
            initial_deployment
            ;;
        deploy)
            bluegreen_deployment
            ;;
        switch)
            manual_switch
            ;;
        status)
            show_status
            ;;
        stop)
            stop_all
            ;;
        *)
            print_error "Comando desconocido: $1"
            echo "Comandos disponibles: init, deploy, switch, status, stop"
            exit 1
            ;;
    esac
fi
