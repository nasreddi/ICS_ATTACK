# Guide de Configuration FUXA pour le Laboratoire OT/ICS

## 📋 Structure des Fichiers de Configuration FUXA

### 1. **fuxa_config.json** - Configuration Principale

Ce fichier contient la configuration globale de FUXA :

```json
{
  "server": {
    "port": 1881,           // Port du serveur web FUXA
    "ip": "192.168.1.20",   // Adresse IP du conteneur FUXA
    "hostname": "fuxa-scada",
    "protocol": "http"
  },
  "security": {
    "authentication": {
      "enabled": false,     // Authentification désactivée pour les tests
      "username": "admin",
      "password": "admin123"
    }
  },
  "modbus": {
    "connections": [
      {
        "id": "openplc-connection",
        "name": "OpenPLC Device",
        "type": "tcp",
        "host": "192.168.1.10",  // IP d'OpenPLC
        "port": 502,             // Port Modbus TCP
        "unit_id": 1,
        "timeout": 5000,
        "enabled": true
      }
    ]
  }
}
```

### 2. **Projet Dashboard** - ot-ics-dashboard.json

Ce fichier définit l'interface utilisateur et les connexions aux dispositifs :

#### **Section Devices (Dispositifs)**
```json
"devices": [
  {
    "id": "openplc-device",
    "name": "OpenPLC Device",
    "type": "modbus",
    "host": "192.168.1.10",
    "port": 502,
    "unit_id": 1,
    "tags": [
      {
        "id": "input1",
        "name": "Input 1",
        "address": "0.0",
        "type": "coil",
        "description": "Entrée digitale 1"
      }
    ]
  }
]
```

#### **Section Views (Vues)**
```json
"views": [
  {
    "id": "main-dashboard",
    "name": "Main Dashboard",
    "components": [
      {
        "id": "input1_button",
        "type": "button",
        "x": 100,
        "y": 150,
        "width": 120,
        "height": 60,
        "text": "Input 1",
        "device": "openplc-device",
        "tag": "input1",
        "action": "write"
      }
    ]
  }
]
```

## 🎯 Types de Composants FUXA

### **Composants de Contrôle :**
- **Button** : Boutons pour envoyer des commandes
- **Switch** : Interrupteurs on/off
- **Slider** : Curseurs pour valeurs analogiques
- **Input** : Champs de saisie

### **Composants d'Affichage :**
- **LED** : Voyants lumineux
- **Text** : Texte statique ou dynamique
- **Gauge** : Jauges circulaires
- **Chart** : Graphiques en temps réel
- **Table** : Tableaux de données

### **Composants de Monitoring :**
- **Alarm** : Affichage d'alarmes
- **Status** : Statut des connexions
- **Log** : Journal des événements

## 🔧 Configuration des Tags Modbus

### **Types de Tags :**
```json
{
  "coil": "0.0",              // Sortie digitale (0x0000-0xFFFF)
  "discrete_input": "0.0",    // Entrée digitale (0x0000-0xFFFF)
  "holding_register": "0.0",  // Registre de maintien (0x0000-0xFFFF)
  "input_register": "0.0"     // Registre d'entrée (0x0000-0xFFFF)
}
```

### **Exemple de Configuration Complète :**
```json
{
  "id": "temperature_sensor",
  "name": "Temperature Sensor",
  "address": "0.2",
  "type": "holding_register",
  "data_type": "int16",
  "scale": 0.1,
  "offset": 0,
  "unit": "°C",
  "min_value": 0,
  "max_value": 100,
  "description": "Capteur de température"
}
```

## 🚨 Configuration des Alarmes

```json
"alarms": [
  {
    "id": "high_temperature",
    "name": "High Temperature",
    "device": "openplc-device",
    "tag": "temperature",
    "condition": ">",
    "value": 80,
    "message": "Temperature is too high!",
    "severity": "high",
    "enabled": true,
    "actions": [
      {
        "type": "notification",
        "message": "Alert: High temperature detected"
      }
    ]
  }
]
```

## 📊 Configuration des Graphiques

```json
{
  "id": "temperature_chart",
  "type": "chart",
  "x": 100,
  "y": 400,
  "width": 400,
  "height": 200,
  "chart_type": "line",
  "device": "openplc-device",
  "tag": "temperature",
  "time_range": 3600,
  "update_interval": 1000,
  "y_axis": {
    "min": 0,
    "max": 100,
    "unit": "°C"
  }
}
```

## 🔗 Connexions Multi-Protocoles

### **Modbus TCP :**
```json
{
  "id": "modbus-connection",
  "type": "modbus",
  "host": "192.168.1.10",
  "port": 502,
  "unit_id": 1
}
```

### **IEC 104 :**
```json
{
  "id": "iec104-connection",
  "type": "iec104",
  "host": "192.168.1.40",
  "port": 2404,
  "asdu_address": 1
}
```

### **DNP3 :**
```json
{
  "id": "dnp3-connection",
  "type": "dnp3",
  "host": "192.168.1.50",
  "port": 20000,
  "outstation_id": 1
}
```

## 🎨 Personnalisation de l'Interface

### **Thèmes :**
```json
"ui": {
  "theme": "dark",           // dark, light, custom
  "primary_color": "#3498db",
  "secondary_color": "#2c3e50",
  "background_color": "#34495e",
  "text_color": "#ffffff"
}
```

### **Grille et Alignement :**
```json
"ui": {
  "show_grid": true,
  "snap_to_grid": true,
  "grid_size": 20,
  "auto_save": true,
  "auto_save_interval": 30000
}
```

## 📝 Scripts Personnalisés

```json
"scripts": [
  {
    "id": "attack_detection",
    "name": "Attack Detection Script",
    "language": "javascript",
    "code": "function detectAttack() {\n    // Logique de détection d'attaque\n    if (temperature > 90) {\n        triggerAlarm('High temperature attack detected');\n    }\n}",
    "enabled": true,
    "trigger": "on_data_change"
  }
]
```

## 🔄 Sauvegarde et Restauration

### **Configuration de Sauvegarde :**
```json
"projects": {
  "backup": {
    "enabled": true,
    "interval": 3600000,      // 1 heure
    "max_backups": 10,
    "backup_path": "/data/backups"
  }
}
```

## 🚀 Utilisation dans le Laboratoire

1. **Accéder à FUXA :** http://localhost:1881
2. **Importer le projet :** Charger `ot-ics-dashboard.json`
3. **Configurer les connexions :** Vérifier les adresses IP
4. **Tester les composants :** Interagir avec les boutons et voyants
5. **Lancer les attaques :** Utiliser les scripts d'attaque
6. **Observer les changements :** Monitorer les modifications en temps réel

## 🛠️ Dépannage

### **Problèmes de Connexion :**
- Vérifier les adresses IP des dispositifs
- Contrôler les ports et protocoles
- Vérifier les timeouts et intervalles de retry

### **Problèmes d'Affichage :**
- Vérifier les types de données des tags
- Contrôler les échelles et offsets
- Vérifier les plages min/max

### **Problèmes de Performance :**
- Réduire la fréquence de mise à jour
- Limiter le nombre de tags actifs
- Optimiser les requêtes de données
