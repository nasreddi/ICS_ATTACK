#!/bin/bash

# OT/ICS Attack Laboratory Setup Script for Kali Linux
# Ce script configure automatiquement l'environnement de laboratoire

set -e

echo "🏭 Configuration du Laboratoire OT/ICS Attack"
echo "=============================================="

# Couleurs pour les messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher les messages colorés
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

# Vérifier les prérequis
check_prerequisites() {
    print_status "Vérification des prérequis..."
    
    # Vérifier si le script de vérification existe
    if [ -f "check-prerequisites.sh" ]; then
        print_status "Exécution du script de vérification des prérequis..."
        ./check-prerequisites.sh
    else
        print_warning "Script de vérification des prérequis non trouvé, vérification manuelle..."
        
        # Vérifier Docker
        if ! command -v docker &> /dev/null; then
            print_error "Docker n'est pas installé. Veuillez installer Docker d'abord."
            print_status "Installation de Docker..."
            sudo apt update && sudo apt install -y docker.io docker-compose
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo usermod -aG docker $USER
        fi
        
        # Vérifier Docker Compose
        if ! command -v docker-compose &> /dev/null; then
            print_error "Docker Compose n'est pas installé. Veuillez installer Docker Compose d'abord."
            print_status "Installation de Docker Compose..."
            sudo apt install -y docker-compose
        fi
        
        # Vérifier Python
        if ! command -v python3 &> /dev/null; then
            print_error "Python 3 n'est pas installé. Veuillez installer Python 3 d'abord."
            print_status "Installation de Python 3..."
            sudo apt install -y python3 python3-pip python3-venv
        fi
        
        # Vérifier pip
        if ! command -v pip3 &> /dev/null; then
            print_error "pip3 n'est pas installé. Veuillez installer pip3 d'abord."
            print_status "Installation de pip3..."
            sudo apt install -y python3-pip
        fi
    fi
    
    print_success "Tous les prérequis sont satisfaits"
}

# Créer la structure de répertoires
create_directories() {
    print_status "Création de la structure de répertoires..."
    
    mkdir -p lab-config/{modbus,fuxa,openplc,wireshark,elasticsearch,kibana,grafana,prometheus,influxdb,logs}
    mkdir -p lab-config/modbus/{config,data}
    mkdir -p lab-config/fuxa/{projects,assets,config}
    mkdir -p lab-config/openplc/{programs,config}
    mkdir -p lab-config/wireshark/{captures,config}
    mkdir -p lab-config/elasticsearch/{data,logs}
    mkdir -p lab-config/kibana/{data,config}
    mkdir -p lab-config/grafana/{data,config,dashboards}
    mkdir -p lab-config/prometheus/{config,rules}
    mkdir -p lab-config/influxdb/{data,config}
    mkdir -p logs/{attacks,monitoring,backups}
    
    print_success "Structure de répertoires créée"
}

# Installer les dépendances Python
install_python_dependencies() {
    print_status "Installation des dépendances Python..."
    
    # Créer un environnement virtuel Python
    if [ ! -d ".venv" ]; then
        print_status "Création de l'environnement virtuel Python..."
        python3 -m venv .venv
    fi
    
    # Activer l'environnement virtuel
    print_status "Activation de l'environnement virtuel..."
    source .venv/bin/activate
    
    # Installer les dépendances dans l'environnement virtuel
    print_status "Installation des packages Python..."
    pip install --upgrade pip
    
    # Installer depuis requirements.txt si disponible
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
    else
        # Installation manuelle des packages essentiels
        pip install scapy python-nmap psutil requests colorama rich
    fi
    
    print_success "Dépendances Python installées dans l'environnement virtuel"
}

# Créer les fichiers de configuration
create_config_files() {
    print_status "Création des fichiers de configuration..."
    
    # Configuration Prometheus
    cat > lab-config/prometheus/config/prometheus.yml << EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "rules/*.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
  
  - job_name: 'docker'
    static_configs:
      - targets: ['host.docker.internal:9323']
EOF

    # Configuration Grafana
    cat > lab-config/grafana/config/grafana.ini << EOF
[server]
http_port = 3000
domain = localhost

[security]
admin_user = admin
admin_password = admin123

[database]
type = sqlite3
path = grafana.db

[log]
mode = console
level = info
EOF

    # Configuration Modbus
    cat > lab-config/modbus/config/modbus_config.json << EOF
{
    "slave_id": 1,
    "ip": "192.168.1.10",
    "port": 502,
    "registers": {
        "coils": 100,
        "discrete_inputs": 100,
        "holding_registers": 100,
        "input_registers": 100
    }
}
EOF

    # Configuration OpenPLC
    cat > lab-config/openplc/config/plc_config.json << EOF
{
    "plc_name": "TestPLC",
    "plc_ip": "192.168.1.30",
    "modbus_port": 5020,
    "web_port": 8080,
    "registers": {
        "coils": 100,
        "discrete_inputs": 100,
        "holding_registers": 100,
        "input_registers": 100
    }
}
EOF

    # Configuration FUXA
    cat > lab-config/fuxa/config/fuxa_config.json << EOF
{
    "server": {
        "port": 1881,
        "ip": "192.168.1.20"
    },
    "modbus": {
        "host": "192.168.1.10",
        "port": 502,
        "unit_id": 1
    }
}
EOF

    print_success "Fichiers de configuration créés"
}

# Créer un programme OpenPLC de test
create_test_program() {
    print_status "Création d'un programme OpenPLC de test..."
    
    cat > lab-config/openplc/programs/test_program.st << EOF
PROGRAM TestProgram
VAR
    Input1 : BOOL;
    Input2 : BOOL;
    Output1 : BOOL;
    Output2 : BOOL;
    Counter : INT;
    Temperature : REAL;
END_VAR

// Logique de test simple
Input1 := %IX0.0;
Input2 := %IX0.1;

// Contrôle des sorties
Output1 := Input1 AND Input2;
Output2 := Input1 OR Input2;

// Compteur
IF Input1 THEN
    Counter := Counter + 1;
END_IF;

// Simulation de température
Temperature := 20.0 + (Counter MOD 10);

// Assignation aux sorties
%QX0.0 := Output1;
%QX0.1 := Output2;
%QW0 := Counter;
%QW2 := INT_TO_WORD(REAL_TO_INT(Temperature * 10));

END_PROGRAM
EOF

    print_success "Programme OpenPLC de test créé"
}

# Créer un projet FUXA de test
create_fuxa_project() {
    print_status "Création d'un projet FUXA de test..."
    
    cat > lab-config/fuxa/projects/test_project.json << EOF
{
    "name": "OT/ICS Test Project",
    "version": "1.0.0",
    "devices": [
        {
            "id": "modbus-device",
            "name": "OpenPLC Device",
            "type": "modbus",
            "host": "192.168.1.10",
            "port": 502,
            "unit_id": 1
        }
    ],
    "views": [
        {
            "id": "main-view",
            "name": "Main Dashboard",
            "components": [
                {
                    "id": "input1",
                    "type": "button",
                    "x": 100,
                    "y": 100,
                    "width": 100,
                    "height": 50,
                    "text": "Input 1",
                    "device": "modbus-device",
                    "address": "0.0"
                },
                {
                    "id": "output1",
                    "type": "led",
                    "x": 300,
                    "y": 100,
                    "width": 50,
                    "height": 50,
                    "color": "green",
                    "device": "modbus-device",
                    "address": "0.0"
                },
                {
                    "id": "counter",
                    "type": "text",
                    "x": 100,
                    "y": 200,
                    "width": 200,
                    "height": 50,
                    "text": "Counter: ",
                    "device": "modbus-device",
                    "address": "0.0"
                }
            ]
        }
    ]
}
EOF

    print_success "Projet FUXA de test créé"
}

# Démarrer les services
start_services() {
    print_status "Démarrage des services Docker..."
    
    # Arrêter les services existants
    docker-compose down 2>/dev/null || true
    
    # Construire et démarrer les services
    docker-compose up -d --build
    
    print_success "Services Docker démarrés"
}

# Vérifier le statut des services
check_services() {
    print_status "Vérification du statut des services..."
    
    sleep 10  # Attendre que les services démarrent
    
    # Vérifier OpenPLC
    if curl -s http://localhost:8080 > /dev/null; then
        print_success "OpenPLC est accessible sur http://localhost:8080"
    else
        print_warning "OpenPLC n'est pas encore accessible"
    fi
    
    # Vérifier FUXA
    if curl -s http://localhost:1881 > /dev/null; then
        print_success "FUXA est accessible sur http://localhost:1881"
    else
        print_warning "FUXA n'est pas encore accessible"
    fi
    
    # Vérifier Elasticsearch
    if curl -s http://localhost:9200 > /dev/null; then
        print_success "Elasticsearch est accessible sur http://localhost:9200"
    else
        print_warning "Elasticsearch n'est pas encore accessible"
    fi
    
    # Vérifier Kibana
    if curl -s http://localhost:5601 > /dev/null; then
        print_success "Kibana est accessible sur http://localhost:5601"
    else
        print_warning "Kibana n'est pas encore accessible"
    fi
    
    # Vérifier Grafana
    if curl -s http://localhost:3001 > /dev/null; then
        print_success "Grafana est accessible sur http://localhost:3001"
    else
        print_warning "Grafana n'est pas encore accessible"
    fi
}

# Afficher les informations de connexion
show_connection_info() {
    echo ""
    echo "🌐 Informations de Connexion"
    echo "============================"
    echo "Modbus Simulator:   http://localhost:502 (192.168.1.10:502)"
    echo "FUXA SCADA:         http://localhost:1881"
    echo "OpenPLC Runtime:    http://localhost:8080"
    echo "Wireshark:          http://localhost:3000"
    echo "Grafana:            http://localhost:3001 (admin/admin123)"
    echo "Prometheus:         http://localhost:9090"
    echo "Node Exporter:      http://localhost:9100"
    echo "InfluxDB:           http://localhost:8086 (admin/admin123)"
    echo "Elasticsearch:      http://localhost:9200"
    echo "Kibana:             http://localhost:5601"
    echo ""
    echo "🔧 Adresses IP des Services"
    echo "==========================="
    echo "Modbus Simulator:   192.168.1.10:502"
    echo "FUXA:               192.168.1.20:1881"
    echo "OpenPLC:            192.168.1.30:5020"
    echo "Wireshark:          192.168.1.40:3000"
    echo "Grafana:            192.168.1.50:3001"
    echo "Prometheus:         192.168.1.60:9090"
    echo "InfluxDB:           192.168.1.70:8086"
    echo "Elasticsearch:      192.168.1.80:9200"
    echo "Kibana:             192.168.1.90:5601"
    echo ""
    echo "🎯 Commandes Utiles"
    echo "==================="
    echo "Arrêter le lab:     docker-compose down"
    echo "Redémarrer:         docker-compose restart"
    echo "Voir les logs:      docker-compose logs -f"
    echo "Statut des services: docker-compose ps"
    echo "Nettoyer:           docker-compose down -v"
    echo ""
    echo "🐍 Environnement Python"
    echo "======================="
    echo "Activer l'env virtuel: source .venv/bin/activate"
    echo "Désactiver l'env virtuel: deactivate"
    echo "Lancer les tests:     python3 test-scenarios.py"
    echo "Lancer les attaques:  python3 OT_ICS_ATTACK_*.py"
    echo ""
    echo "📊 Monitoring et Logs"
    echo "====================="
    echo "Logs d'attaques:     ./logs/attacks/"
    echo "Logs de monitoring:  ./logs/monitoring/"
    echo "Sauvegardes:         ./logs/backups/"
    echo ""
}

# Fonction principale
main() {
    echo "Démarrage de la configuration du laboratoire OT/ICS..."
    echo ""
    
    check_prerequisites
    create_directories
    install_python_dependencies
    create_config_files
    create_test_program
    create_fuxa_project
    start_services
    check_services
    show_connection_info
    
    print_success "Configuration du laboratoire terminée avec succès!"
    print_warning "Veuillez attendre quelques minutes que tous les services soient complètement démarrés."
}

# Exécuter le script principal
main "$@"
