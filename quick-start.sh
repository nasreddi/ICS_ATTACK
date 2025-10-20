#!/bin/bash

# OT/ICS Attack Laboratory - Quick Start Script
# Script de démarrage rapide pour Kali Linux

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
    echo "║                    Quick Start Guide                        ║"
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

# Main function
main() {
    print_header
    
    echo "🚀 Démarrage rapide du laboratoire OT/ICS Attack"
    echo ""
    
    # Check if we're in the right directory
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found. Please run this script from the project root."
        exit 1
    fi
    
    # Check prerequisites
    print_status "Vérification des prérequis..."
    if [ -f "check-prerequisites.sh" ]; then
        ./check-prerequisites.sh
    else
        print_warning "Script de vérification des prérequis non trouvé"
    fi
    
    # Setup environment
    print_status "Configuration de l'environnement..."
    if [ -f "lab-setup.sh" ]; then
        ./lab-setup.sh
    else
        print_warning "Script de configuration non trouvé"
    fi
    
    # Start services
    print_status "Démarrage des services Docker..."
    docker-compose up -d
    
    # Wait for services to start
    print_status "Attente du démarrage des services (30 secondes)..."
    sleep 30
    
    # Check services
    print_status "Vérification du statut des services..."
    docker-compose ps
    
    # Show connection info
    echo ""
    echo "🌐 Services disponibles:"
    echo "======================="
    echo "Modbus Simulator:   http://localhost:502"
    echo "FUXA SCADA:         http://localhost:1881"
    echo "OpenPLC:            http://localhost:8080"
    echo "Wireshark:          http://localhost:3000"
    echo "Grafana:            http://localhost:3001 (admin/admin123)"
    echo "Prometheus:         http://localhost:9090"
    echo "InfluxDB:           http://localhost:8086 (admin/admin123)"
    echo "Elasticsearch:      http://localhost:9200"
    echo "Kibana:             http://localhost:5601"
    echo ""
    
    print_success "Laboratoire démarré avec succès!"
    print_status "Vous pouvez maintenant lancer les attaques avec:"
    echo "  python3 OT_ICS_ATTACK_MODBUS.py"
    echo "  python3 OT_ICS_ATTACK_S7COMM.py"
    echo "  python3 OT_ICS_ATTACK_IEC104.py"
    echo "  python3 OT_ICS_ATTACK_DNP3.py"
    echo ""
    print_status "Pour arrêter le laboratoire: docker-compose down"
}

# Run main function
main "$@"
