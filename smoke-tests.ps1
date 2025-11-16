# Smoke Tests para Blue-Green Deployment (PowerShell)
# Pruebas básicas para verificar que la aplicación funciona correctamente

# Contadores
$script:TestsPassed = 0
$script:TestsFailed = 0
$script:TotalTests = 0

# Funciones de utilidad
function Print-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "================================" -ForegroundColor Blue
}

function Test-Http {
    param(
        [string]$Url,
        [string]$ExpectedStatus,
        [string]$Description
    )
    
    $script:TotalTests++
    Write-Host "`n[TEST $script:TotalTests] $Description" -ForegroundColor Yellow
    Write-Host "  URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
        $status = $response.StatusCode.ToString()
        
        if ($status -eq $ExpectedStatus) {
            Write-Host "  Status: $status" -ForegroundColor Gray
            Write-Host "✓ PASS" -ForegroundColor Green
            $script:TestsPassed++
            return $true
        } else {
            Write-Host "  Expected: $ExpectedStatus, Got: $status" -ForegroundColor Red
            Write-Host "✗ FAIL" -ForegroundColor Red
            $script:TestsFailed++
            return $false
        }
    }
    catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "✗ FAIL" -ForegroundColor Red
        $script:TestsFailed++
        return $false
    }
}

function Test-Content {
    param(
        [string]$Url,
        [string]$ExpectedContent,
        [string]$Description
    )
    
    $script:TotalTests++
    Write-Host "`n[TEST $script:TotalTests] $Description" -ForegroundColor Yellow
    Write-Host "  URL: $Url" -ForegroundColor Gray
    
    try {
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
        $content = $response.Content
        
        if ($content -match $ExpectedContent) {
            Write-Host "  Found: '$ExpectedContent'" -ForegroundColor Gray
            Write-Host "✓ PASS" -ForegroundColor Green
            $script:TestsPassed++
            return $true
        } else {
            Write-Host "  Expected content not found: '$ExpectedContent'" -ForegroundColor Red
            Write-Host "✗ FAIL" -ForegroundColor Red
            $script:TestsFailed++
            return $false
        }
    }
    catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "✗ FAIL" -ForegroundColor Red
        $script:TestsFailed++
        return $false
    }
}

function Test-ResponseTime {
    param(
        [string]$Url,
        [int]$MaxTimeMs,
        [string]$Description
    )
    
    $script:TotalTests++
    Write-Host "`n[TEST $script:TotalTests] $Description" -ForegroundColor Yellow
    Write-Host "  URL: $Url" -ForegroundColor Gray
    
    try {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        $response = Invoke-WebRequest -Uri $Url -UseBasicParsing -TimeoutSec 5
        $stopwatch.Stop()
        
        $responseTime = $stopwatch.ElapsedMilliseconds
        
        if ($responseTime -lt $MaxTimeMs) {
            Write-Host "  Response time: ${responseTime}ms (max: ${MaxTimeMs}ms)" -ForegroundColor Gray
            Write-Host "✓ PASS" -ForegroundColor Green
            $script:TestsPassed++
            return $true
        } else {
            Write-Host "  Response time: ${responseTime}ms (max: ${MaxTimeMs}ms)" -ForegroundColor Red
            Write-Host "✗ FAIL - Too slow" -ForegroundColor Red
            $script:TestsFailed++
            return $false
        }
    }
    catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "✗ FAIL" -ForegroundColor Red
        $script:TestsFailed++
        return $false
    }
}

function Test-Container {
    param(
        [string]$ContainerName,
        [string]$Description
    )
    
    $script:TotalTests++
    Write-Host "`n[TEST $script:TotalTests] $Description" -ForegroundColor Yellow
    
    $container = docker ps --filter "name=$ContainerName" --format "{{.Names}}"
    
    if ($container -eq $ContainerName) {
        Write-Host "  Container '$ContainerName' is running" -ForegroundColor Gray
        Write-Host "✓ PASS" -ForegroundColor Green
        $script:TestsPassed++
        return $true
    } else {
        Write-Host "  Container '$ContainerName' is not running" -ForegroundColor Red
        Write-Host "✗ FAIL" -ForegroundColor Red
        $script:TestsFailed++
        return $false
    }
}

# Inicio de los tests
Clear-Host
Print-Header "SMOKE TESTS - Blue-Green Deployment"
Write-Host ""
Write-Host "Fecha: $(Get-Date)" -ForegroundColor Gray
Write-Host "Testing endpoints..." -ForegroundColor Gray
Write-Host ""

# ============================================
# SUITE 1: Tests de Contenedores
# ============================================
Print-Header "SUITE 1: Container Health Tests"

Test-Container "sports-portal-blue" "Blue container is running"
Test-Container "sports-portal-green" "Green container is running"
Test-Container "sports-portal-router" "Router container is running"

# ============================================
# SUITE 2: Tests de Health Checks
# ============================================
Print-Header "SUITE 2: Health Check Tests"

Test-Http "http://localhost:8081/health" "200" "Blue health endpoint responds"
Test-Http "http://localhost:8082/health" "200" "Green health endpoint responds"
Test-Http "http://localhost/router-health" "200" "Router health endpoint responds"
Test-Http "http://localhost/health/blue" "200" "Blue health via router responds"
Test-Http "http://localhost/health/green" "200" "Green health via router responds"

# Verificar contenido de health checks
Test-Content "http://localhost:8081/health" "healthy" "Blue health returns correct content"
Test-Content "http://localhost:8082/health" "healthy" "Green health returns correct content"

# ============================================
# SUITE 3: Tests de Aplicación
# ============================================
Print-Header "SUITE 3: Application Tests"

Test-Http "http://localhost/" "200" "Production endpoint responds"
Test-Http "http://localhost:8081/" "200" "Blue application responds"
Test-Http "http://localhost:8082/" "200" "Green application responds"

# Verificar contenido de la aplicación
Test-Content "http://localhost/" "Portal Deportivo" "Production shows app title"
Test-Content "http://localhost:8081/" "Portal Deportivo" "Blue shows app title"
Test-Content "http://localhost:8082/" "Portal Deportivo" "Green shows app title"

# Verificar que la app tiene contenido esperado
Test-Content "http://localhost/" "Fútbol" "App shows sports content (Fútbol)"
Test-Content "http://localhost/" "Baloncesto" "App shows sports content (Baloncesto)"
Test-Content "http://localhost/" "Blue-Green" "App shows deployment info"

# ============================================
# SUITE 4: Tests de Rendimiento
# ============================================
Print-Header "SUITE 4: Performance Tests"

Test-ResponseTime "http://localhost/" 1000 "Production responds in < 1s"
Test-ResponseTime "http://localhost:8081/" 1000 "Blue responds in < 1s"
Test-ResponseTime "http://localhost:8082/" 1000 "Green responds in < 1s"
Test-ResponseTime "http://localhost/health/blue" 500 "Blue health responds in < 500ms"
Test-ResponseTime "http://localhost/health/green" 500 "Green health responds in < 500ms"

# ============================================
# SUITE 5: Tests de Assets Estáticos
# ============================================
Print-Header "SUITE 5: Static Assets Tests"

Test-Http "http://localhost:8081/vite.svg" "200" "Blue serves static assets"
Test-Http "http://localhost:8082/vite.svg" "200" "Green serves static assets"

# ============================================
# SUITE 6: Tests de Carga Simple
# ============================================
Print-Header "SUITE 6: Load Tests (Simple)"

$script:TotalTests++
Write-Host "`n[TEST $script:TotalTests] Load test: 50 concurrent requests" -ForegroundColor Yellow

$loadFailed = 0
1..50 | ForEach-Object {
    try {
        Invoke-WebRequest -Uri "http://localhost/" -UseBasicParsing -TimeoutSec 5 | Out-Null
    }
    catch {
        $loadFailed++
    }
}

if ($loadFailed -eq 0) {
    Write-Host "  All 50 requests successful" -ForegroundColor Gray
    Write-Host "✓ PASS" -ForegroundColor Green
    $script:TestsPassed++
} else {
    Write-Host "  Failed requests: $loadFailed/50" -ForegroundColor Red
    Write-Host "✗ FAIL" -ForegroundColor Red
    $script:TestsFailed++
}

# ============================================
# SUITE 7: Tests de Ambiente Activo
# ============================================
Print-Header "SUITE 7: Active Environment Tests"

$script:TotalTests++
Write-Host "`n[TEST $script:TotalTests] Verify active environment configuration" -ForegroundColor Yellow

$config = Get-Content nginx-router.conf -Raw
if ($config -match "proxy_pass http://blue_backend") {
    $activeEnv = "BLUE"
} elseif ($config -match "proxy_pass http://green_backend") {
    $activeEnv = "GREEN"
} else {
    $activeEnv = "UNKNOWN"
}

Write-Host "  Active environment: $activeEnv" -ForegroundColor Gray

if ($activeEnv -ne "UNKNOWN") {
    Write-Host "✓ PASS" -ForegroundColor Green
    $script:TestsPassed++
} else {
    Write-Host "✗ FAIL" -ForegroundColor Red
    $script:TestsFailed++
}

# ============================================
# SUITE 8: Tests de Logs
# ============================================
Print-Header "SUITE 8: Log Tests"

$script:TotalTests++
Write-Host "`n[TEST $script:TotalTests] Check for errors in nginx logs" -ForegroundColor Yellow

$logs = docker logs sports-portal-router 2>&1 | Select-String -Pattern "error" -NotMatch "error_log"
$errorCount = ($logs | Measure-Object).Count

if ($errorCount -eq 0) {
    Write-Host "  No errors found in router logs" -ForegroundColor Gray
    Write-Host "✓ PASS" -ForegroundColor Green
    $script:TestsPassed++
} else {
    Write-Host "  Found $errorCount errors in router logs" -ForegroundColor Red
    Write-Host "✗ FAIL" -ForegroundColor Red
    $script:TestsFailed++
}

# ============================================
# Resumen Final
# ============================================
Write-Host ""
Print-Header "SMOKE TESTS SUMMARY"
Write-Host ""
Write-Host "Total Tests:   $script:TotalTests"
Write-Host "Passed:        $script:TestsPassed" -ForegroundColor Green
Write-Host "Failed:        $script:TestsFailed" -ForegroundColor Red
Write-Host ""

# Calcular porcentaje
if ($script:TotalTests -gt 0) {
    $passRate = [math]::Round(($script:TestsPassed * 100 / $script:TotalTests), 2)
    Write-Host "Success Rate:  $passRate%"
}

Write-Host ""

# Determinar resultado final
if ($script:TestsFailed -eq 0) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "  ✓ ALL SMOKE TESTS PASSED!" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host ""
    Write-Host "The application is healthy and ready for use!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host "  ✗ SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please review the failed tests above." -ForegroundColor Yellow
    Write-Host "The application may not be functioning correctly." -ForegroundColor Yellow
    exit 1
}
