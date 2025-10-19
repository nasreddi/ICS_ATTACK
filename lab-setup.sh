#!/bin/bash

# OT/ICS Attack Laboratory Setup Script
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
    
    # Vérifier Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker n'est pas installé. Veuillez installer Docker d'abord."
        exit 1
    fi
    
    # Vérifier Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose n'est pas installé. Veuillez installer Docker Compose d'abord."
        exit 1
    fi
    
    # Vérifier Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 n'est pas installé. Veuillez installer Python 3 d'abord."
        exit 1
    fi
    
    # Vérifier pip
    if ! command -v pip3 &> /dev/null; then
        print_error "pip3 n'est pas installé. Veuillez installer pip3 d'abord."
        exit 1
    fi
    
    print_success "Tous les prérequis sont satisfaits"
}

# Créer la structure de répertoires
create_directories() {
    print_status "Création de la structure de répertoires..."
    
    mkdir -p lab-config/{openplc,fuxa,modbus-slave,iec104,dnp3,wireshark,elasticsearch,kibana,logstash,grafana,influxdb}
    mkdir -p lab-config/openplc/{programs,config}
    mkdir -p lab-config/fuxa/{projects,assets}
    mkdir -p lab-config/modbus-slave/{config,data}
    mkdir -p lab-config/iec104/{config,data}
    mkdir -p lab-config/dnp3/{config,data}
    mkdir -p lab-config/wireshark/{captures,config}
    mkdir -p lab-config/elasticsearch/{data,logs}
    mkdir -p lab-config/kibana/{data,config}
    mkdir -p lab-config/logstash/{pipeline,config}
    mkdir -p lab-config/grafana/{data,config}
    mkdir -p lab-config/influxdb/{data,config}
    
    print_success "Structure de répertoires créée"
}

# Installer les dépendances Python
install_python_dependencies() {
    print_status "Installation des dépendances Python..."
    
    pip3 install scapy python-nmap psutil requests
    
    print_success "Dépendances Python installées"
}

# Créer les fichiers de configuration
create_config_files() {
    print_status "Création des fichiers de configuration..."
    
    # Configuration OpenPLC
    cat > lab-config/openplc/config/plc_config.json << EOF
{
    "plc_name": "TestPLC",
    "plc_ip": "192.168.1.10",
    "modbus_port": 502,
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

    # Configuration Modbus Slave
    cat > lab-config/modbus-slave/config/slave_config.json << EOF
{
    "slave_id": 1,
    "ip": "192.168.1.30",
    "port": 502,
    "registers": {
        "coils": 100,
        "discrete_inputs": 100,
        "holding_registers": 100,
        "input_registers": 100
    }
}
EOF

    # Configuration IEC 104
    cat > lab-config/iec104/config/iec104_config.json << EOF
{
    "server": {
        "ip": "192.168.1.40",
        "port": 2404
    },
    "asdu": {
        "address": 1,
        "max_objects": 100
    }
}
EOF

    # Configuration DNP3
    cat > lab-config/dnp3/config/dnp3_config.json << EOF
{
    "outstation": {
        "ip": "192.168.1.50",
        "port": 20000,
        "outstation_id": 1
    },
    "objects": {
        "binary_inputs": 100,
        "binary_outputs": 100,
        "analog_inputs": 100,
        "analog_outputs": 100
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
    echo "OpenPLC Runtime:    http://localhost:8080"
    echo "FUXA SCADA:         http://localhost:1881"
    echo "Elasticsearch:      http://localhost:9200"
    echo "Kibana:             http://localhost:5601"
    echo "Grafana:            http://localhost:3001 (admin/admin123)"
    echo "Wireshark:          http://localhost:3000"
    echo ""
    echo "🔧 Adresses IP des Services"
    echo "==========================="
    echo "OpenPLC:            192.168.1.10:502"
    echo "FUXA:               192.168.1.20:1881"
    echo "Modbus Slave:       192.168.1.30:503"
    echo "IEC 104 Simulator:  192.168.1.40:2404"
    echo "DNP3 Simulator:     192.168.1.50:20000"
    echo ""
    echo "🎯 Commandes Utiles"
    echo "==================="
    echo "Arrêter le lab:     docker-compose down"
    echo "Redémarrer:         docker-compose restart"
    echo "Voir les logs:      docker-compose logs -f"
    echo "Statut des services: docker-compose ps"
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
