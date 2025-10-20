# Guide du Système SCADA Électrique Complet

## 🏭 Architecture du Système Électrique

Ce système SCADA simule un réseau électrique complet depuis la production jusqu'à la consommation, en passant par la transmission et la distribution.

### 📊 **Flux d'Énergie :**
```
CENTRALES → TRANSMISSION HTB → DISTRIBUTION HTA → CONSOMMATEURS
    ↓              ↓                ↓                ↓
 400kV          400kV            20kV             400V
```

## 🏗️ **Composants du Système**

### 1. **CENTRALES DE PRODUCTION**

#### **Centrale Thermique Nord (Unit ID 1)**
- **Type** : Centrale thermique classique
- **Puissance** : 150 MW ± 20 MW
- **Tension** : 400 kV
- **Fréquence** : 50 Hz ± 0.2 Hz
- **Variables** :
  - `gen1_power` : Puissance active (MW)
  - `gen1_voltage` : Tension de sortie (kV)
  - `gen1_current` : Courant de sortie (A)
  - `gen1_frequency` : Fréquence (Hz)
  - `gen1_status` : Statut ON/OFF
  - `gen1_trip` : Déclenchement de protection

#### **Centrale Solaire Sud (Unit ID 2)**
- **Type** : Centrale photovoltaïque
- **Puissance** : Variable selon l'irradiance
- **Tension** : 400 kV
- **Variables** :
  - `gen2_power` : Puissance active (MW)
  - `gen2_voltage` : Tension de sortie (kV)
  - `gen2_current` : Courant de sortie (A)
  - `solar_irradiance` : Irradiance solaire (W/m²)
  - `gen2_status` : Statut ON/OFF

### 2. **RÉSEAU DE TRANSMISSION**

#### **Poste de Transmission HTB (Unit ID 3)**
- **Niveau** : Haute Tension B (HTB)
- **Tension** : 400 kV
- **Fonction** : Élévation et transmission longue distance
- **Variables** :
  - `htb_voltage_400kv` : Tension ligne (kV)
  - `htb_current_400kv` : Courant ligne (A)
  - `htb_power_400kv` : Puissance transmise (MW)
  - `htb_breaker_400kv` : Statut disjoncteur
  - `htb_protection` : Déclenchement protection

### 3. **RÉSEAU DE DISTRIBUTION**

#### **Poste de Distribution HTA 1 (Unit ID 4)**
- **Niveau** : Haute Tension A (HTA)
- **Tension** : 20 kV
- **Fonction** : Abaissement 400kV → 20kV
- **Variables** :
  - `hta_voltage_20kv` : Tension HTA (kV)
  - `hta_current_20kv` : Courant HTA (A)
  - `transformer_1_power` : Puissance transformateur (MVA)
  - `transformer_1_temp` : Température transformateur (°C)
  - `hta_breaker_20kv` : Statut disjoncteur HTA

#### **Poste de Distribution HTA 2 (Unit ID 5)**
- **Niveau** : Haute Tension A (HTA)
- **Tension** : 20 kV
- **Fonction** : Distribution secondaire
- **Variables** :
  - `hta2_voltage_20kv` : Tension HTA2 (kV)
  - `transformer_2_power` : Puissance transformateur (MVA)
  - `transformer_2_temp` : Température transformateur (°C)

### 4. **CONSOMMATEURS**

#### **Charge Industrielle Zone Nord (Unit ID 6)**
- **Type** : Industrie lourde
- **Puissance** : 25 MW ± 5 MW
- **Tension** : 400 V
- **Variables** :
  - `load1_power` : Puissance consommée (MW)
  - `load1_voltage` : Tension d'alimentation (kV)
  - `load1_current` : Courant consommé (A)
  - `load1_status` : Statut ON/OFF

#### **Charge Résidentielle Zone Sud (Unit ID 7)**
- **Type** : Habitations
- **Puissance** : 15 MW (variable jour/nuit)
- **Tension** : 400 V
- **Variables** :
  - `load2_power` : Puissance consommée (MW)
  - `load2_voltage` : Tension d'alimentation (kV)
  - `load2_status` : Statut ON/OFF

#### **Charge Commerciale Centre-Ville (Unit ID 8)**
- **Type** : Bureaux, commerces
- **Puissance** : 20 MW (variable jour/nuit)
- **Tension** : 400 V
- **Variables** :
  - `load3_power` : Puissance consommée (MW)
  - `load3_voltage` : Tension d'alimentation (kV)
  - `load3_status` : Statut ON/OFF

## 🎯 **Interface SCADA FUXA**

### **Vue d'Ensemble du Réseau**
- **Dimensions** : 2560x1440 pixels
- **Arrière-plan** : Sombre pour simulation nocturne
- **Composants** :
  - Centrales de production (rouge/orange)
  - Postes de transmission (violet)
  - Postes de distribution (vert)
  - Charges consommateurs (orange)
  - Lignes de transmission (jaune/bleu)
  - Lignes de distribution (orange)

### **Éléments Visuels**

#### **Centrales de Production**
- **Boîtes colorées** avec informations en temps réel
- **Voyants LED** pour statut ON/OFF
- **Affichage** : Puissance, tension, fréquence
- **Couleurs** :
  - Thermique : Rouge (#e74c3c)
  - Solaire : Orange (#f39c12)

#### **Postes de Transmission/Distribution**
- **Boîtes colorées** avec données techniques
- **Voyants LED** pour disjoncteurs
- **Affichage** : Tension, courant, puissance
- **Couleurs** :
  - HTB : Violet (#9b59b6)
  - HTA : Vert (#1abc9c)

#### **Charges Consommatrices**
- **Boîtes colorées** avec consommation
- **Voyants LED** pour statut
- **Affichage** : Puissance, tension
- **Couleur** : Orange (#e67e22)

#### **Lignes de Transmission**
- **Lignes colorées** selon le niveau de tension
- **Épaisseur** proportionnelle à la puissance
- **Couleurs** :
  - 400kV : Jaune (#f1c40f)
  - 20kV : Bleu (#3498db)
  - 400V : Orange (#e67e22)

### **Panneau de Contrôle**
- **Résumé système** : Génération totale, consommation totale
- **Fréquence système** : Monitoring en temps réel
- **Statut système** : NORMAL/ALARME
- **Panneau d'alarmes** : Alertes actives

## 🚨 **Système d'Alarmes**

### **Alarmes de Température**
- **Transformateur 1** : > 80°C
- **Transformateur 2** : > 80°C
- **Sévérité** : Haute

### **Alarmes de Protection**
- **Générateur 1** : Déclenchement
- **Protection HTB** : Déclenchement
- **Sévérité** : Critique

### **Alarmes de Fréquence**
- **Fréquence basse** : < 49.5 Hz
- **Fréquence élevée** : > 50.5 Hz
- **Sévérité** : Moyenne

## 🔧 **Scripts de Contrôle**

### **Script Équilibre Puissance**
```javascript
function checkPowerBalance() {
    var generation = gen1_power + gen2_power;
    var consumption = load1_power + load2_power + load3_power;
    var balance = generation - consumption;
    
    if (balance < -10) {
        triggerAlarm('Déficit de puissance: ' + Math.abs(balance) + ' MW');
    } else if (balance > 10) {
        triggerAlarm('Excédent de puissance: ' + balance + ' MW');
    }
    
    return balance;
}
```

### **Script Contrôle Fréquence**
```javascript
function controlFrequency() {
    var frequency = gen1_frequency;
    
    if (frequency < 49.8) {
        setTagValue('gen1_power', gen1_power + 5);
    } else if (frequency > 50.2) {
        setTagValue('gen1_power', Math.max(0, gen1_power - 5));
    }
}
```

## 🎮 **Scénarios de Test d'Attaque**

### **Scénario 1 : Attaque sur la Génération**
1. **Cible** : Centrale thermique
2. **Attaque** : Déclenchement générateur
3. **Impact** : Réduction de la génération
4. **Conséquence** : Déséquilibre puissance/fréquence

### **Scénario 2 : Attaque sur la Transmission**
1. **Cible** : Poste HTB
2. **Attaque** : Déclenchement protection
3. **Impact** : Coupure transmission
4. **Conséquence** : Perte d'alimentation consommateurs

### **Scénario 3 : Attaque sur la Distribution**
1. **Cible** : Transformateurs HTA
2. **Attaque** : Surchauffe artificielle
3. **Impact** : Déclenchement protection
4. **Conséquence** : Coupure secteur

### **Scénario 4 : Attaque sur les Charges**
1. **Cible** : Charges consommatrices
2. **Attaque** : Modification des consommations
3. **Impact** : Déséquilibre réseau
4. **Conséquence** : Instabilité fréquence

## 📊 **Métriques de Monitoring**

### **Indicateurs de Performance**
- **Équilibre puissance** : Génération vs Consommation
- **Fréquence système** : 50 Hz ± 0.2 Hz
- **Tensions** : Niveaux selon standards
- **Températures** : Transformateurs < 80°C

### **Indicateurs de Sécurité**
- **Statut disjoncteurs** : Fermé/Ouvert
- **Protections actives** : Déclenchements
- **Alarmes** : Niveau de sévérité
- **Connexions** : État des communications

## 🚀 **Utilisation du Système**

### **Démarrage**
1. Lancer OpenPLC avec le programme `electrical_system_simulation.st`
2. Démarrer FUXA avec le projet `electrical-scada-system.json`
3. Accéder à l'interface : http://localhost:1881

### **Monitoring**
- Observer les flux d'énergie en temps réel
- Surveiller les alarmes et alertes
- Analyser les tendances de consommation
- Contrôler l'équilibre du réseau

### **Tests d'Attaque**
- Utiliser les scripts d'attaque OT/ICS
- Observer les impacts sur le système
- Analyser les réactions de protection
- Évaluer les temps de récupération

## 🛡️ **Sécurité et Protection**

### **Mesures de Protection**
- Disjoncteurs automatiques
- Protections de surcharge
- Surveillance température
- Contrôle fréquence

### **Procédures d'Urgence**
- Déclenchement manuel
- Isolation de zones
- Rétablissement prioritaire
- Communication d'alerte

Ce système SCADA électrique offre une simulation réaliste d'un réseau de distribution d'électricité complet, parfait pour tester les attaques OT/ICS et analyser leurs impacts sur les infrastructures critiques.
