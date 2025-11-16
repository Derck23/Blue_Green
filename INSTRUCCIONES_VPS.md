# 🚀 Despliegue en VPS DigitalOcean - Paso a Paso

## 📋 Información del Proyecto
- **IP VPS**: 104.248.211.70
- **Usuario**: root
- **OS**: Ubuntu 25.10
- **Repositorio**: https://github.com/Derck23/Blue_Green

---

## 🎯 PASOS PARA DESPLEGAR

### 1️⃣ EN TU PC LOCAL (Windows)

```powershell
# 1. Verificar que estás en la carpeta correcta
cd C:\DevOps\BlueAndGreen

# 2. Subir cambios a GitHub
git add .
git commit -m "Proyecto Blue-Green listo para producción"
git push origin main
```

---

### 2️⃣ EN TU VPS (Ya estás conectado por SSH)

Copia y pega estos comandos en tu terminal SSH:

```bash
# 1. Actualizar sistema
apt update && apt upgrade -y

# 2. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl start docker
systemctl enable docker

# 3. Clonar tu repositorio
cd /root
git clone https://github.com/Derck23/Blue_Green.git
cd Blue_Green

# 4. Construir la imagen Docker
docker build -t sports-app:1.0 .

# 5. Dar permisos a los scripts
chmod +x blue-green-deploy.sh deploy-green.sh smoke-tests.sh

# 6. Inicializar Blue-Green (despliega en Blue - puerto 8001)
./blue-green-deploy.sh init

# 7. Verificar que está corriendo
docker ps

# 8. Probar la aplicación
curl http://localhost:8001
```

---

### 3️⃣ CONFIGURAR NGINX COMO PROXY (Opcional pero recomendado)

```bash
# 1. Instalar Nginx
apt install nginx -y

# 2. Crear configuración
cat > /etc/nginx/sites-available/blue-green <<'EOF'
server {
    listen 80;
    server_name 104.248.211.70;

    location / {
        proxy_pass http://localhost:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# 3. Activar configuración
ln -s /etc/nginx/sites-available/blue-green /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

# 4. Configurar firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 8001/tcp
ufw allow 8002/tcp
ufw --force enable
```

---

### 4️⃣ PROBAR EL DESPLIEGUE BLUE-GREEN

```bash
cd /root/Blue_Green

# 1. Ver estado actual
./blue-green-deploy.sh status

# 2. Desplegar en Green (puerto 8002) con smoke tests
./blue-green-deploy.sh green

# 3. Si los tests pasan, cambiar tráfico a Green
# El script te preguntará si quieres cambiar el tráfico

# 4. Verificar que funciona
curl http://localhost:8002
curl http://104.248.211.70

# 5. Ver logs
docker logs app-blue
docker logs app-green
```

---

## 🎓 ENTREGABLES PARA EL PROFESOR

### 1. **URL del Servicio Publicado**
```
http://104.248.211.70
```

### 2. **Repositorio GitHub**
```
https://github.com/Derck23/Blue_Green
```

### 3. **Documento de Resultados** (Ya tienes `RESULTADOS.md`)
- Capturas de pantalla del despliegue
- Evidencia de smoke tests
- Logs de Docker
- Evidencia de cambio Blue → Green

### 4. **Archivos de Configuración** (Ya están en tu repo)
- ✅ `Dockerfile` - Construcción de imagen
- ✅ `nginx.conf` - Configuración del servidor web
- ✅ `blue-green-deploy.sh` - Script principal
- ✅ `deploy-green.sh` - Script con plantilla
- ✅ `smoke-tests.sh` - Pruebas automáticas
- ✅ `.github/workflows/blue-green-deployment.yml` - Pipeline CI/CD

---

## 📸 CAPTURAS DE PANTALLA NECESARIAS

1. **Despliegue inicial (Blue)**
   ```bash
   docker ps
   curl http://104.248.211.70
   ```

2. **Smoke Tests ejecutándose**
   ```bash
   ./smoke-tests.sh 8001
   ```

3. **Despliegue en Green**
   ```bash
   ./blue-green-deploy.sh green
   docker ps
   ```

4. **Cambio de tráfico**
   ```bash
   ./blue-green-deploy.sh status
   curl http://104.248.211.70
   ```

5. **Ambos contenedores corriendo**
   ```bash
   docker ps -a
   docker logs app-blue
   docker logs app-green
   ```

---

## 🔧 COMANDOS ÚTILES

```bash
# Ver contenedores corriendo
docker ps

# Ver logs en tiempo real
docker logs -f app-blue
docker logs -f app-green

# Reiniciar todo
docker stop app-blue app-green
docker rm app-blue app-green
./blue-green-deploy.sh init

# Ver estado del sistema
./blue-green-deploy.sh status

# Ejecutar smoke tests manualmente
./smoke-tests.sh 8001
./smoke-tests.sh 8002

# Ver uso de recursos
docker stats
```

---

## ✅ CHECKLIST FINAL

- [ ] Git push a GitHub completado
- [ ] Docker instalado en VPS
- [ ] Repositorio clonado en VPS
- [ ] Imagen Docker construida
- [ ] Blue desplegado en puerto 8001
- [ ] Nginx configurado (opcional)
- [ ] Smoke tests ejecutados con éxito
- [ ] Green desplegado en puerto 8002
- [ ] Cambio de tráfico Blue → Green realizado
- [ ] Capturas de pantalla tomadas
- [ ] Documento RESULTADOS.md actualizado
- [ ] URL funcionando: http://104.248.211.70

---

## 🆘 TROUBLESHOOTING

### Error: "Cannot connect to Docker daemon"
```bash
systemctl start docker
systemctl status docker
```

### Error: "Port already in use"
```bash
docker ps -a
docker stop app-blue app-green
docker rm app-blue app-green
```

### Error: "Permission denied" en scripts
```bash
chmod +x *.sh
```

### Ver qué proceso usa un puerto
```bash
netstat -tulpn | grep 8001
netstat -tulpn | grep 8002
```

---

## 📝 NOTAS IMPORTANTES

1. **Versión de la App**: Tu app muestra "Versión: Blue 1.0" o "Versión: Green 1.0" según el ambiente
2. **Puertos**: Blue (8001), Green (8002), Nginx (80)
3. **Smoke Tests**: Se ejecutan automáticamente antes de cambiar el tráfico
4. **Rollback Automático**: Si fallan los smoke tests, se hace rollback automático
5. **Zero Downtime**: Siempre hay un contenedor corriendo mientras despliegas

---

¡Éxito con tu entrega! 🚀
