# APC UPS Power + Energy Sensor Template pour Home Assistant

Un générateur de template YAML personnalisable pour créer des capteurs de puissance (W) et d'énergie (kWh) pour votre UPS APC dans Home Assistant.

## 🎯 Objectif

Créer **2 capteurs complementaires** pour votre UPS APC :

### 📊 **Capteur de Puissance (W)**
- Monitoring temps réel de la consommation
- Graphiques et alertes instantanées  
- Basé sur : `(Charge % ÷ 100) × Puissance nominale`

### ⚡ **Capteur d'Énergie (kWh)**  
- **Compatible Dashboard Énergie** de Home Assistant
- Historique de consommation long terme
- Calcul des coûts énergétiques
- Comparaison avec autres appareils

## 🚀 Installation Rapide (Recommandée)

### Générateur Automatique avec Dashboard Énergie

```bash
./generate_ups_template.sh
```

Le script crée **automatiquement les 2 capteurs** et vous guide pour :
- 📋 **Configuration UPS** (nom, entités, puissance)
- 🔧 **Installation** (Template Helper + configuration.yaml)
- 📈 **Dashboard Énergie** (intégration du capteur kWh)

### Exemple d'utilisation :

```bash
$ ./generate_ups_template.sh

========================================
  GÉNÉRATEUR TEMPLATE UPS POWER SENSOR
   + DASHBOARD ÉNERGIE (kWh)
========================================

📋 Nom descriptif de votre UPS
> Serveur

📊 Entité de charge UPS en %
> sensor.apc_ups_load

⚡ Entité de puissance nominale en W  
> sensor.apc_ups_nominal_power

🔋 Puissance par défaut
> 1500

📊 CAPTEURS QUI SERONT CRÉÉS :
   🔋 sensor.ups_serveur_puissance  → Puissance instantanée (W)
   ⚡ sensor.ups_serveur_energie     → Énergie cumulée (kWh)

🚀 PROCHAINES ÉTAPES :
1. Template Helper: Section 'template:' → Helpers → Template
2. Sensor Integration: Section 'sensor:' → configuration.yaml  
3. Dashboard Énergie: Ajoutez sensor.ups_serveur_energie
```

## 📋 Prérequis

- Home Assistant avec un UPS APC intégré
- Une entité qui indique la **charge en pourcentage** (ex: `sensor.ups_load`)
- Une entité qui indique la **puissance nominale** (ex: `sensor.ups_nominal_power`) OU connaître la puissance de votre UPS

### Intégrations UPS compatibles :
- **Network UPS Tools (NUT)** - *Recommandé*
- **SNMP** pour Smart-UPS
- **Intégration USB** APC
- Toute intégration exposant charge % et puissance nominale

## 📝 Installation Manuelle

Le générateur crée 2 sections distinctes à installer séparément :

### 1. Capteur de Puissance (Template Helper)
```yaml
template:
  - sensor:
      - name: "UPS [Nom] - Puissance"
        unique_id: "ups_power_[id]"
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement
        # ... config complète générée
```

**Installation :** Helpers → Template → Copier la section `template:`

### 2. Capteur d'Énergie (Integration Sensor)  
```yaml
sensor:
  - platform: integration
    source: sensor.ups_[id]_puissance
    name: "UPS [Nom] - Énergie"
    unique_id: "ups_energy_[id]"
    unit_prefix: k
    round: 3
    method: trapezoidal
```

**Installation :** Ajouter à `configuration.yaml` puis redémarrer

## 📈 Configuration Dashboard Énergie

Une fois les 2 capteurs créés :

1. **Paramètres** → **Tableaux de bord** → **Énergie**
2. **Ajouter une consommation individuelle**
3. **Sélectionnez** : `sensor.ups_[nom]_energie`
4. **Enregistrez**

Votre UPS apparaîtra maintenant dans le dashboard avec :
- 📊 Consommation temps réel et historique
- 💰 Calcul des coûts énergétiques  
- 📈 Comparaison avec autres appareils
- 🔔 Alertes de consommation anormale

## 📊 Résultat Final

### Capteurs créés :
- **`sensor.ups_[nom]_puissance`** (W) → Monitoring temps réel
- **`sensor.ups_[nom]_energie`** (kWh) → Dashboard Énergie

### Fonctionnalités :
- ✅ **Monitoring temps réel** de la charge UPS
- ✅ **Dashboard Énergie** intégré avec historique
- ✅ **Calcul de coûts** énergétiques
- ✅ **Statistiques long terme** de consommation  
- ✅ **Comparaison** avec autres appareils
- ✅ **Alertes** de consommation anormale

## 🔧 Dépannage

### Le capteur d'énergie n'apparaît pas dans Dashboard Énergie
1. Vérifiez que `device_class: energy` est présent (généré automatiquement)
2. Vérifiez que `state_class: total_increasing` est configuré  
3. Attendez quelques heures pour accumulation de données
4. Redémarrez Home Assistant si nécessaire

### Valeurs d'énergie incorrectes
1. Vérifiez que le capteur de puissance fonctionne correctement
2. L'intégration Riemann utilise `method: trapezoidal` pour plus de précision
3. Les données sont arrondies à 3 décimales (`round: 3`)

### Le capteur de puissance est "Indisponible"
1. Vérifiez que les entités sources existent et ont des valeurs
2. Testez dans **Outils de développement** → **États**
3. Vérifiez la section `availability` du template

## 📁 Fichiers inclus

- **`generate_ups_template.sh`** ⭐ - Générateur interactif (puissance + énergie)
- `apc_ups_power_template.yaml` - Template de base avec 2 capteurs
- `examples.yaml` - Exemples d'utilisation pour différents cas
- `README.md` - Cette documentation

## 🎯 Avantages vs solution simple

### ✅ **Générateur v2.0** :
- **2 capteurs automatiques** (puissance + énergie)  
- **Dashboard Énergie compatible** immédiatement
- **Instructions intégrées** pour chaque étape
- **Validation avancée** des configurations
- **Interface colorée et guidée**

### 📈 **Dashboard Énergie** :
- **Historique long terme** de consommation UPS
- **Coûts énergétiques** calculés automatiquement  
- **Comparaison** avec autres appareils du foyer
- **Graphiques** de tendance et de pointe
- **Export de données** pour analyse

## 🎨 Exemples d'usage

### UPS domestique (650VA)
```bash
echo -e "Bureau\nbureau\nsensor.ups_load\nsensor.ups_nominal_power\n650\nn" | ./generate_ups_template.sh
```

### UPS professionnel (1500VA)  
```bash
echo -e "Serveur\nserveur\nsensor.smart_ups_load\nsensor.smart_ups_power\n1500\nn" | ./generate_ups_template.sh
```

### Multi-UPS
Exécutez le script plusieurs fois avec des noms différents pour créer plusieurs capteurs.

## 🤝 Contribution

N'hésitez pas à :
- Signaler des bugs dans les Issues
- Proposer des améliorations via Pull Request  
- Partager vos configurations spécifiques
- Suggérer des fonctionnalités Dashboard Énergie

## 📄 Licence

Ce template est libre d'utilisation et de modification.

---

**💡 Nouveau :** Votre UPS apparaît maintenant dans le **Dashboard Énergie** de Home Assistant avec historique de consommation, calcul de coûts et comparaison avec vos autres appareils ! 📈⚡

## 🔧 Usage avancé

### Script en mode batch
```bash
# Génération automatique pour plusieurs UPS
echo -e "Bureau\nbureau\nsensor.ups1_load\nsensor.ups1_nominal\n650\nn" | ./generate_ups_template.sh
echo -e "Serveur\nserveur\nsensor.ups2_load\nsensor.ups2_nominal\n1500\nn" | ./generate_ups_template.sh
```

### Intégration complète Dashboard Énergie
Une fois vos capteurs configurés, votre Dashboard Énergie affichera :
- 📊 Consommation UPS en temps réel
- 📈 Historique sur 7j/30j/1an  
- 💰 Coût énergétique estimé
- ⚖️ Pourcentage vs consommation totale
- 🔔 Alertes de pic de consommation
