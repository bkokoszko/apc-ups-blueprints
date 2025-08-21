# APC UPS Power Sensor Blueprint pour Home Assistant

Ce blueprint permet de créer facilement des capteurs de puissance instantanée pour vos UPS APC dans Home Assistant.

## 🚀 Fonctionnalités

- ✅ Calcul automatique de la puissance instantanée basée sur la charge UPS
- ✅ Utilise la puissance nominale exposée par l'UPS (pas de saisie manuelle)
- ✅ Compatible avec le dashboard Énergie de Home Assistant
- ✅ Vérification de disponibilité des capteurs
- ✅ Interface graphique simple

## 📋 Prérequis

- Home Assistant avec l'intégration **NUT (Network UPS Tools)**
- UPS APC connecté et configuré
- Les entités suivantes doivent être disponibles :
  - `sensor.{nom_ups}_load` (charge en %)
  - `sensor.{nom_ups}_nominal_real_power` (puissance nominale)

## 🔧 Installation

1. Dans Home Assistant, allez dans **Paramètres** > **Automatisations & Scènes**
2. Cliquez sur l'onglet **Blueprints**
3. Cliquez sur **Importer un blueprint**
4. Collez cette URL : `https://raw.githubusercontent.com/VOTRE_USERNAME/apc-ups-blueprints/main/apc_ups_power_sensor.yaml`
5. Cliquez sur **Aperçu du blueprint** puis **Importer le blueprint**

## 📊 Utilisation

1. Dans l'onglet **Blueprints**, trouvez "APC UPS Power Sensor (Automatique)"
2. Cliquez sur **Créer une automatisation**
3. Remplissez les paramètres :
   - **Nom de l'UPS** : salon, bureau, etc.
   - **Entité de charge UPS** : sélectionnez `sensor.xxx_load`
   - **Entité Puissance Nominale** : sélectionnez `sensor.xxx_nominal_real_power`
4. Sauvegardez

## ✨ Résultat

Un nouveau capteur sera créé : `sensor.ups_{nom}_puissance`

Ce capteur peut être utilisé directement dans le **dashboard Énergie** de Home Assistant.

## 📈 Exemple

Pour un UPS nommé "salon" :
- Nom UPS : `salon`
- Charge : `sensor.apc850_load`  
- Puissance nominale : `sensor.apc850_nominal_real_power`
- → Crée : `sensor.ups_salon_puissance`

## 🐛 Dépannage

Si le capteur affiche "Indisponible" :
1. Vérifiez que l'intégration NUT fonctionne
2. Vérifiez que les entités existent dans **Outils de développement** > **États**
3. Assurez-vous que l'UPS est en ligne

## 📝 Licence

MIT License - Libre d'utilisation
