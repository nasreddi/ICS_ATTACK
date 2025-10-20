# 🏭 OT/ICS Attack Laboratory

Un laboratoire complet pour tester et démontrer les attaques sur les systèmes de contrôle industriels (ICS/SCADA) avec des protocoles réels.

## 🎯 Vue d'ensemble

Ce projet fournit un environnement de laboratoire sécurisé pour :
- **Tester les attaques** sur les protocoles industriels (Modbus, S7Comm, IEC 104, DNP3)
- **Simuler des systèmes SCADA** avec des composants réels
- **Analyser le trafic réseau** avec Wireshark
- **Monitorer les performances** avec Grafana et Prometheus
- **Collecter et analyser les logs** avec ELK Stack

## 🚀 Démarrage Rapide sur Kali Linux

### Prérequis
- **Kali Linux** (recommandé) ou Ubuntu 20.04+
- **8GB RAM** minimum (16GB recommandé)
- **20GB espace disque** libre
- **Docker** et **Docker Compose**
- **Python 3.8+**

### Installation Automatique

```bash
# 1. Cloner le projet
git clone https://github.com/your-repo/ICS_ATTACK.git
cd ICS_ATTACK

# 2. Vérifier les prérequis
./check-prerequisites.sh

# 3. Configurer le laboratoire
./lab-setup.sh

# 4. Démarrer les services
docker-compose up -d
```

### Installation Manuelle

```bash
# 1. Installer Docker
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# 2. Installer Python et dépendances
sudo apt install -y python3 python3-pip python3-venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# 3. Configurer l'environnement
cp env.example .env
# Éditer .env selon vos besoins

# 4. Démarrer le laboratoire
docker-compose up -d
```

## 🌐 Services Disponibles

| Service | URL | Description |
|---------|-----|-------------|
| **Modbus Simulator** | `192.168.1.10:502` | Simulateur Modbus TCP |
| **FUXA SCADA** | http://localhost:1881 | Interface SCADA/HMI |
| **OpenPLC** | http://localhost:8080 | Runtime PLC avec Modbus |
| **Wireshark** | http://localhost:3000 | Capture et analyse réseau |
| **Grafana** | http://localhost:3001 | Dashboards de monitoring |
| **Prometheus** | http://localhost:9090 | Métriques système |
| **InfluxDB** | http://localhost:8086 | Base de données temporelle |
| **Elasticsearch** | http://localhost:9200 | Moteur de recherche |
| **Kibana** | http://localhost:5601 | Visualisation des logs |

### Identifiants par défaut
- **Grafana**: `admin` / `admin123`
- **InfluxDB**: `admin` / `admin123`

## 🎯 Scripts d'Attaque

### Modbus TCP Attack
```bash
# Activer l'environnement Python
source .venv/bin/activate

# Lancer l'attaque Modbus
python3 OT_ICS_ATTACK_MODBUS.py
```

### S7Comm Attack
```bash
python3 OT_ICS_ATTACK_S7COMM.py
```

### IEC 104 Attack
```bash
python3 OT_ICS_ATTACK_IEC104.py
```

### DNP3 Attack
```bash
python3 OT_ICS_ATTACK_DNP3.py
```

## 🧪 Tests Automatisés

```bash
# Lancer tous les tests
python3 test-scenarios.py

# Tests individuels
python3 test-scenarios.py --test modbus
python3 test-scenarios.py --test s7comm
python3 test-scenarios.py --test iec104
python3 test-scenarios.py --test dnp3
```

## 📊 Monitoring et Logs

### Grafana Dashboards
- **Système**: Métriques CPU, RAM, disque
- **Réseau**: Trafic, connexions, erreurs
- **Services**: Statut des conteneurs Docker
- **Attaques**: Détection d'anomalies

### Logs et Captures
```bash
# Voir les logs d'attaques
tail -f logs/attacks/attack.log

# Voir les captures réseau
ls lab-config/wireshark/captures/

# Voir les logs des services
docker-compose logs -f
```

## 🔧 Configuration Avancée

### Variables d'environnement
```bash
# Copier le fichier de configuration
cp env.example .env

# Éditer la configuration
nano .env
```

### Réseau personnalisé
```yaml
# docker-compose.override.yml
version: '3.8'
services:
  modbus-simulator:
    networks:
      ot-ics-lab:
        ipv4_address: 192.168.100.10
```

### Ajout de nouveaux simulateurs
```yaml
# Ajouter dans docker-compose.yml
  new-simulator:
    image: your-image:latest
    container_name: new-simulator
    ports:
      - "PORT:PORT"
    networks:
      ot-ics-lab:
        ipv4_address: 192.168.1.X
```

## 🛠️ Développement

### Structure du projet
```
ICS_ATTACK/
├── lab-config/           # Configurations des services
├── logs/                 # Logs et captures
├── OT_ICS_ATTACK_*.py   # Scripts d'attaque
├── test-scenarios.py    # Tests automatisés
├── docker-compose.yml   # Services Docker
├── requirements.txt     # Dépendances Python
└── README.md           # Documentation
```

### Ajout de nouveaux protocoles
1. Créer le script d'attaque `OT_ICS_ATTACK_NEWPROTOCOL.py`
2. Ajouter le simulateur dans `docker-compose.yml`
3. Mettre à jour `test-scenarios.py`
4. Documenter dans le README

### Tests personnalisés
```python
# test-custom.py
from test_scenarios import OTICSTestLab

lab = OTICSTestLab()

# Test personnalisé
def custom_test():
    print("Test personnalisé...")
    # Votre logique de test ici

if __name__ == "__main__":
    custom_test()
```

## 🚨 Sécurité et Légalité

### ⚠️ AVERTISSEMENT IMPORTANT
- **Utilisation uniquement** sur des réseaux que vous possédez
- **Autorisation explicite** requise pour tous les tests
- **Environnement isolé** recommandé
- **Respect des lois** locales et internationales

### Bonnes pratiques
- Utiliser un réseau isolé (VLAN dédié)
- Sauvegarder les configurations
- Documenter tous les tests
- Nettoyer après utilisation

## 🔍 Dépannage

### Services qui ne démarrent pas
```bash
# Vérifier les logs
docker-compose logs SERVICE_NAME

# Redémarrer un service
docker-compose restart SERVICE_NAME

# Reconstruire les images
docker-compose up --build
```

### Problèmes de réseau
```bash
# Vérifier le réseau Docker
docker network ls
docker network inspect ot-ics-lab

# Tester la connectivité
docker exec -it modbus-simulator ping 192.168.1.20
```

### Problèmes Python
```bash
# Réinstaller l'environnement virtuel
rm -rf .venv
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## 📚 Ressources et Documentation

### Documentation des protocoles
- [Modbus Protocol](https://modbus.org/docs/Modbus_Application_Protocol_V1_1b3.pdf)
- [IEC 61850 Standard](https://www.iec.ch/standardsdev/61850.htm)
- [DNP3 Specification](https://www.dnp.org/About/Overview-of-DNP3.aspx)

### Outils et simulateurs
- [FUXA Documentation](https://frangoteam.github.io/FUXA/)
- [OpenPLC Project](https://openplcproject.com/)
- [Wireshark User Guide](https://www.wireshark.org/docs/wsug_html/)

### Formation et certification
- [SANS ICS Security](https://www.sans.org/cyber-security-courses/industrial-control-systems-security/)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)

## 🤝 Contribution

### Comment contribuer
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

### Guidelines
- Code propre et commenté
- Tests pour les nouvelles fonctionnalités
- Documentation mise à jour
- Respect des bonnes pratiques de sécurité

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 🆘 Support

### Issues et bugs
- Ouvrir une issue sur GitHub
- Fournir les logs d'erreur
- Décrire les étapes de reproduction

### Questions et discussions
- Utiliser les GitHub Discussions
- Consulter la documentation
- Participer à la communauté

## 🏆 Remerciements

- **FUXA Team** pour l'interface SCADA
- **OpenPLC Project** pour le runtime PLC
- **Prometheus** et **Grafana** pour le monitoring
- **Docker** pour la containerisation
- **Kali Linux** pour les outils de sécurité

---

**⚠️ DISCLAIMER**: Ce projet est destiné uniquement à des fins éducatives et de recherche en cybersécurité. Les utilisateurs sont responsables de l'utilisation légale et éthique de ces outils.