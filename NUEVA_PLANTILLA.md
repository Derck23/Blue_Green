# 🚀 Guía de Uso - Nueva Plantilla Blue-Green

## 📋 Descripción

El proyecto ahora usa una **plantilla estándar de Blue-Green Deployment** que incluye:
- ✅ Despliegue automático con `docker pull`
- ✅ Smoke tests integrados
- ✅ Switch automático de tráfico
- ✅ Rollback automático si los tests fallan
- ✅ Limpieza opcional de contenedores antiguos

## 🏗️ Arquitectura Simplificada

```
          Usuario
             ↓
    Nginx (Puerto 80)
             ↓
      [current_app.conf]
             ↓
    ┌────────┴────────┐
    ↓                 ↓
BLUE (8001)      GREEN (8002)
app-BLUE         app-GREEN
[ACTIVO]         [STANDBY]
```

## 🚀 Scripts Disponibles

### 1. `blue-green-deploy.sh` - Script Principal

Este es el script principal con menú interactivo.

```bash
# Ejecutar con menú
./blue-green-deploy.sh

# O con comandos directos
./blue-green-deploy.sh init      # Despliegue inicial
./blue-green-deploy.sh deploy    # Despliegue Blue-Green
./blue-green-deploy.sh switch    # Cambiar tráfico
./blue-green-deploy.sh status    # Ver estado
./blue-green-deploy.sh stop      # Detener todo
```

### 2. `deploy-green.sh` - Despliegue Avanzado

Script basado en la plantilla del profesor con smoke tests.

```bash
# Usando imagen local
./deploy-green.sh sports-portal:latest

# Usando imagen desde Docker Hub
./deploy-green.sh tu-usuario/sports-portal:latest
```

## 📖 Flujo de Trabajo Completo

### Paso 1: Despliegue Inicial

```bash
# Dar permisos (primera vez)
chmod +x blue-green-deploy.sh deploy-green.sh

# Ejecutar despliegue inicial
./blue-green-deploy.sh init
```

**Esto hace:**
1. ✅ Construye la imagen Docker
2. ✅ Despliega contenedor Blue (puerto 8001)
3. ✅ Ejecuta smoke test en Blue
4. ✅ Despliega contenedor Green (puerto 8002)
5. ✅ Ejecuta smoke test en Green
6. ✅ Configura Blue como activo
7. ✅ Muestra estado final

**Resultado:**
- Blue ACTIVO en http://127.0.0.1:8001
- Green STANDBY en http://127.0.0.1:8002

### Paso 2: Modificar Código

```bash
# Editar tu aplicación
vim src/App.jsx

# Por ejemplo, cambiar el texto de "Blue" a "Green"
# o actualizar funcionalidades
```

### Paso 3: Desplegar Nueva Versión

```bash
./blue-green-deploy.sh deploy
```

**Esto hace:**
1. ✅ Identifica ambiente activo (Blue)
2. ✅ Construye nueva imagen
3. ✅ Despliega en ambiente inactivo (Green)
4. ✅ Ejecuta smoke test en Green
5. ✅ **Si test pasa**: Pregunta si hacer switch
6. ✅ **Si test falla**: Revierte automáticamente

### Paso 4: Switch de Tráfico

Durante el despliegue te preguntará:

```
¿Cambiar tráfico a GREEN? (s/N):
```

- **Presiona 's'**: Cambia tráfico inmediatamente
- **Presiona 'N'**: Mantiene Blue activo

O hazlo manualmente:
```bash
./blue-green-deploy.sh switch
```

### Paso 5: Verificar

```bash
# Ver estado actual
./blue-green-deploy.sh status

# Probar endpoints
curl http://127.0.0.1:8001  # Blue
curl http://127.0.0.1:8002  # Green
```

## 🧪 Smoke Tests Automáticos

Los smoke tests se ejecutan automáticamente en cada despliegue:

```bash
# Test básico
curl --fail --silent --show-error "http://127.0.0.1:PORT/"
```

**Si el test falla:**
1. ❌ Despliegue se cancela
2. ❌ Contenedor fallido se elimina
3. ❌ Ambiente anterior sigue activo
4. ❌ Script termina con error

**Si el test pasa:**
1. ✅ Contenedor está listo
2. ✅ Puede recibir tráfico
3. ✅ Script continúa

## 📊 Configuración

### Variables principales en `blue-green-deploy.sh`:

```bash
DOCKER_IMAGE="sports-portal:latest"  # Imagen a usar
CONTAINER_PORT="80"                   # Puerto interno del contenedor
UPSTREAM_BLUE="http://127.0.0.1:8001;"
UPSTREAM_GREEN="http://127.0.0.1:8002;"
```

### Puertos:

| Componente | Puerto |
|------------|--------|
| Blue | 8001 |
| Green | 8002 |
| Nginx interno | 80 |

## 🔄 Ejemplos de Uso

### Ejemplo 1: Primer Despliegue

```bash
# 1. Despliegue inicial
./blue-green-deploy.sh init

# Salida esperada:
# ✓ Imagen construida
# ✓ Blue desplegado (8001)
# ✓ Smoke test Blue: PASS
# ✓ Green desplegado (8002)
# ✓ Smoke test Green: PASS
# Ambiente activo: BLUE
```

### Ejemplo 2: Actualizar Aplicación

```bash
# 1. Modificar código
echo "Nueva versión" >> src/App.jsx

# 2. Desplegar
./blue-green-deploy.sh deploy

# 3. El script pregunta:
# ¿Cambiar tráfico a GREEN? (s/N): s

# 4. ¿Eliminar contenedor BLUE? (s/N): n

# Resultado:
# ✓ Green ahora es ACTIVO
# ✓ Blue queda como backup
```

### Ejemplo 3: Rollback Manual

```bash
# Si algo falla después del switch, simplemente vuelve a cambiar:
./blue-green-deploy.sh switch

# Cambia de GREEN a BLUE instantáneamente
```

### Ejemplo 4: Ver Estado

```bash
./blue-green-deploy.sh status

# Salida:
# Ambiente activo: BLUE
# Contenedores:
#   app-BLUE    Up 5 minutes    0.0.0.0:8001->80/tcp
#   app-GREEN   Up 2 minutes    0.0.0.0:8002->80/tcp
```

### Ejemplo 5: Detener Todo

```bash
./blue-green-deploy.sh stop

# Detiene y elimina ambos contenedores
# Elimina archivo de configuración
```

## 🎯 Usando Imágenes Externas

Si tienes la imagen en Docker Hub:

```bash
# Construir y subir imagen
docker build -t tu-usuario/sports-portal:latest .
docker push tu-usuario/sports-portal:latest

# Desplegar usando imagen externa
./deploy-green.sh tu-usuario/sports-portal:latest
```

## 🔍 Troubleshooting

### Problema: Smoke test falla

```bash
# Ver logs del contenedor
docker logs app-GREEN

# Probar manualmente
curl -v http://127.0.0.1:8002/

# Verificar que el contenedor inició
docker ps | grep app-GREEN
```

### Problema: Puerto en uso

```bash
# Ver qué usa el puerto
lsof -i :8001
lsof -i :8002

# Detener todo
./blue-green-deploy.sh stop
```

### Problema: Imagen no se construye

```bash
# Ver errores de build
docker build -t sports-portal:latest . --no-cache

# Verificar Dockerfile
cat Dockerfile
```

## 📝 Diferencias con la versión anterior

| Aspecto | Anterior (docker-compose) | Nueva (Plantilla) |
|---------|---------------------------|-------------------|
| **Orquestación** | docker-compose | docker run directo |
| **Puertos** | 80, 8081, 8082 | 8001, 8002 |
| **Nginx** | Contenedor separado | Integrado en app |
| **Switch** | Editar nginx-router.conf | Archivo current_app.conf |
| **Smoke tests** | Archivo separado | Integrados en deploy |

## 🎓 Ventajas de la Nueva Plantilla

1. ✅ **Más simple**: Menos archivos de configuración
2. ✅ **Smoke tests integrados**: No hay que ejecutarlos por separado
3. ✅ **Rollback automático**: Si el test falla, revierte solo
4. ✅ **Estándar**: Sigue la plantilla del profesor
5. ✅ **Flexible**: Funciona con imágenes locales o remotas

## 📚 Comandos Útiles

```bash
# Ver contenedores
docker ps -a | grep app-

# Ver logs
docker logs app-BLUE
docker logs app-GREEN

# Ejecutar comando en contenedor
docker exec -it app-BLUE sh

# Eliminar contenedor manualmente
docker stop app-BLUE && docker rm app-BLUE

# Ver imágenes
docker images | grep sports-portal

# Limpiar todo
docker system prune -a
```

## 🎉 Quick Start

```bash
# Un solo comando para empezar:
chmod +x blue-green-deploy.sh && ./blue-green-deploy.sh init

# Eso es todo! Tu aplicación está corriendo en:
# - Blue (activo): http://127.0.0.1:8001
# - Green (standby): http://127.0.0.1:8002
```

## 💡 Tips

1. **Siempre prueba en el ambiente inactivo antes del switch**
2. **Mantén el ambiente anterior como backup**
3. **Los smoke tests son tu amigo - no los omitas**
4. **Usa tags de versión en tus imágenes: `v1.0`, `v1.1`, etc.**
5. **Documenta cada despliegue y los cambios realizados**

---

**¿Problemas?** Revisa los logs con `docker logs app-BLUE` o `docker logs app-GREEN`

**¿Necesitas más ayuda?** Ejecuta `./blue-green-deploy.sh status` para ver el estado actual
