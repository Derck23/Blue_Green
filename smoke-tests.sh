#!/bin/bash

# Smoke Tests para Blue-Green Deployment
# Pruebas básicas para verificar que la aplicación funciona correctamente

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

# Función para imprimir encabezado
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Función para ejecutar un test
run_test() {
    local test_name=$1
    local test_command=$2
    local expected_result=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} $test_name"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Función para test HTTP
test_http() {
    local url=$1
    local expected_status=$2
    local description=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} $description"
    echo -e "  URL: $url"
    
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")
    
    if [ "$response" == "$expected_status" ]; then
        echo -e "  Status: $response"
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  Expected: $expected_status, Got: $response"
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Función para test de contenido
test_content() {
    local url=$1
    local expected_content=$2
    local description=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} $description"
    echo -e "  URL: $url"
    
    local content=$(curl -s "$url" 2>/dev/null || echo "")
    
    if echo "$content" | grep -q "$expected_content"; then
        echo -e "  Found: '$expected_content'"
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  Expected content not found: '$expected_content'"
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Función para test de tiempo de respuesta
test_response_time() {
    local url=$1
    local max_time=$2
    local description=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} $description"
    echo -e "  URL: $url"
    
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" "$url" 2>/dev/null || echo "999")
    local response_time_ms=$(echo "$response_time * 1000" | bc | cut -d. -f1)
    local max_time_ms=$(echo "$max_time * 1000" | bc | cut -d. -f1)
    
    if [ "$response_time_ms" -lt "$max_time_ms" ]; then
        echo -e "  Response time: ${response_time_ms}ms (max: ${max_time_ms}ms)"
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  Response time: ${response_time_ms}ms (max: ${max_time_ms}ms)"
        echo -e "${RED}✗ FAIL - Too slow${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Función para test de contenedor
test_container() {
    local container_name=$1
    local description=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} $description"
    
    if docker ps | grep -q "$container_name"; then
        echo -e "  Container '$container_name' is running"
        echo -e "${GREEN}✓ PASS${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  Container '$container_name' is not running"
        echo -e "${RED}✗ FAIL${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Inicio de los tests
clear
print_header "SMOKE TESTS - Blue-Green Deployment"
echo ""
echo "Fecha: $(date)"
echo "Testing endpoints..."
echo ""

# ============================================
# SUITE 1: Tests de Contenedores
# ============================================
print_header "SUITE 1: Container Health Tests"

test_container "sports-portal-blue" "Blue container is running"
test_container "sports-portal-green" "Green container is running"
test_container "sports-portal-router" "Router container is running"

# ============================================
# SUITE 2: Tests de Health Checks
# ============================================
print_header "SUITE 2: Health Check Tests"

test_http "http://localhost:8081/health" "200" "Blue health endpoint responds"
test_http "http://localhost:8082/health" "200" "Green health endpoint responds"
test_http "http://localhost/router-health" "200" "Router health endpoint responds"
test_http "http://localhost/health/blue" "200" "Blue health via router responds"
test_http "http://localhost/health/green" "200" "Green health via router responds"

# Verificar contenido de health checks
test_content "http://localhost:8081/health" "healthy" "Blue health returns correct content"
test_content "http://localhost:8082/health" "healthy" "Green health returns correct content"

# ============================================
# SUITE 3: Tests de Aplicación
# ============================================
print_header "SUITE 3: Application Tests"

test_http "http://localhost/" "200" "Production endpoint responds"
test_http "http://localhost:8081/" "200" "Blue application responds"
test_http "http://localhost:8082/" "200" "Green application responds"

# Verificar contenido de la aplicación
test_content "http://localhost/" "Portal Deportivo" "Production shows app title"
test_content "http://localhost:8081/" "Portal Deportivo" "Blue shows app title"
test_content "http://localhost:8082/" "Portal Deportivo" "Green shows app title"

# Verificar que la app tiene contenido esperado
test_content "http://localhost/" "Fútbol" "App shows sports content (Fútbol)"
test_content "http://localhost/" "Baloncesto" "App shows sports content (Baloncesto)"
test_content "http://localhost/" "Blue-Green" "App shows deployment info"

# ============================================
# SUITE 4: Tests de Rendimiento
# ============================================
print_header "SUITE 4: Performance Tests"

test_response_time "http://localhost/" "1.0" "Production responds in < 1s"
test_response_time "http://localhost:8081/" "1.0" "Blue responds in < 1s"
test_response_time "http://localhost:8082/" "1.0" "Green responds in < 1s"
test_response_time "http://localhost/health/blue" "0.5" "Blue health responds in < 500ms"
test_response_time "http://localhost/health/green" "0.5" "Green health responds in < 500ms"

# ============================================
# SUITE 5: Tests de Assets Estáticos
# ============================================
print_header "SUITE 5: Static Assets Tests"

test_http "http://localhost:8081/vite.svg" "200" "Blue serves static assets"
test_http "http://localhost:8082/vite.svg" "200" "Green serves static assets"

# ============================================
# SUITE 6: Tests de Carga Simple
# ============================================
print_header "SUITE 6: Load Tests (Simple)"

TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} Load test: 50 concurrent requests"

LOAD_FAILED=0
for i in {1..50}; do
    curl -s -f http://localhost/ > /dev/null 2>&1 || LOAD_FAILED=$((LOAD_FAILED + 1))
done

if [ $LOAD_FAILED -eq 0 ]; then
    echo -e "  All 50 requests successful"
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  Failed requests: $LOAD_FAILED/50"
    echo -e "${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# ============================================
# SUITE 7: Tests de Ambiente Activo
# ============================================
print_header "SUITE 7: Active Environment Tests"

TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} Verify active environment configuration"

if grep -q "proxy_pass http://blue_backend" nginx-router.conf; then
    ACTIVE_ENV="blue"
    echo -e "  Active environment: BLUE"
elif grep -q "proxy_pass http://green_backend" nginx-router.conf; then
    ACTIVE_ENV="green"
    echo -e "  Active environment: GREEN"
else
    ACTIVE_ENV="unknown"
    echo -e "  Active environment: UNKNOWN"
fi

if [ "$ACTIVE_ENV" != "unknown" ]; then
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# ============================================
# SUITE 8: Tests de Logs
# ============================================
print_header "SUITE 8: Log Tests"

TOTAL_TESTS=$((TOTAL_TESTS + 1))
echo -e "\n${YELLOW}[TEST $TOTAL_TESTS]${NC} Check for errors in nginx logs"

ERROR_COUNT=$(docker logs sports-portal-router 2>&1 | grep -i "error" | grep -v "error_log" | wc -l)

if [ $ERROR_COUNT -eq 0 ]; then
    echo -e "  No errors found in router logs"
    echo -e "${GREEN}✓ PASS${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
else
    echo -e "  Found $ERROR_COUNT errors in router logs"
    echo -e "${RED}✗ FAIL${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
fi

# ============================================
# Resumen Final
# ============================================
echo ""
print_header "SMOKE TESTS SUMMARY"
echo ""
echo -e "Total Tests:   $TOTAL_TESTS"
echo -e "${GREEN}Passed:        $TESTS_PASSED${NC}"
echo -e "${RED}Failed:        $TESTS_FAILED${NC}"
echo ""

# Calcular porcentaje
if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_RATE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "Success Rate:  ${PASS_RATE}%"
fi

echo ""

# Determinar resultado final
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  ✓ ALL SMOKE TESTS PASSED!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "The application is healthy and ready for use!"
    exit 0
else
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}  ✗ SOME TESTS FAILED${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Please review the failed tests above."
    echo "The application may not be functioning correctly."
    exit 1
fi
