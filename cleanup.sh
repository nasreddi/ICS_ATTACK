#!/bin/bash

# OT/ICS Attack Laboratory - Cleanup Script
# Script de nettoyage pour arrêter et supprimer tous les services

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Main cleanup function
main() {
    echo "🧹 Nettoyage du laboratoire OT/ICS Attack"
    echo "=========================================="
    echo ""
    
    # Stop and remove containers
    print_status "Arrêt des services Docker..."
    if [ -f "docker-compose.yml" ]; then
        docker-compose down -v
        print_success "Services Docker arrêtés"
    else
        print_warning "docker-compose.yml non trouvé"
    fi
    
    # Remove unused images
    print_status "Suppression des images inutilisées..."
    docker image prune -f
    print_success "Images inutilisées supprimées"
    
    # Remove unused volumes
    print_status "Suppression des volumes orphelins..."
    docker volume prune -f
    print_success "Volumes orphelins supprimés"
    
    # Remove unused networks
    print_status "Suppression des réseaux orphelins..."
    docker network prune -f
    print_success "Réseaux orphelins supprimés"
    
    # Clean up logs (optional)
    if [ -d "logs" ]; then
        print_status "Nettoyage des logs..."
        find logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
        print_success "Logs anciens supprimés"
    fi
    
    # Clean up captures (optional)
    if [ -d "lab-config/wireshark/captures" ]; then
        print_status "Nettoyage des captures réseau..."
        find lab-config/wireshark/captures -name "*.pcap" -mtime +7 -delete 2>/dev/null || true
        print_success "Captures anciennes supprimées"
    fi
    
    print_success "Nettoyage terminé!"
    echo ""
    print_status "Pour redémarrer le laboratoire:"
    echo "  ./quick-start.sh"
    echo "  ou"
    echo "  ./lab-setup.sh"
}

# Run main function
main "$@"
