# APC UPS Power Sensor Template pour Home Assistant

Un template YAML simple et bien documenté pour créer un capteur de puissance instantanée de votre UPS APC dans Home Assistant.

## 🎯 Objectif

Calculer la puissance instantanée (en Watts) de votre UPS APC basée sur :
- **Charge actuelle** (en pourcentage)  
- **Puissance nominale** (en Watts)

**Formule :** `Puissance instantanée = (Charge % ÷ 100) × Puissance nominale`

## 📋 Prérequis

- Home Assistant avec un UPS APC intégré
- Une entité qui indique la **charge en pourcentage** (ex: `sensor.ups_load`)
- Une entité qui indique la **puissance nominale** (ex: `sensor.ups_nominal_power`) OU connaître la puissance de votre UPS

### Intégrations UPS compatibles :
- **Network UPS Tools (NUT)** - *Recommandé*
- **SNMP** pour Smart-UPS
- **Intégration USB** APC
- Toute intégration exposant charge % et puissance nominale

## 🚀 Installation

### Méthode 1: Via l'interface Template (Recommandée)

1. **Paramètres** → **Appareils et services** → **Helpers**
2. **+ CRÉER UN HELPER** → **Template** → **Capteur de template**
3. **Effacez tout** le contenu par défaut dans l'éditeur
4. **Copiez le template personnalisé** (voir section Utilisation)
5. **Enregistrez**

### Méthode 2: Via configuration.yaml

1. Éditez votre fichier `configuration.yaml`
2. Ajoutez la section `template:` (ou complétez-la si elle existe)
3. Collez le template personnalisé
4. **Vérifiez la configuration** : Outils de développement → YAML → Vérifier
5. **Redémarrez Home Assistant**

## 📝 Utilisation

### 1. Identifier vos entités

D'abord, trouvez vos entités UPS :

```bash
# Dans les Outils de développement → États, recherchez :
sensor.ups_load              # Charge en %
sensor.ups_nominal_power     # Puissance nominale en W
```

### 2. Personnaliser le template

Utilisez le template de base et remplacez :

```yaml
template:
  - sensor:
      - name: "UPS [VOTRE_NOM] - Puissance Instantanée"  # ← Nom descriptif
        unique_id: "ups_power_[identifiant]"              # ← Identifiant unique
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement
        icon: mdi:power-plug-outline
        
        availability: >-
          {{ states('[ENTITE_CHARGE]') not in ['unavailable', 'unknown'] and
             states('[ENTITE_PUISSANCE_NOMINALE]') not in ['unavailable', 'unknown'] }}
        
        state: >-
          {% set load_percent = states('[ENTITE_CHARGE]') | float(0) %}
          {% set nominal_power = states('[ENTITE_PUISSANCE_NOMINALE]') | float([PUISSANCE_DEFAUT]) %}
          {{ (load_percent / 100 * nominal_power) | round(1) }}
        
        attributes:
          ups_name: "[VOTRE_NOM]"
          charge_percent: "{{ states('[ENTITE_CHARGE]') | float(0) }}"
          nominal_power_w: "{{ states('[ENTITE_PUISSANCE_NOMINALE]') | float([PUISSANCE_DEFAUT]) }}"
          formula: "{{ states('[ENTITE_CHARGE]') | float(0) }} % × {{ states('[ENTITE_PUISSANCE_NOMINALE]') | float([PUISSANCE_DEFAUT]) }} W"
```

**Remplacements nécessaires :**
- `[VOTRE_NOM]` → "Bureau", "Salon", "Serveur"...
- `[identifiant]` → "bureau", "salon", "serveur"...
- `[ENTITE_CHARGE]` → `sensor.ups_load`
- `[ENTITE_PUISSANCE_NOMINALE]` → `sensor.ups_nominal_power` 
- `[PUISSANCE_DEFAUT]` → `650`, `900`, `1500`...

### 3. Exemple concret

Pour un UPS de bureau avec NUT :

```yaml
template:
  - sensor:
      - name: "UPS Bureau - Puissance Instantanée"
        unique_id: "ups_power_bureau"
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement
        icon: mdi:power-plug-outline
        
        availability: >-
          {{ states('sensor.ups_load') not in ['unavailable', 'unknown'] and
             states('sensor.ups_nominal_power') not in ['unavailable', 'unknown'] }}
        
        state: >-
          {% set load_percent = states('sensor.ups_load') | float(0) %}
          {% set nominal_power = states('sensor.ups_nominal_power') | float(650) %}
          {{ (load_percent / 100 * nominal_power) | round(1) }}
        
        attributes:
          ups_name: "Bureau"
          charge_percent: "{{ states('sensor.ups_load') | float(0) }}"
          nominal_power_w: "{{ states('sensor.ups_nominal_power') | float(650) }}"
```

## 📊 Résultat

Après installation, vous obtiendrez :

- **Capteur** : `sensor.ups_bureau_puissance_instantanee`
- **Valeur** : Puissance en Watts (ex: 156.5 W)
- **Historique** compatible avec Energy Dashboard
- **Attributs utiles** pour debugging

## 🔧 Dépannage

### Le capteur n'apparaît pas
1. Vérifiez la syntaxe YAML (indentation importante !)
2. Vérifiez la configuration : **Outils de développement** → **YAML** → **Vérifier**
3. Consultez les logs : **Paramètres** → **Logs**

### Valeur "Indisponible"
1. Vérifiez que les entités sources existent et ont des valeurs
2. Testez les entités dans **Outils de développement** → **États**
3. Vérifiez la section `availability` du template

### Valeurs incorrectes
1. Vérifiez les noms d'entités (case-sensitive)
2. Vérifiez que la puissance nominale est en Watts (pas en VA)
3. Testez la formule manuellement : `charge_% × puissance_nominale ÷ 100`

## 📁 Fichiers inclus

- `apc_ups_power_template.yaml` - Template principal avec documentation
- `examples.yaml` - Exemples d'utilisation pour différents cas
- `README.md` - Cette documentation

## 🤝 Contribution

N'hésitez pas à :
- Signaler des bugs dans les Issues
- Proposer des améliorations via Pull Request  
- Partager vos configurations spécifiques

## 📄 Licence

Ce template est libre d'utilisation et de modification.

---

**💡 Astuce :** Utilisez ce capteur dans l'Energy Dashboard de Home Assistant pour suivre la consommation électrique protégée par votre UPS !
