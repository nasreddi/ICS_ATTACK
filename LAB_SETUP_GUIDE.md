# OT/ICS Attack Laboratory Setup Guide

## 🏭 Laboratoire de Test OT/ICS avec OpenPLC et FUXA

Ce guide vous permet de configurer un environnement de laboratoire complet pour tester les attaques OT/ICS sur des protocoles industriels réels.

## 📋 Architecture du Laboratoire

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Attacker      │    │   Network       │    │   Target        │
│   Machine       │    │   Switch        │    │   Systems       │
│                 │    │                 │    │                 │
│ • Kali Linux    │◄──►│ • Virtual       │◄──►│ • OpenPLC       │
│ • Attack Tools  │    │   Network       │    │ • FUXA SCADA    │
│ • Wireshark     │    │ • VLAN 100      │    │ • Modbus Slave  │
│ • Scapy         │    │ • 192.168.1.0/24│    │ • S7 Simulator  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ Composants du Laboratoire

### 1. **OpenPLC Runtime**
- **Rôle** : Simulateur de PLC avec support Modbus TCP
- **Fonctionnalités** : 
  - Modbus TCP Server (port 502)
  - Variables I/O configurables
  - Interface web de monitoring
  - Support des registres coils et holding

### 2. **FUXA SCADA**
- **Rôle** : Interface SCADA/HMI pour visualisation
- **Fonctionnalités** :
  - Connexion Modbus TCP vers OpenPLC
  - Dashboards en temps réel
  - Historique des données
  - Alarmes et événements

### 3. **S7-PLCSIM Advanced** (Optionnel)
- **Rôle** : Simulateur Siemens S7 pour tests S7Comm/S7CommPlus
- **Fonctionnalités** :
  - Simulation S7-1200/1500
  - Support S7CommPlus
  - Interface TIA Portal

### 4. **Modbus Slave Simulator**
- **Rôle** : Simulateur Modbus pour tests avancés
- **Fonctionnalités** :
  - Multiple slaves
  - Configuration flexible
  - Logging des communications

## 🚀 Installation Rapide avec Docker

### Prérequis
- Docker et Docker Compose
- 8GB RAM minimum
- 20GB espace disque

### Configuration Réseau
```bash
# Créer un réseau Docker pour le lab
docker network create --driver bridge --subnet=192.168.1.0/24 ot-ics-lab
```

### Services Docker

#### 1. OpenPLC Runtime
```yaml
openplc:
  image: thiagoralves/openplc-runtime:latest
  container_name: openplc-runtime
  ports:
    - "8080:8080"  # Web interface
    - "502:502"    # Modbus TCP
  networks:
    - ot-ics-lab
  environment:
    - PLC_IP=192.168.1.10
  volumes:
    - ./openplc-config:/opt/openplc
```

#### 2. FUXA SCADA
```yaml
fuxa:
  image: frangoteam/fuxa:latest
  container_name: fuxa-scada
  ports:
    - "1881:1881"  # Web interface
  networks:
    - ot-ics-lab
  environment:
    - FUXA_IP=192.168.1.20
  volumes:
    - ./fuxa-projects:/data
```

#### 3. Modbus Slave Simulator
```yaml
modbus-slave:
  image: oitc/modbus-slave:latest
  container_name: modbus-slave
  ports:
    - "503:502"    # Modbus TCP
  networks:
    - ot-ics-lab
  environment:
    - SLAVE_IP=192.168.1.30
```

## 📊 Configuration des Protocoles

### Modbus TCP Configuration
```python
# Configuration pour OpenPLC
MODBUS_CONFIG = {
    "ip_address": "192.168.1.10",
    "port": 502,
    "unit_id": 1,
    "registers": {
        "coils": range(0, 100),           # 0x0000-0x0063
        "discrete_inputs": range(0, 100), # 0x0000-0x0063
        "holding_registers": range(0, 100), # 0x0000-0x0063
        "input_registers": range(0, 100)   # 0x0000-0x0063
    }
}
```

### S7Comm Configuration (avec S7-PLCSIM)
```python
S7COMM_CONFIG = {
    "ip_address": "192.168.1.40",
    "port": 102,
    "rack": 0,
    "slot": 1,
    "db_blocks": {
        "DB1": {"size": 100, "type": "data"},
        "DB2": {"size": 50, "type": "data"}
    }
}
```

## 🎯 Scénarios de Test

### Scénario 1 : Attaque Modbus TCP
1. **Setup** : OpenPLC + FUXA connectés
2. **Objectif** : Modifier des valeurs de registres
3. **Attaque** : `OT_ICS_ATTACK_MODBUS.py`
4. **Validation** : Observer les changements dans FUXA

### Scénario 2 : Attaque S7Comm
1. **Setup** : S7-PLCSIM Advanced + TIA Portal
2. **Objectif** : Manipuler des blocs de données
3. **Attaque** : `OT_ICS_ATTACK_S7COMM.py`
4. **Validation** : Vérifier les modifications dans TIA Portal

### Scénario 3 : Attaque IEC 104
1. **Setup** : Simulateur IEC 104 + Client SCADA
2. **Objectif** : Injecter des commandes de télécommande
3. **Attaque** : `OT_ICS_ATTACK_IEC104.py`
4. **Validation** : Observer les commandes dans le client

## 🔧 Outils de Monitoring

### Wireshark
```bash
# Capturer le trafic Modbus
wireshark -i eth0 -f "port 502"

# Capturer le trafic S7Comm
wireshark -f "port 102"
```

### Modbus Poll (Windows)
- Client Modbus pour tests manuels
- Connexion directe aux slaves
- Monitoring en temps réel

### S7Comm Browser
- Outil spécialisé pour S7Comm
- Analyse des paquets S7
- Débogage des communications

## 📈 Métriques de Test

### Avant Attaque
- Temps de réponse normal
- Valeurs par défaut des registres
- État des connexions

### Pendant Attaque
- Détection des paquets malveillants
- Temps de réponse dégradé
- Modifications des valeurs

### Après Attaque
- Impact sur le système
- Récupération automatique
- Logs d'événements

## 🛡️ Sécurité du Laboratoire

### Isolation Réseau
```bash
# Créer un VLAN isolé
vconfig add eth0 100
ifconfig eth0.100 192.168.1.1 netmask 255.255.255.0
```

### Monitoring
- Logs centralisés avec ELK Stack
- Alertes automatiques
- Sauvegarde des configurations

### Sauvegarde
```bash
# Sauvegarder les configurations
tar -czf lab-backup-$(date +%Y%m%d).tar.gz \
    ./openplc-config \
    ./fuxa-projects \
    ./docker-compose.yml
```

## 🚨 Avertissements

⚠️ **IMPORTANT** : Ce laboratoire est destiné uniquement à des fins éducatives et de recherche en cybersécurité. Ne jamais utiliser ces outils sur des systèmes de production sans autorisation explicite.

## 📚 Ressources Supplémentaires

- [OpenPLC Documentation](https://openplcproject.com/)
- [FUXA Documentation](https://frangoteam.github.io/FUXA/)
- [Modbus Protocol Specification](https://modbus.org/docs/Modbus_Application_Protocol_V1_1b3.pdf)
- [IEC 61850 Standard](https://www.iec.ch/standardsdev/61850.htm)
