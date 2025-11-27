# Configuración del Blue-Green Switching

## ✅ Cambios Implementados

El workflow ahora tiene **switching real** entre ambientes Blue y Green:

### 🔄 Flujo de Deployment Completo

```
1. Build & Test → 2. Build Docker → 3. Determinar Target → 4. Deploy Inactivo → 5. Switch Manual
```

### 📋 ¿Qué hace cada Job?

1. **build-and-test**: Compila y valida el código
2. **build-docker**: Crea la imagen Docker
3. **determine-target**: Detecta qué ambiente está activo y cuál usar para deployment
4. **deploy-inactive**: Despliega en el ambiente inactivo (Blue o Green)
5. **switch-to-production**: Cambia el tráfico de producción al nuevo ambiente
6. **rollback**: Revierte al ambiente anterior en caso de problemas

---

## 🚀 Configuración Inicial en GitHub

### Paso 1: Crear Variable de Repositorio

Necesitas crear una variable para trackear qué ambiente está activo:

1. Ve a tu repositorio en GitHub
2. Click en **Settings** → **Secrets and variables** → **Actions**
3. En la pestaña **Variables**, click en **New repository variable**
4. Crea:
   - **Name**: `ACTIVE_ENVIRONMENT`
   - **Value**: `blue` (valor inicial)
5. Click **Add variable**

### Paso 2: Configurar Entorno de Producción

1. En **Settings** → **Environments**
2. Click **New environment**
3. Nombre: `production`
4. (Opcional) Agrega protection rules:
   - Required reviewers: Marca y agrega revisores
   - Wait timer: 5 minutos

### Paso 3: Configurar Entorno de Rollback

1. Crear otro environment llamado `production-rollback`
2. Agregar protection rules similares

---

## 📖 Cómo Usar el Workflow

### 🔵 Deployment Normal (Push a Main)

Cuando haces `push` a `main`:

```bash
git add .
git commit -m "Nueva feature"
git push origin main
```

El workflow automáticamente:
1. ✅ Compila y testea
2. ✅ Crea imagen Docker
3. ✅ Identifica ambiente inactivo (si Blue está activo, despliega en Green)
4. ✅ Despliega en el ambiente inactivo
5. ⏸️ **ESPERA** tu confirmación para hacer switch

### 🔄 Switch a Producción (Manual)

Después del deployment exitoso:

1. Ve a **Actions** → **Blue-Green Deployment Pipeline**
2. Click en el workflow run más reciente
3. Click en **Re-run jobs** → **Run workflow**
4. Selecciona:
   - **action**: `switch`
   - Click **Run workflow**

Esto ejecutará el script `switch-environment.sh` que:
- Detiene el proxy actual
- Crea un nuevo proxy Nginx apuntando al ambiente nuevo
- Verifica que todo funcione

### ⏮️ Rollback (En caso de problemas)

Si algo sale mal:

1. Ve a **Actions** → **Blue-Green Deployment Pipeline**
2. Click **Run workflow**
3. Selecciona:
   - **action**: `rollback`
   - Click **Run workflow**

Esto revierte al ambiente anterior automáticamente.

---

## 🔍 Verificación del Switching

### Verificar Estado Actual

Puedes ver qué ambiente está activo:

```bash
# Ver variable de GitHub (requiere gh CLI)
gh variable list

# O manualmente en Settings → Variables
```

### Verificar Contenedores Localmente

Si tienes acceso al servidor:

```bash
# Ver contenedores corriendo
docker ps --filter "name=app-"

# Ver logs del proxy
docker logs app-proxy

# Ver a qué ambiente apunta producción
curl http://localhost/health
```

---

## 📊 Diagrama del Flujo

```
┌─────────────┐
│   PUSH to   │
│    main     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Build &    │
│    Test     │
└──────┬──────┘
       │
       ▼
┌─────────────┐       ┌──────────────┐
│   Detect    │       │ Estado actual│
│   Active    │◄──────┤ BLUE = activo│
│   Env       │       └──────────────┘
└──────┬──────┘
       │ (Blue activo)
       ▼
┌─────────────┐
│   Deploy    │
│   GREEN     │ ← Nueva versión
└──────┬──────┘
       │
       ▼
┌─────────────┐
│   ESPERA    │
│   Manual    │ ← TÚ decides cuándo
│   Switch    │
└──────┬──────┘
       │
       ▼
┌─────────────┐       ┌──────────────┐
│   Proxy     │       │ Proxy = 80   │
│   → GREEN   │──────►│ Green = 8082 │
└──────┬──────┘       │ Blue = 8081  │
       │              └──────────────┘
       ▼
┌─────────────┐
│  PRODUCCIÓN │
│   = GREEN   │
└─────────────┘
```

---

## 🎯 Ejemplo Completo

### Escenario: Deployment de Nueva Feature

**Estado Inicial:**
- ✅ Blue activo en producción (puerto 80 → 8081)
- ⭕ Green inactivo

**Paso 1: Push del código**
```bash
git push origin main
```

**Paso 2: Workflow despliega en Green**
- Build exitoso ✅
- Tests pasan ✅
- Deploy en Green (puerto 8082) ✅
- Health check OK ✅

**Paso 3: Switch Manual**
- Vas a Actions
- Run workflow → action: `switch`
- Proxy cambia a puerto 8082 (Green) ✅

**Estado Final:**
- ✅ Green activo en producción (puerto 80 → 8082)
- 🔵 Blue disponible para rollback (puerto 8081)

---

## 🔧 Scripts Importantes

### `switch-environment.sh`

Este script hace el switching real:
- Detiene el proxy actual
- Crea configuración de Nginx
- Inicia proxy apuntando al ambiente seleccionado
- Verifica que funcione

### Uso Manual

```bash
# Switch a Green
./switch-environment.sh green

# Switch a Blue
./switch-environment.sh blue

# Ver estado
docker ps --filter "name=app-"
```

---

## ⚠️ Notas Importantes

1. **Ambos ambientes corren siempre**: Blue en 8081, Green en 8082
2. **Solo el proxy cambia**: El puerto 80 apunta a uno u otro
3. **Zero downtime**: El cambio es instantáneo
4. **Rollback rápido**: Solo cambias el proxy de vuelta

---

## 🐛 Troubleshooting

### El switch no funciona

```bash
# Verificar que ambos contenedores estén corriendo
docker ps --filter "name=app-"

# Ver logs del contenedor
docker logs app-blue
docker logs app-green

# Verificar conectividad
curl http://localhost:8081
curl http://localhost:8082
```

### Variable ACTIVE_ENVIRONMENT no existe

```bash
# Crear variable con gh CLI
gh variable set ACTIVE_ENVIRONMENT --body "blue"

# O manualmente en GitHub Settings → Variables
```

### Proxy no responde

```bash
# Ver logs del proxy
docker logs app-proxy

# Reiniciar proxy
docker restart app-proxy

# Re-ejecutar switch
./switch-environment.sh green
```

---

## ✨ Ventajas de Esta Implementación

✅ **Zero Downtime**: Nunca se detiene el servicio
✅ **Rollback Instantáneo**: Solo cambias el proxy
✅ **Testing en Producción**: Puedes probar Green antes del switch
✅ **Trazabilidad**: Cada cambio queda registrado en GitHub Actions
✅ **Control Manual**: Tú decides cuándo hacer el switch
✅ **Ambientes Paralelos**: Ambos ambientes corren simultáneamente

---

## 📚 Referencias

- [Blue-Green Deployment Pattern](https://martinfowler.com/bliki/BlueGreenDeployment.html)
- [GitHub Actions Environments](https://docs.github.com/en/actions/deployment/targeting-different-environments)
- [Docker Networking](https://docs.docker.com/network/)
