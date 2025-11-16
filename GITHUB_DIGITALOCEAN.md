# 📦 Análisis de Archivos del Proyecto y Guía de Despliegue

## 🗂️ Archivos del Proyecto - Análisis Completo

### ✅ ARCHIVOS ESENCIALES (Debes subirlos a GitHub)

#### 🎨 Aplicación Frontend
```
✅ src/App.jsx                    - Componente principal
✅ src/App.css                    - Estilos
✅ src/main.jsx                   - Entry point React
✅ src/index.css                  - Estilos globales
✅ src/assets/react.svg           - Logo React
✅ public/vite.svg                - Logo Vite
✅ index.html                     - HTML base
```

#### 🐳 Docker y Configuración
```
✅ Dockerfile                     - Build de la imagen
✅ .dockerignore                  - Exclusiones Docker
✅ nginx.conf                     - Config Nginx para app
```

#### 📦 Dependencias Node
```
✅ package.json                   - Dependencias del proyecto
✅ package-lock.json              - Lock de versiones
✅ vite.config.js                 - Configuración Vite
✅ eslint.config.js               - Configuración ESLint
```

#### 🚀 Scripts de Despliegue (Nuevos - Plantilla)
```
✅ blue-green-deploy.sh           - Script principal Blue-Green
✅ deploy-green.sh                - Script con plantilla del profesor
✅ smoke-tests.sh                 - Tests automáticos
```

#### 🔧 Git
```
✅ .gitignore                     - Archivos excluidos
✅ .github/workflows/blue-green-deployment.yml  - Pipeline CI/CD
```

#### 📚 Documentación Principal
```
✅ README.md                      - Presentación del proyecto
✅ NUEVA_PLANTILLA.md             - Guía de la nueva plantilla
✅ DEPLOYMENT_GUIDE.md            - Guía completa
✅ RESULTADOS.md                  - Documento de resultados
```

---

### ⚠️ ARCHIVOS OBSOLETOS/NO NECESARIOS (Puedes eliminar o no subir)

#### ❌ Scripts Antiguos (docker-compose approach)
```
❌ deploy.sh                      - Script viejo con docker-compose
❌ deploy.ps1                     - Script viejo PowerShell
❌ switch-environment.sh          - Ya no se usa (nueva plantilla)
❌ health-check.sh                - Integrado en smoke-tests.sh
❌ quick-start.ps1                - Script viejo PowerShell
❌ docker-compose.yml             - Ya no se usa (usamos docker run)
❌ nginx-router.conf              - Ya no se usa
```

#### 📝 Documentación Duplicada/Vieja
```
❌ README_NEW.md                  - Duplicado de README.md
❌ PROYECTO_COMPLETO.md           - Resumen ya no necesario
❌ INSTRUCCIONES_ENTREGA.md       - Solo para entrega de práctica
❌ WINDOWS_GUIDE.md               - Específico para Windows (opcional)
❌ COMANDOS_RAPIDOS.md            - Para comandos viejos
```

#### 🔧 PowerShell (Solo si usas Windows)
```
⚠️ smoke-tests.ps1                - Solo útil en Windows
```

#### 🗂️ Otros
```
❌ node_modules/                  - NUNCA subir (está en .gitignore)
❌ dist/                          - Build temporal (se genera)
❌ current_app.conf               - Se genera automáticamente
❌ *.backup.*                     - Backups temporales
```

---

## 📋 Estructura Recomendada para GitHub

### Archivos que DEBES subir:

```
Blue_Green/
├── .github/
│   └── workflows/
│       └── blue-green-deployment.yml    ✅ Pipeline CI/CD
├── public/
│   └── vite.svg                         ✅ Assets
├── src/
│   ├── assets/
│   │   └── react.svg                    ✅ Logos
│   ├── App.jsx                          ✅ Componente principal
│   ├── App.css                          ✅ Estilos
│   ├── main.jsx                         ✅ Entry point
│   └── index.css                        ✅ Estilos globales
├── .dockerignore                        ✅ Exclusiones Docker
├── .gitignore                           ✅ Exclusiones Git
├── blue-green-deploy.sh                 ✅ Script principal
├── deploy-green.sh                      ✅ Script plantilla
├── Dockerfile                           ✅ Build imagen
├── eslint.config.js                     ✅ Config ESLint
├── index.html                           ✅ HTML base
├── nginx.conf                           ✅ Config Nginx
├── package.json                         ✅ Dependencias
├── package-lock.json                    ✅ Lock versiones
├── README.md                            ✅ Documentación principal
├── RESULTADOS.md                        ✅ Resultados práctica
├── NUEVA_PLANTILLA.md                   ✅ Guía nueva plantilla
├── DEPLOYMENT_GUIDE.md                  ✅ Guía completa
├── smoke-tests.sh                       ✅ Tests automáticos
└── vite.config.js                       ✅ Config Vite
```

**Total aproximado: 25 archivos** (sin contar node_modules ni dist)

---

## 🗑️ Archivos a Eliminar Antes de Subir

Ejecuta estos comandos para limpiar:

```bash
# Eliminar scripts antiguos
rm -f deploy.sh deploy.ps1 switch-environment.sh health-check.sh quick-start.ps1
rm -f docker-compose.yml nginx-router.conf

# Eliminar documentación duplicada
rm -f README_NEW.md PROYECTO_COMPLETO.md INSTRUCCIONES_ENTREGA.md
rm -f WINDOWS_GUIDE.md COMANDOS_RAPIDOS.md

# Eliminar archivos temporales
rm -f current_app.conf *.backup.*
rm -rf dist/

# NUNCA elimines node_modules manualmente, está en .gitignore
```

---

## 🚀 Guía para Subir a GitHub

### Paso 1: Limpiar Archivos Obsoletos

```bash
cd c:\DevOps\BlueAndGreen

# En PowerShell (Windows)
Remove-Item deploy.sh, deploy.ps1, switch-environment.sh, health-check.sh, quick-start.ps1
Remove-Item docker-compose.yml, nginx-router.conf
Remove-Item README_NEW.md, PROYECTO_COMPLETO.md, INSTRUCCIONES_ENTREGA.md
Remove-Item WINDOWS_GUIDE.md, COMANDOS_RAPIDOS.md
```

### Paso 2: Verificar .gitignore

Asegúrate de que `.gitignore` contenga:

```
# Dependencies
node_modules/

# Build output
dist/
build/

# Environment
.env
.env.local

# Temporales
current_app.conf
*.backup.*
*.log

# OS
.DS_Store
Thumbs.db
```

### Paso 3: Commit y Push

```bash
# Ver estado
git status

# Agregar archivos
git add .

# Commit
git commit -m "Blue-Green Deployment con smoke tests integrados"

# Push a GitHub
git push origin main
```

### Paso 4: Verificar en GitHub

Visita: https://github.com/Derck23/Blue_Green

Deberías ver:
- ✅ Código fuente
- ✅ Scripts de despliegue
- ✅ Dockerfile
- ✅ Documentación
- ❌ NO node_modules
- ❌ NO archivos temporales

---

## 🌊 Guía para Desplegar en DigitalOcean VPS

### Requisitos Previos

1. **VPS de DigitalOcean**
   - Ubuntu 22.04 LTS (recomendado)
   - Mínimo: 1 GB RAM, 1 vCPU
   - Recomendado: 2 GB RAM, 2 vCPU

2. **Acceso SSH**
   - Clave SSH configurada
   - Usuario con privilegios sudo

### Paso 1: Conectar a tu VPS

```bash
# Desde tu computadora local
ssh root@tu-ip-del-vps

# O si tienes usuario específico
ssh usuario@tu-ip-del-vps
```

### Paso 2: Actualizar Sistema

```bash
# Actualizar paquetes
sudo apt update && sudo apt upgrade -y

# Instalar utilidades básicas
sudo apt install -y curl wget git
```

### Paso 3: Instalar Docker

```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Agregar usuario al grupo docker (opcional)
sudo usermod -aG docker $USER

# Iniciar Docker
sudo systemctl start docker
sudo systemctl enable docker

# Verificar instalación
docker --version
docker ps
```

### Paso 4: Clonar Repositorio

```bash
# Ir al directorio home
cd ~

# Clonar tu repositorio
git clone https://github.com/Derck23/Blue_Green.git

# Entrar al directorio
cd Blue_Green
```

### Paso 5: Dar Permisos a Scripts

```bash
# Dar permisos de ejecución
chmod +x blue-green-deploy.sh
chmod +x deploy-green.sh
chmod +x smoke-tests.sh
```

### Paso 6: Construir Imagen

```bash
# Construir imagen Docker
docker build -t sports-portal:latest .

# Verificar que se creó
docker images | grep sports-portal
```

### Paso 7: Despliegue Inicial

```bash
# Opción 1: Despliegue completo automático
./blue-green-deploy.sh init

# O paso a paso:
# Desplegar Blue
docker run -d \
  --name app-BLUE \
  -p 8001:80 \
  -e APP_COLOR="BLUE" \
  --restart always \
  sports-portal:latest

# Desplegar Green
docker run -d \
  --name app-GREEN \
  -p 8002:80 \
  -e APP_COLOR="GREEN" \
  --restart always \
  sports-portal:latest

# Esperar 10 segundos
sleep 10

# Verificar
docker ps
curl http://127.0.0.1:8001/
curl http://127.0.0.1:8002/
```

### Paso 8: Configurar Nginx como Proxy Reverso (Opcional pero Recomendado)

```bash
# Instalar Nginx
sudo apt install -y nginx

# Crear configuración
sudo nano /etc/nginx/sites-available/sports-portal
```

**Agregar esta configuración:**

```nginx
upstream blue_backend {
    server 127.0.0.1:8001;
}

upstream green_backend {
    server 127.0.0.1:8002;
}

server {
    listen 80;
    server_name tu-dominio.com;  # O tu IP pública

    # Archivo que define el upstream activo
    include /etc/nginx/current_app.conf;

    location / {
        proxy_pass $upstream;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /blue {
        rewrite ^/blue/(.*) /$1 break;
        proxy_pass http://blue_backend;
    }

    location /green {
        rewrite ^/green/(.*) /$1 break;
        proxy_pass http://green_backend;
    }
}
```

```bash
# Crear archivo de upstream activo
echo "set \$upstream http://127.0.0.1:8001;" | sudo tee /etc/nginx/current_app.conf

# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/sports-portal /etc/nginx/sites-enabled/

# Eliminar default
sudo rm /etc/nginx/sites-enabled/default

# Probar configuración
sudo nginx -t

# Recargar Nginx
sudo systemctl reload nginx
```

### Paso 9: Configurar Firewall

```bash
# Permitir puertos necesarios
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS (para futuro)

# Habilitar firewall
sudo ufw enable

# Ver estado
sudo ufw status
```

### Paso 10: Verificar Despliegue

```bash
# Desde el VPS
curl http://localhost/
curl http://127.0.0.1:8001/
curl http://127.0.0.1:8002/

# Desde tu computadora local
curl http://tu-ip-publica/
```

**Abre en tu navegador:**
- http://tu-ip-publica (Nginx proxy)
- http://tu-ip-publica:8001 (Blue directo)
- http://tu-ip-publica:8002 (Green directo)

---

## 🔄 Actualizar Aplicación en DigitalOcean

### Método 1: Desde el VPS (Recomendado)

```bash
# SSH al VPS
ssh usuario@tu-ip-del-vps

# Ir al directorio
cd ~/Blue_Green

# Pull cambios desde GitHub
git pull origin main

# Reconstruir imagen
docker build -t sports-portal:latest .

# Desplegar nueva versión
./blue-green-deploy.sh deploy

# Responder preguntas:
# ¿Cambiar tráfico? s
# ¿Eliminar viejo? n (mantener como backup)
```

### Método 2: Build Local y Push a Docker Hub

```bash
# En tu computadora local
docker build -t tu-usuario/sports-portal:v1.1 .
docker push tu-usuario/sports-portal:v1.1

# En el VPS
ssh usuario@tu-ip-del-vps
cd ~/Blue_Green
./deploy-green.sh tu-usuario/sports-portal:v1.1
```

---

## 🎯 Comandos Útiles en DigitalOcean

### Ver Estado

```bash
# Ver contenedores
docker ps

# Ver logs
docker logs app-BLUE
docker logs app-GREEN

# Ver estado de Nginx
sudo systemctl status nginx

# Ver recursos del sistema
htop  # Instalar con: sudo apt install htop
```

### Smoke Tests

```bash
# Ejecutar smoke tests
./smoke-tests.sh

# O manualmente
curl -f http://127.0.0.1:8001/ && echo "Blue OK"
curl -f http://127.0.0.1:8002/ && echo "Green OK"
```

### Cambiar Ambiente Activo

```bash
# Opción 1: Con script
./blue-green-deploy.sh switch

# Opción 2: Manual
echo "set \$upstream http://127.0.0.1:8002;" | sudo tee /etc/nginx/current_app.conf
sudo systemctl reload nginx
```

### Detener/Reiniciar

```bash
# Reiniciar contenedor
docker restart app-BLUE

# Detener todo
docker stop app-BLUE app-GREEN

# Iniciar todo
docker start app-BLUE app-GREEN
```

### Limpiar Recursos

```bash
# Eliminar contenedores parados
docker container prune

# Eliminar imágenes sin usar
docker image prune

# Limpiar todo
docker system prune -a
```

---

## 🔒 Seguridad Adicional

### 1. Configurar SSL/TLS con Let's Encrypt (Recomendado)

```bash
# Instalar Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtener certificado
sudo certbot --nginx -d tu-dominio.com

# Renovación automática (ya configurada)
sudo certbot renew --dry-run
```

### 2. Configurar Auto-updates

```bash
# Instalar unattended-upgrades
sudo apt install -y unattended-upgrades

# Habilitar
sudo dpkg-reconfigure -plow unattended-upgrades
```

### 3. Monitoreo Básico

```bash
# Instalar netdata (dashboard de monitoreo)
bash <(curl -Ss https://my-netdata.io/kickstart.sh)

# Acceder en: http://tu-ip:19999
```

---

## 📊 Resumen de URLs

Después del despliegue en DigitalOcean:

| Servicio | URL |
|----------|-----|
| **Producción (Nginx)** | http://tu-ip-publica |
| **Blue directo** | http://tu-ip-publica:8001 |
| **Green directo** | http://tu-ip-publica:8002 |
| **Con dominio** | http://tu-dominio.com |
| **Con SSL** | https://tu-dominio.com |

---

## ✅ Checklist Final

### Para GitHub:
- [ ] Eliminar archivos obsoletos
- [ ] Verificar .gitignore
- [ ] Commit y push
- [ ] Verificar en GitHub que todo está correcto
- [ ] README.md actualizado con URL del VPS

### Para DigitalOcean:
- [ ] VPS creado y accesible por SSH
- [ ] Docker instalado
- [ ] Repositorio clonado
- [ ] Imagen construida
- [ ] Ambientes Blue y Green corriendo
- [ ] Nginx configurado (opcional)
- [ ] Firewall configurado
- [ ] Smoke tests pasan
- [ ] Aplicación accesible desde navegador
- [ ] SSL configurado (opcional)

---

## 🆘 Solución de Problemas Comunes

### Problema: Puerto 80 ocupado en VPS

```bash
# Ver qué usa el puerto
sudo lsof -i :80

# Detener servicio
sudo systemctl stop apache2  # Si es Apache
sudo systemctl stop nginx    # Si es Nginx viejo

# O usar puerto diferente
# Editar configuración de Nginx para usar puerto 8080
```

### Problema: Contenedor no inicia

```bash
# Ver logs detallados
docker logs app-BLUE --tail 100

# Ver estado
docker inspect app-BLUE

# Reiniciar
docker restart app-BLUE
```

### Problema: No puedo acceder desde navegador

```bash
# Verificar firewall
sudo ufw status

# Verificar que contenedor escucha
netstat -tulpn | grep :8001

# Verificar Nginx
sudo nginx -t
sudo systemctl status nginx
```

---

¡Listo! Con esta guía tienes todo lo necesario para subir tu proyecto a GitHub y desplegarlo en DigitalOcean. 🚀
