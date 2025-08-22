# APC UPS Power Sensor Template pour Home Assistant

Un template YAML personnalisable pour créer un capteur de puissance instantanée de votre UPS APC dans Home Assistant.

## 🎯 Objectif

Calculer la puissance instantanée (en Watts) de votre UPS APC basée sur :
- **Charge actuelle** (en pourcentage)  
- **Puissance nominale** (en Watts)

**Formule :** `Puissance instantanée = (Charge % ÷ 100) × Puissance nominale`

## 🚀 Installation Rapide (Recommandée)

### Générateur Automatique

Utilisez le script générateur interactif pour créer votre template personnalisé :

```bash
./generate_ups_template.sh
```

Le script vous demandera :
- 📋 **Nom de l'UPS** (ex: Bureau, Salon, Serveur)
- 🔑 **Identifiant unique** (généré automatiquement)
- 📊 **Entité de charge** (ex: `sensor.ups_load`)
- ⚡ **Entité de puissance nominale** (ex: `sensor.ups_nominal_power`)
- 🔋 **Puissance par défaut** (ex: 650W)

**Résultat :** Un fichier YAML prêt à copier-coller dans Home Assistant !

### Exemple d'utilisation du générateur :

```bash
$ ./generate_ups_template.sh

========================================
  GÉNÉRATEUR TEMPLATE UPS POWER SENSOR
========================================

📋 Nom descriptif de votre UPS (ex: Bureau, Salon, Serveur)
  (défaut: Bureau)
> Serveur

🔑 Identifiant unique (sans espaces, minuscules)
  (défaut: serveur)
> 

📊 Entité de charge UPS en % (ex: sensor.ups_load)
  (défaut: sensor.ups_load)
> sensor.apc_ups_load

⚡ Entité de puissance nominale en W (ex: sensor.ups_nominal_power)
  (défaut: sensor.ups_nominal_power)
> sensor.apc_ups_nominal_power

🔋 Puissance par défaut si entité indisponible (ex: 650)
  (défaut: 650)
> 1500

✅ Template généré avec succès !
📁 Fichier créé : ups_serveur_power_template.yaml
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

Si vous préférez personnaliser manuellement, consultez les fichiers d'exemple :

### 1. Identifier vos entités

Dans Home Assistant → **Outils de développement** → **États**, recherchez :
```
sensor.ups_load              # Charge en %
sensor.ups_nominal_power     # Puissance nominale en W
```

### 2. Méthodes d'installation

#### Méthode 1: Via l'interface Template (Recommandée)

1. **Paramètres** → **Appareils et services** → **Helpers**
2. **+ CRÉER UN HELPER** → **Template** → **Capteur de template**
3. **Effacez tout** le contenu par défaut dans l'éditeur
4. **Copiez le template généré** ou personnalisé
5. **Enregistrez**

#### Méthode 2: Via configuration.yaml

1. Éditez votre fichier `configuration.yaml`
2. Ajoutez la section `template:` (ou complétez-la si elle existe)
3. Collez le template personnalisé
4. **Vérifiez la configuration** : Outils de développement → YAML → Vérifier
5. **Redémarrez Home Assistant**

## 📊 Résultat

Après installation, vous obtiendrez :

- **Capteur** : `sensor.ups_[nom]_puissance_instantanee`
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

- **`generate_ups_template.sh`** - Générateur interactif de template personnalisé ⭐
- `apc_ups_power_template.yaml` - Template de base avec documentation
- `examples.yaml` - Exemples d'utilisation pour différents cas
- `README.md` - Cette documentation

## 🎯 Avantages du générateur

✅ **Interface interactive** - Questions guidées avec valeurs par défaut  
✅ **Validation automatique** - Vérification des noms d'entités  
✅ **Template personnalisé** - Génération sur mesure pour votre configuration  
✅ **Documentation incluse** - Instructions d'installation dans le fichier généré  
✅ **Aucune erreur** - Pas de copier-coller manuel avec risques de fautes  

## 🎨 Exemples de templates générés

Le script peut générer des templates pour différents types d'UPS :

- **UPS domestique** (Back-UPS 650VA) → Template optimisé pour NUT
- **UPS professionnel** (Smart-UPS 1500VA) → Template avec SNMP
- **Multi-UPS** → Templates séparés pour chaque UPS
- **Configuration avancée** → Avec gestion d'erreurs étendue

## 🤝 Contribution

N'hésitez pas à :
- Signaler des bugs dans les Issues
- Proposer des améliorations via Pull Request  
- Partager vos configurations spécifiques

## 📄 Licence

Ce template est libre d'utilisation et de modification.

---

**💡 Astuce :** Utilisez ce capteur dans l'Energy Dashboard de Home Assistant pour suivre la consommation électrique protégée par votre UPS !

## 🔧 Usage avancé

### Script en mode non-interactif

```bash
echo -e "Serveur\nserveur\nsensor.ups_load\nsensor.ups_nominal_power\n1500\nn" | ./generate_ups_template.sh
```

### Génération de plusieurs templates

```bash
# UPS Bureau
echo -e "Bureau\nbureau\nsensor.ups_bureau_load\nsensor.ups_bureau_nominal\n650\nn" | ./generate_ups_template.sh

# UPS Salon  
echo -e "Salon\nsalon\nsensor.ups_salon_load\nsensor.ups_salon_nominal\n900\nn" | ./generate_ups_template.sh
```
