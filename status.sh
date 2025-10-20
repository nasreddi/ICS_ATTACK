#!/bin/bash

# OT/ICS Attack Laboratory - Status Check Script
# Script de vérification du statut des services

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                OT/ICS Attack Laboratory                     ║"
    echo "║                    Status Check                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check Docker services
check_docker_services() {
    print_status "Vérification des services Docker..."
    
    if [ -f "docker-compose.yml" ]; then
        echo ""
        echo "📦 Services Docker:"
        echo "=================="
        docker-compose ps
        echo ""
    else
        print_warning "docker-compose.yml non trouvé"
    fi
}

# Check service health
check_service_health() {
    print_status "Vérification de la santé des services..."
    
    SERVICES=(
        "Modbus Simulator:localhost:502"
        "FUXA SCADA:localhost:1881"
        "OpenPLC:localhost:8080"
        "Wireshark:localhost:3000"
        "Grafana:localhost:3001"
        "Prometheus:localhost:9090"
        "Node Exporter:localhost:9100"
        "InfluxDB:localhost:8086"
        "Elasticsearch:localhost:9200"
        "Kibana:localhost:5601"
    )
    
    echo ""
    echo "🏥 Santé des services:"
    echo "====================="
    
    for service in "${SERVICES[@]}"; do
        name=$(echo $service | cut -d: -f1)
        host=$(echo $service | cut -d: -f2)
        port=$(echo $service | cut -d: -f3)
        
        if nc -z $host $port 2>/dev/null; then
            print_success "$name: ✅ Accessible"
        else
            print_error "$name: ❌ Non accessible"
        fi
    done
}

# Check network connectivity
check_network() {
    print_status "Vérification de la connectivité réseau..."
    
    echo ""
    echo "🌐 Connectivité réseau:"
    echo "======================"
    
    # Check Docker network
    if docker network ls | grep -q "ot-ics-lab"; then
        print_success "Réseau Docker 'ot-ics-lab': ✅ Actif"
    else
        print_error "Réseau Docker 'ot-ics-lab': ❌ Non trouvé"
    fi
    
    # Check network interfaces
    if ip link show | grep -q "docker0"; then
        print_success "Interface Docker: ✅ Actif"
    else
        print_warning "Interface Docker: ⚠️ Non trouvé"
    fi
}

# Check resources
check_resources() {
    print_status "Vérification des ressources système..."
    
    echo ""
    echo "💻 Ressources système:"
    echo "====================="
    
    # CPU usage
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    echo "CPU Usage: ${cpu_usage}%"
    
    # Memory usage
    memory_info=$(free -h | grep "Mem:")
    echo "Memory: $memory_info"
    
    # Disk usage
    disk_info=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    echo "Disk Usage: $disk_info"
    
    # Docker stats
    if docker ps -q | wc -l | grep -q "[1-9]"; then
        echo ""
        echo "🐳 Statistiques Docker:"
        echo "======================="
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
    fi
}

# Check logs
check_logs() {
    print_status "Vérification des logs récents..."
    
    echo ""
    echo "📋 Logs récents:"
    echo "================"
    
    if [ -d "logs" ]; then
        echo "Logs d'attaques:"
        ls -la logs/attacks/ 2>/dev/null || echo "Aucun log d'attaque"
        
        echo ""
        echo "Logs de monitoring:"
        ls -la logs/monitoring/ 2>/dev/null || echo "Aucun log de monitoring"
    else
        print_warning "Répertoire logs non trouvé"
    fi
}

# Main function
main() {
    print_header
    
    check_docker_services
    check_service_health
    check_network
    check_resources
    check_logs
    
    echo ""
    print_success "Vérification terminée!"
    echo ""
    print_status "Commandes utiles:"
    echo "  docker-compose logs -f [service]  # Voir les logs d'un service"
    echo "  docker-compose restart [service]  # Redémarrer un service"
    echo "  docker-compose down              # Arrêter tous les services"
    echo "  ./cleanup.sh                     # Nettoyer complètement"
}

# Run main function
main "$@"
