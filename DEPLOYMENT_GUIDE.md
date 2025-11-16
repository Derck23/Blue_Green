# Portal Deportivo - Blue-Green Deployment

![Deployment Strategy](https://img.shields.io/badge/Deployment-Blue--Green-blue)
![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED?logo=docker)
![Nginx](https://img.shields.io/badge/Nginx-Proxy-009639?logo=nginx)

## 📋 Descripción del Proyecto

Portal Deportivo es una aplicación web desarrollada con React + Vite que implementa una estrategia completa de despliegue **Blue-Green** utilizando Docker, Nginx y scripts automatizados.

El proyecto demuestra:
- ✅ Despliegue Blue-Green completo
- ✅ Contenedores Docker
- ✅ Nginx como Load Balancer/Router
- ✅ Scripts de automatización en Shell
- ✅ Pipeline CI/CD
- ✅ Health checks automatizados
- ✅ Rollback instantáneo

## 🎯 ¿Qué es Blue-Green Deployment?

Blue-Green deployment es una estrategia de despliegue que reduce el tiempo de inactividad y el riesgo al ejecutar dos ambientes de producción idénticos llamados Blue y Green.

### Ventajas:
- **Zero downtime**: Cambio instantáneo entre ambientes
- **Rollback rápido**: Vuelta atrás en segundos
- **Testing en producción**: Prueba la nueva versión antes del switch
- **Reducción de riesgo**: Ambiente anterior siempre disponible

## 🏗️ Arquitectura

```
                    ┌─────────────────┐
                    │  Usuario Web    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │  Nginx Router   │ (Puerto 80)
                    │  Load Balancer  │
                    └────────┬────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
        ┌───────▼────────┐       ┌───────▼────────┐
        │  App Blue      │       │  App Green     │
        │  (Puerto 8081) │       │  (Puerto 8082) │
        │  [ACTIVE]      │       │  [STANDBY]     │
        └────────────────┘       └────────────────┘
```

## 📦 Componentes del Proyecto

### 1. Aplicación (React + Vite)
- **src/App.jsx**: Componente principal con información de deportes
- **src/App.css**: Estilos modernos y responsive
- **index.html**: Página HTML base

### 2. Docker
- **Dockerfile**: Build multi-stage para optimizar la imagen
- **.dockerignore**: Archivos excluidos del contexto Docker
- **docker-compose.yml**: Orquestación de servicios (Blue, Green, Router)

### 3. Nginx
- **nginx.conf**: Configuración para servir la aplicación SPA
- **nginx-router.conf**: Load balancer que controla el tráfico entre Blue/Green

### 4. Scripts de Automatización
- **deploy.sh**: Script principal con menú interactivo
- **switch-environment.sh**: Cambio entre ambientes
- **health-check.sh**: Verificación de estado de servicios
- **deploy-green.sh**: Despliegue de nueva versión en Green

### 5. Pipeline CI/CD
- **.github/workflows/blue-green-deployment.yml**: Pipeline automatizado

## 🚀 Guía de Despliegue

### Prerrequisitos

```bash
# Verificar instalaciones
docker --version
docker-compose --version
git --version
```

### Instalación Rápida

1. **Clonar el repositorio**
```bash
git clone https://github.com/Derck23/Blue_Green.git
cd Blue_Green
```

2. **Dar permisos a los scripts (Linux/Mac)**
```bash
chmod +x *.sh
```

3. **Despliegue inicial**
```bash
# Opción 1: Usando el script interactivo
./deploy.sh
# Selecciona opción 1: "Despliegue inicial completo"

# Opción 2: Usando Docker Compose directamente
docker-compose up -d --build
```

4. **Verificar el despliegue**
```bash
./health-check.sh
```

### Acceso a la Aplicación

Después del despliegue, accede a:

- **Producción (activo)**: http://localhost
- **Ambiente Blue directo**: http://localhost/blue
- **Ambiente Green directo**: http://localhost/green
- **Health Blue**: http://localhost/health/blue
- **Health Green**: http://localhost/health/green
- **Router Health**: http://localhost/router-health

## 🔄 Flujo de Despliegue Blue-Green

### Paso 1: Estado Inicial
```
Blue: ACTIVO en Producción (v1.0)
Green: STANDBY (v1.0)
```

### Paso 2: Desplegar Nueva Versión en Green
```bash
# Modificar código (actualizar versión, features, etc.)
vim src/App.jsx

# Desplegar en Green
./deploy-green.sh
```

```
Blue: ACTIVO en Producción (v1.0)
Green: STANDBY con nueva versión (v2.0)
```

### Paso 3: Probar Green
```bash
# Acceder a Green directamente
curl http://localhost/green
# o visitar en navegador: http://localhost:8082
```

### Paso 4: Switch a Producción
```bash
# Cambiar producción a Green
./switch-environment.sh green
```

```
Blue: STANDBY (v1.0) - Disponible para rollback
Green: ACTIVO en Producción (v2.0)
```

### Paso 5: Rollback (si es necesario)
```bash
# Volver a Blue instantáneamente
./switch-environment.sh blue
```

## 🛠️ Comandos Útiles

### Gestión de Contenedores

```bash
# Ver estado de todos los contenedores
docker-compose ps

# Ver logs de un contenedor específico
docker-compose logs app-blue
docker-compose logs app-green
docker-compose logs nginx-router

# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar un servicio
docker-compose restart app-blue

# Detener todos los servicios
docker-compose down

# Reconstruir imágenes
docker-compose build --no-cache

# Limpiar todo (contenedores, imágenes, volúmenes)
docker-compose down -v --rmi all
```

### Verificación de Estado

```bash
# Health check completo
./health-check.sh

# Verificar ambiente activo
grep "proxy_pass" nginx-router.conf

# Ver recursos de Docker
docker stats

# Inspeccionar un contenedor
docker inspect sports-portal-blue
```

### Testing

```bash
# Test de carga simple
for i in {1..100}; do curl http://localhost/ > /dev/null 2>&1; done

# Test de health
curl -f http://localhost/health/blue && echo "Blue OK"
curl -f http://localhost/health/green && echo "Green OK"
```

## 📁 Estructura de Archivos

```
BlueAndGreen/
├── .github/
│   └── workflows/
│       └── blue-green-deployment.yml   # Pipeline CI/CD
├── public/                              # Assets públicos
├── src/
│   ├── App.jsx                         # Componente principal
│   ├── App.css                         # Estilos
│   ├── main.jsx                        # Entry point
│   └── index.css                       # Estilos globales
├── .dockerignore                       # Exclusiones Docker
├── Dockerfile                          # Imagen de la aplicación
├── docker-compose.yml                  # Orquestación servicios
├── nginx.conf                          # Config Nginx app
├── nginx-router.conf                   # Config Nginx router
├── deploy.sh                           # Script principal
├── switch-environment.sh               # Script de switch
├── health-check.sh                     # Health checks
├── deploy-green.sh                     # Deploy a Green
├── package.json                        # Dependencias Node
├── vite.config.js                      # Config Vite
└── README.md                           # Esta documentación
```

## 🔧 Configuración Avanzada

### Modificar Puertos

Edita `docker-compose.yml`:

```yaml
services:
  app-blue:
    ports:
      - "8081:80"  # Cambiar 8081 por tu puerto
  app-green:
    ports:
      - "8082:80"  # Cambiar 8082 por tu puerto
```

### Configurar Dominio Personalizado

Edita `nginx-router.conf`:

```nginx
server {
    listen 80;
    server_name tudominio.com;  # Cambiar aquí
    # ... resto de configuración
}
```

### Variables de Entorno

Puedes agregar variables de entorno en `docker-compose.yml`:

```yaml
environment:
  - NODE_ENV=production
  - API_URL=https://api.ejemplo.com
```

## 🧪 Testing

### Test Manual

1. **Verificar ambientes corriendo**
```bash
docker-compose ps
```

2. **Probar Blue**
```bash
curl http://localhost:8081/health
```

3. **Probar Green**
```bash
curl http://localhost:8082/health
```

4. **Probar Router**
```bash
curl http://localhost/router-health
```

### Test de Cambio de Ambiente

```bash
# Estado inicial
curl http://localhost | grep "BLUE"

# Cambiar a Green
./switch-environment.sh green

# Verificar cambio
curl http://localhost | grep "GREEN"
```

## 📊 Monitoreo

### Logs en Tiempo Real

```bash
# Ver todos los logs
docker-compose logs -f

# Solo un servicio
docker-compose logs -f app-blue
```

### Métricas de Contenedores

```bash
# Ver uso de recursos
docker stats
```

### Health Checks Automáticos

Los contenedores tienen health checks configurados:

```bash
docker inspect sports-portal-blue | grep -A 10 Health
```

## 🚨 Troubleshooting

### Problema: Puertos en uso

```bash
# Encontrar proceso usando el puerto
netstat -tlnp | grep :80

# Matar proceso
kill -9 <PID>
```

### Problema: Contenedor no inicia

```bash
# Ver logs detallados
docker-compose logs app-blue

# Revisar configuración
docker-compose config
```

### Problema: Nginx no recarga

```bash
# Reiniciar Nginx router
docker-compose restart nginx-router

# Verificar configuración
docker exec sports-portal-router nginx -t
```

### Problema: Health check falla

```bash
# Verificar conectividad
docker exec sports-portal-blue curl http://localhost/health

# Revisar logs de Nginx
docker exec sports-portal-blue cat /var/log/nginx/error.log
```

## 📈 Mejores Prácticas

1. **Siempre hacer backup antes de switch**
2. **Probar Green exhaustivamente antes del switch**
3. **Mantener Blue corriendo como backup**
4. **Monitorear métricas después del switch**
5. **Documentar todos los cambios**
6. **Hacer rollback inmediato si hay problemas**

## 🔐 Seguridad

- Los contenedores corren con usuario no-root
- Health checks para detectar problemas
- Backup automático de configuraciones
- Logs centralizados para auditoría

## 📝 Entregables del Proyecto

### ✅ Checklist de Entrega

- [x] Código fuente de la aplicación
- [x] Dockerfile funcional
- [x] docker-compose.yml con ambientes Blue/Green
- [x] Configuraciones de Nginx (app y router)
- [x] Scripts de Shell para automatización
- [x] Pipeline CI/CD (GitHub Actions)
- [x] Documentación completa (README.md)
- [x] Instrucciones de despliegue
- [x] Arquitectura del sistema

### 📤 Para Entregar

1. **URL del servicio publicado**: http://localhost (o tu dominio)
2. **Repositorio GitHub**: https://github.com/Derck23/Blue_Green
3. **Documentación**: Este README.md
4. **Archivos de configuración**: Todos incluidos en el repositorio

## 👥 Autor

- **Nombre**: [Tu Nombre]
- **Email**: [Tu Email]
- **GitHub**: [@Derck23](https://github.com/Derck23)

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 🙏 Agradecimientos

Proyecto desarrollado como práctica de DevOps para demostrar la implementación de estrategias de despliegue Blue-Green.

---

**¿Necesitas ayuda?** Abre un issue en el repositorio o contacta al autor.

**¿Encontraste un bug?** Las contribuciones son bienvenidas mediante Pull Requests.
