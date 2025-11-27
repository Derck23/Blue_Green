# 🔐 Configurar GitHub Actions con tu VPS Digital Ocean

## 📋 Secretos que Necesitas Configurar

Para que el workflow se conecte a tu VPS, necesitas configurar estos **Secrets** en GitHub:

### 1️⃣ Ir a Configuración de Secretos

1. Ve a tu repositorio: `https://github.com/Derck23/Blue_Green`
2. Click en **Settings** (⚙️)
3. En el menú izquierdo: **Secrets and variables** → **Actions**
4. Click en **New repository secret**

---

### 2️⃣ Secretos a Crear

#### Secret 1: `VPS_SSH_KEY` (Clave SSH Privada)

**Valor**: Tu clave SSH privada para conectarte al VPS

##### Cómo obtener la clave SSH:

**Opción A: Si ya tienes clave SSH**
```powershell
# En PowerShell (Windows)
Get-Content ~\.ssh\id_rsa
```

**Opción B: Crear nueva clave SSH**
```powershell
# En PowerShell
ssh-keygen -t rsa -b 4096 -C "github-actions@blue-green"
# Presiona Enter en todas las preguntas
# Luego copia la clave:
Get-Content ~\.ssh\id_rsa
```

**Copiar la clave completa incluyendo:**
```
-----BEGIN OPENSSH PRIVATE KEY-----
... (todo el contenido) ...
-----END OPENSSH PRIVATE KEY-----
```

##### Agregar clave pública al VPS:

```bash
# Desde tu PC, ejecuta:
ssh-copy-id root@tu-ip-vps

# O manualmente en el VPS:
ssh root@tu-ip-vps
mkdir -p ~/.ssh
nano ~/.ssh/authorized_keys
# Pega tu clave pública (contenido de id_rsa.pub)
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

##### En GitHub:
- **Name**: `VPS_SSH_KEY`
- **Value**: (Pega toda la clave privada)

---

#### Secret 2: `VPS_HOST` (IP del VPS)

**Valor**: La IP de tu VPS de Digital Ocean

##### En GitHub:
- **Name**: `VPS_HOST`
- **Value**: `104.248.211.70` (o tu IP actual)

---

#### Secret 3: `VPS_USER` (Usuario SSH)

**Valor**: Usuario con el que te conectas al VPS

##### En GitHub:
- **Name**: `VPS_USER`
- **Value**: `root` (o el usuario que uses)

---

#### Secret 4: `VPS_PROJECT_PATH` (Ruta del proyecto)

**Valor**: Ruta donde está clonado el repositorio en el VPS

##### En GitHub:
- **Name**: `VPS_PROJECT_PATH`
- **Value**: `/root/Blue_Green` (o donde lo clonaste)

---

### 3️⃣ Variable de Estado (No es Secret)

También necesitas una **Variable** (no secret):

1. En la misma página, ve a la pestaña **Variables**
2. Click en **New repository variable**

- **Name**: `ACTIVE_ENVIRONMENT`
- **Value**: `blue` (valor inicial)

---

## ✅ Verificar Configuración

Después de configurar todo, deberías tener:

### Secrets (🔒):
- ✅ `VPS_SSH_KEY` → Tu clave SSH privada
- ✅ `VPS_HOST` → IP del VPS (ej: 104.248.211.70)
- ✅ `VPS_USER` → Usuario SSH (ej: root)
- ✅ `VPS_PROJECT_PATH` → Ruta del proyecto (ej: /root/Blue_Green)

### Variables (📊):
- ✅ `ACTIVE_ENVIRONMENT` → Estado actual (ej: blue)

---

## 🧪 Probar Conexión SSH

Antes de hacer push, prueba la conexión SSH desde tu PC:

```powershell
# Probar conexión
ssh root@104.248.211.70

# Una vez conectado, verifica que existe el proyecto
cd /root/Blue_Green
ls -la
```

Si esto funciona, GitHub Actions también funcionará.

---

## 🚀 Preparar el VPS

### 1. Clonar el repositorio en el VPS

```bash
# Conectar por SSH
ssh root@104.248.211.70

# Clonar repositorio
cd /root
git clone https://github.com/Derck23/Blue_Green.git
cd Blue_Green

# Dar permisos a scripts
chmod +x *.sh

# Instalar Docker si no está instalado
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
systemctl start docker
systemctl enable docker

# Instalar Nginx
apt update
apt install -y nginx

# Configurar Nginx básico
cat > /etc/nginx/sites-available/blue-green << 'EOF'
server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://localhost:8081;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
    
    location /health {
        return 200 "Active: blue\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Activar configuración
ln -sf /etc/nginx/sites-available/blue-green /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl restart nginx

# Configurar firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 8081/tcp
ufw allow 8082/tcp
ufw --force enable

echo "✅ VPS preparado"
```

### 2. Deployment inicial manual

```bash
# Construir imagen
docker build -t sports-portal:latest .

# Desplegar Blue (inicial)
docker run -d \
  --name app-blue \
  -p 8081:80 \
  -e APP_ENV=blue \
  --restart unless-stopped \
  sports-portal:latest

# Verificar
docker ps
curl http://localhost:8081
curl http://localhost/

echo "✅ Deployment inicial completado"
```

---

## 🔄 Flujo Completo

### Paso 1: Configurar Secretos en GitHub
- Crear los 4 secrets
- Crear la variable ACTIVE_ENVIRONMENT

### Paso 2: Preparar VPS
- Clonar repositorio
- Instalar Docker y Nginx
- Deployment inicial de Blue

### Paso 3: Push a GitHub
```bash
# En tu PC
cd C:\DevOps\BlueAndGreen
git add .
git commit -m "Configurar deployment automático a VPS"
git push origin main
```

### Paso 4: Ver el Workflow
- Ve a GitHub Actions
- Verás el workflow ejecutándose
- Se conectará por SSH a tu VPS
- Desplegará en Green
- Esperará tu confirmación para el switch

### Paso 5: Ejecutar Switch
- En Actions, click en "Run workflow"
- Selecciona action: "switch"
- El workflow cambiará producción de Blue a Green

---

## 🎓 Para Mostrar al Profesor

Con esta configuración, puedes mostrar:

1. **Código en GitHub** → Cambias código y haces push
2. **Pipeline ejecutándose** → Se ve en Actions
3. **Logs del deployment** → Muestra conexión SSH y Docker en VPS
4. **Contenedores en VPS** → Se ven los 2 ambientes corriendo
5. **Switching visual** → Logs muestran el cambio de Blue a Green
6. **Aplicación funcionando** → http://104.248.211.70

---

## 🐛 Troubleshooting

### Error: "Permission denied (publickey)"

```bash
# Verificar que la clave pública está en el VPS
ssh root@104.248.211.70
cat ~/.ssh/authorized_keys

# Debe contener tu clave pública (id_rsa.pub)
```

### Error: "Host key verification failed"

El workflow ya incluye `-o StrictHostKeyChecking=no`, debería funcionar.

### Error: "Repository not found"

```bash
# En el VPS, verificar que existe
ssh root@104.248.211.70
ls -la /root/Blue_Green
```

### Probar Secret manualmente

```powershell
# En tu PC, crear archivo temporal con el secret
$env:VPS_SSH_KEY | Set-Content test-key.pem
ssh -i test-key.pem root@104.248.211.70 "docker ps"
```

---

## 📸 Capturas para el Profesor

1. **Secrets configurados** → Settings > Secrets (ocultar valores)
2. **Workflow ejecutándose** → Actions con jobs verdes
3. **Logs de SSH** → Mostrando conexión al VPS
4. **Logs de Docker** → Mostrando contenedores Blue y Green
5. **Logs del Switch** → Mostrando cambio de ambiente
6. **Navegador** → Aplicación funcionando en http://104.248.211.70

---

¡Listo! Con esto tu workflow se conectará automáticamente a tu VPS y hará el deployment real del switching Blue-Green. 🚀
