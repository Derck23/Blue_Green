# 🎓 Guía para el Profesor - Ver el Switching Blue-Green

## 📍 Dónde Ver el Switching en el Pipeline

### 1️⃣ En GitHub Actions

Cuando ejecutes el workflow, verás:

#### Job: `determine-target` 
```
══════════════════════════════════════════════════════════
     🔍 DETECCIÓN DE AMBIENTE BLUE-GREEN
══════════════════════════════════════════════════════════

📊 Variable de estado:
   ACTIVE_ENVIRONMENT = blue

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 SWITCHING BLUE-GREEN DETECTADO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Ambiente ACTUAL:    🔵 BLUE (puerto 8081)
📍 Ambiente OBJETIVO:  🟢 GREEN (puerto 8082)

✅ SWITCHING: De BLUE → GREEN
```

**Esto demuestra**: El sistema detecta que Blue está activo y automáticamente elige Green para el deployment.

---

#### Job: `deploy-inactive`

**ANTES del deployment:**
```
══════════════════════════════════════════════════════════
     📦 CONTENEDORES DOCKER (ANTES)
══════════════════════════════════════════════════════════

NAMES      STATE    STATUS          PORTS
app-blue   running  Up 5 minutes    0.0.0.0:8081->80/tcp
```

**Durante deployment:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 DEPLOYMENT EN AMBIENTE INACTIVO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 Producción actual: blue
🎯 Desplegando en: green (puerto 8082)
```

**DESPUÉS del deployment:**
```
══════════════════════════════════════════════════════════
     📊 CONTENEDORES DOCKER (DESPUÉS)
══════════════════════════════════════════════════════════

NAMES       STATE    STATUS          PORTS
app-blue    running  Up 5 minutes    0.0.0.0:8081->80/tcp
app-green   running  Up 10 seconds   0.0.0.0:8082->80/tcp

📝 Ambos ambientes Blue y Green están corriendo
```

**Esto demuestra**: Ahora hay DOS contenedores corriendo (Blue y Green).

---

#### Job: `switch-to-production`

**ANTES del switch:**
```
══════════════════════════════════════════════════════════
     📊 ESTADO ANTES DEL SWITCH
══════════════════════════════════════════════════════════

🔍 Ambiente activo: blue

🐳 Contenedores Docker:
NAMES       STATE    STATUS          PORTS
app-blue    running  Up 5 minutes    0.0.0.0:8081->80/tcp
app-green   running  Up 2 minutes    0.0.0.0:8082->80/tcp
```

**Durante el switch:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 SWITCHING BLUE-GREEN EN PROGRESO
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📍 DE:   blue
📍 HACIA: green

🔧 Acción: Cambiar proxy Nginx al nuevo ambiente
```

**DESPUÉS del switch:**
```
══════════════════════════════════════════════════════════
     📊 ESTADO DESPUÉS DEL SWITCH
══════════════════════════════════════════════════════════

🐳 Contenedores Docker:
NAMES       STATE    STATUS          PORTS
app-blue    running  Up 8 minutes    0.0.0.0:8081->80/tcp
app-green   running  Up 5 minutes    0.0.0.0:8082->80/tcp
app-proxy   running  Up 5 seconds    0.0.0.0:80->80/tcp

🔀 Proxy activo: ✅
```

**Resumen final:**
```
╔═══════════════════════════════════════════════════════╗
║      🎉 SWITCHING COMPLETADO EXITOSAMENTE           ║
╚═══════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────┐
│  ANTES → DESPUÉS                                    │
├─────────────────────────────────────────────────────┤
│  🔵 BLUE    →  🟢 GREEN                            │
└─────────────────────────────────────────────────────┘

📍 Producción ahora en: green
🔄 Switching Blue-Green aplicado

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Blue-Green Deployment completado
✅ Zero downtime garantizado
✅ Rollback disponible
```

---

## 🔍 Cómo Leer los Logs

### Evidencia 1: Detección del ambiente
Busca en los logs: `"SWITCHING BLUE-GREEN DETECTADO"`
- Muestra qué ambiente está activo
- Muestra a qué ambiente se va a cambiar

### Evidencia 2: Contenedores Docker
Busca: `"CONTENEDORES DOCKER (ANTES)"` y `"CONTENEDORES DOCKER (DESPUÉS)"`
- ANTES: Solo un contenedor
- DESPUÉS: Dos contenedores (Blue y Green)

### Evidencia 3: El Switch
Busca: `"SWITCHING BLUE-GREEN EN PROGRESO"`
- Muestra DE → HACIA
- Muestra el cambio del proxy

### Evidencia 4: Confirmación
Busca: `"SWITCHING COMPLETADO EXITOSAMENTE"`
- Diagrama ANTES → DESPUÉS
- Confirmación del cambio

---

## 📸 Capturas que Necesitas

1. **Captura del job `determine-target`**
   - Muestra la detección del ambiente

2. **Captura del job `deploy-inactive`**
   - Muestra estado ANTES y DESPUÉS de Docker

3. **Captura del job `switch-to-production`**
   - Muestra el switching en acción
   - Muestra el resumen final

---

## 🚀 Cómo Ejecutar para el Profesor

### Paso 1: Configurar variable
```
Settings → Secrets and variables → Actions → Variables
Crear: ACTIVE_ENVIRONMENT = blue
```

### Paso 2: Hacer push
```bash
git add .
git commit -m "Demo switching Blue-Green"
git push origin main
```

Esto ejecuta el deployment en Green (porque Blue está activo).

### Paso 3: Ver el workflow
Ve a Actions → Verás los logs con todo el switching visual.

### Paso 4: Ejecutar el switch manual
Actions → Run workflow → action: switch

Verás el switch de Blue a Green en los logs.

---

## ✅ Qué Mostrar al Profesor

1. **El workflow completo** corriendo
2. **Los logs del job `determine-target`** - muestra la detección
3. **Los logs del job `deploy-inactive`** - muestra Docker ANTES/DESPUÉS
4. **Los logs del job `switch-to-production`** - muestra el switching

Con estos 4 elementos, el profesor verá claramente:
- ✅ Detección automática del ambiente
- ✅ Deployment en el ambiente inactivo
- ✅ Contenedores Docker cambiando
- ✅ Switching real entre Blue y Green

---

## 💡 Explicación Simple

**Profesor**: "¿Dónde está el switching?"

**Tú**: "Mira los logs del pipeline. El job `determine-target` detecta que Blue está activo, entonces despliega en Green. Luego el job `switch-to-production` cambia el proxy para que producción apunte a Green. En los logs se ve claramente el estado de Docker ANTES y DESPUÉS del cambio."

**Profesor**: "¿Cómo sé que cambia entre Blue y Green?"

**Tú**: "Mira los logs de `determine-target`. Si haces otro deployment, dirá 'SWITCHING: De GREEN → BLUE' porque ahora Green está activo. El switching es automático."
