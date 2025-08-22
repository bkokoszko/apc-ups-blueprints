#!/bin/bash

# ========================================
# GÉNÉRATEUR DE TEMPLATE UPS POWER SENSOR
# ========================================
# 
# Ce script génère un template YAML personnalisé pour votre UPS APC
# Crée 2 capteurs : Puissance (W) + Énergie (kWh) pour Dashboard Énergie
# Usage: ./generate_ups_template.sh
#
# Auteur: Boris Kokoszko
# Version: 2.0
# ========================================

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  GÉNÉRATEUR TEMPLATE UPS POWER SENSOR${NC}"
echo -e "${CYAN}   + DASHBOARD ÉNERGIE (kWh)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Fonction pour demander une valeur avec valeur par défaut
ask_with_default() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    
    echo -e "${YELLOW}$prompt${NC}"
    if [[ -n "$default" ]]; then
        echo -e "${BLUE}  (défaut: $default)${NC}"
    fi
    echo -n "> "
    read -r input
    
    if [[ -z "$input" && -n "$default" ]]; then
        input="$default"
    fi
    
    # Assigner à la variable globale
    declare -g "$var_name"="$input"
}

# Fonction de validation d'entité
validate_entity() {
    local entity="$1"
    if [[ ! "$entity" =~ ^sensor\. ]]; then
        echo -e "${RED}⚠️  Attention: L'entité devrait commencer par 'sensor.' (ex: sensor.ups_load)${NC}"
    fi
}

echo -e "${GREEN}Ce script génère 2 capteurs pour votre UPS :${NC}"
echo -e "${CYAN}  📊 Capteur de puissance (W) - pour monitoring temps réel${NC}"
echo -e "${CYAN}  ⚡ Capteur d'énergie (kWh) - pour Dashboard Énergie${NC}"
echo ""
echo "Répondez aux questions suivantes :"
echo ""

# 1. Nom de l'UPS
ask_with_default "📋 Nom descriptif de votre UPS (ex: Bureau, Salon, Serveur)" "Bureau" "UPS_NAME"

# 2. Identifiant unique
default_id=$(echo "$UPS_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')
ask_with_default "🔑 Identifiant unique (sans espaces, minuscules)" "$default_id" "UPS_ID"

# 3. Entité de charge
ask_with_default "📊 Entité de charge UPS en % (ex: sensor.ups_load)" "sensor.ups_load" "ENTITY_LOAD"
validate_entity "$ENTITY_LOAD"

# 4. Entité de puissance nominale
ask_with_default "⚡ Entité de puissance nominale en W (ex: sensor.ups_nominal_power)" "sensor.ups_nominal_power" "ENTITY_NOMINAL"
validate_entity "$ENTITY_NOMINAL"

# 5. Puissance par défaut
ask_with_default "🔋 Puissance par défaut si entité indisponible (ex: 650)" "650" "DEFAULT_POWER"

# Validation numérique pour la puissance
if ! [[ "$DEFAULT_POWER" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}❌ Erreur: La puissance doit être un nombre entier${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}📝 Génération des templates (puissance + énergie)...${NC}"

# Nom du fichier de sortie
OUTPUT_FILE="ups_${UPS_ID}_power_energy_template.yaml"

# Génération du template
cat > "$OUTPUT_FILE" << TEMPLATE_EOF
# ========================================
# TEMPLATE UPS POWER + ENERGY SENSORS - $UPS_NAME
# ========================================
# Généré automatiquement le $(date '+%Y-%m-%d %H:%M:%S')
# UPS: $UPS_NAME
# Entité charge: $ENTITY_LOAD
# Entité puissance: $ENTITY_NOMINAL
# Puissance défaut: ${DEFAULT_POWER}W
# 
# CAPTEURS GÉNÉRÉS:
# - sensor.ups_${UPS_ID}_puissance (W) - Monitoring temps réel
# - sensor.ups_${UPS_ID}_energie (kWh) - Dashboard Énergie
# ========================================

# ========================================
# 1. CAPTEUR DE PUISSANCE (Watts)
# ========================================
template:
  - sensor:
      - name: "UPS $UPS_NAME - Puissance"
        unique_id: "ups_power_${UPS_ID}"
        
        # Configuration du capteur de puissance
        unit_of_measurement: "W"
        device_class: power
        state_class: measurement
        icon: mdi:power-plug-outline
        
        # Disponibilité : le capteur n'est actif que si les données sources sont valides
        availability: >-
          {{ states('$ENTITY_LOAD') not in ['unavailable', 'unknown'] and
             states('$ENTITY_NOMINAL') not in ['unavailable', 'unknown'] }}
        
        # Calcul de la puissance : (charge % / 100) × puissance nominale
        state: >-
          {% set load_percent = states('$ENTITY_LOAD') | float(0) %}
          {% set nominal_power = states('$ENTITY_NOMINAL') | float($DEFAULT_POWER) %}
          {{ (load_percent / 100 * nominal_power) | round(1) }}
        
        # Attributs supplémentaires pour le debugging et l'historique
        attributes:
          ups_name: "$UPS_NAME"
          charge_percent: "{{ states('$ENTITY_LOAD') | float(0) }}"
          nominal_power_w: "{{ states('$ENTITY_NOMINAL') | float($DEFAULT_POWER) }}"
          last_calculation: "{{ now().strftime('%Y-%m-%d %H:%M:%S') }}"
          formula: "{{ states('$ENTITY_LOAD') | float(0) }} % × {{ states('$ENTITY_NOMINAL') | float($DEFAULT_POWER) }} W = {{ (states('$ENTITY_LOAD') | float(0) / 100 * states('$ENTITY_NOMINAL') | float($DEFAULT_POWER)) | round(1) }} W"

# ========================================
# 2. CAPTEUR D'ÉNERGIE (kWh) - DASHBOARD ÉNERGIE
# ========================================
# Ce capteur utilise l'intégration Riemann pour convertir
# la puissance instantanée (W) en énergie cumulée (kWh)
sensor:
  - platform: integration
    source: sensor.ups_${UPS_ID}_puissance
    name: "UPS $UPS_NAME - Énergie"
    unique_id: "ups_energy_${UPS_ID}"
    unit_prefix: k
    round: 3
    method: trapezoidal

# ========================================
# INSTALLATION
# ========================================
# 
# IMPORTANT: Ce template contient 2 sections différentes !
#
# 1. SECTION TEMPLATE (Capteur de puissance):
#    - Paramètres → Appareils et services → Helpers
#    - + CRÉER UN HELPER → Template → Capteur de template
#    - Copiez SEULEMENT la section "template:" ci-dessus
#    - Enregistrez
#
# 2. SECTION SENSOR (Capteur d'énergie):
#    - Éditez votre configuration.yaml
#    - Ajoutez la section "sensor:" ci-dessus
#    - Vérifiez la configuration (Outils de développement → YAML)
#    - Redémarrez Home Assistant
#
# ALTERNATIVE - Tout dans configuration.yaml:
#    - Copiez les 2 sections dans configuration.yaml
#    - Vérifiez et redémarrez
#
# ========================================
# UTILISATION DASHBOARD ÉNERGIE
# ========================================
#
# Une fois les 2 capteurs créés :
# 1. Paramètres → Tableaux de bord → Énergie
# 2. Ajouter une consommation individuelle
# 3. Sélectionner: sensor.ups_${UPS_ID}_energie
# 4. Le capteur apparaîtra dans le dashboard avec historique kWh
#
# ========================================
# RÉSULTATS
# ========================================
#
# Capteurs créés :
# - sensor.ups_${UPS_ID}_puissance (Watts)     → Valeur instantanée
# - sensor.ups_${UPS_ID}_energie (kWh)         → Consommation cumulée
#
# Compatibilité :
# - ✅ Monitoring temps réel (puissance)
# - ✅ Dashboard Énergie (énergie)
# - ✅ Historique long terme
# - ✅ Statistiques de consommation
#
# ========================================
TEMPLATE_EOF

echo ""
echo -e "${GREEN}✅ Template généré avec succès !${NC}"
echo -e "${BLUE}📁 Fichier créé : $OUTPUT_FILE${NC}"
echo ""

# Affichage du résumé
echo -e "${YELLOW}📋 RÉSUMÉ DE LA CONFIGURATION :${NC}"
echo -e "   UPS Name        : $UPS_NAME"
echo -e "   Unique ID       : $UPS_ID"
echo -e "   Entity Load     : $ENTITY_LOAD"
echo -e "   Entity Nominal  : $ENTITY_NOMINAL"  
echo -e "   Default Power   : ${DEFAULT_POWER}W"
echo -e "   Output File     : $OUTPUT_FILE"
echo ""

echo -e "${CYAN}📊 CAPTEURS QUI SERONT CRÉÉS :${NC}"
echo -e "   ${GREEN}🔋 sensor.ups_${UPS_ID}_puissance${NC}  → Puissance instantanée (W)"
echo -e "   ${GREEN}⚡ sensor.ups_${UPS_ID}_energie${NC}     → Énergie cumulée (kWh)"
echo ""

# Instructions d'installation
echo -e "${GREEN}🚀 PROCHAINES ÉTAPES :${NC}"
echo -e "1. ${YELLOW}Template Helper:${NC} Copiez la section 'template:' → Helpers → Template"
echo -e "2. ${YELLOW}Sensor Integration:${NC} Copiez la section 'sensor:' → configuration.yaml"
echo -e "3. ${YELLOW}Dashboard Énergie:${NC} Ajoutez sensor.ups_${UPS_ID}_energie"
echo ""

# Proposition d'affichage du fichier
echo -n "Voulez-vous afficher le contenu du template ? (y/N) : "
read -r show_content

if [[ "$show_content" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  CONTENU DU TEMPLATE${NC}"
    echo -e "${BLUE}========================================${NC}"
    cat "$OUTPUT_FILE"
fi

echo ""
echo -e "${GREEN}🎉 Terminé ! Vos templates UPS (puissance + énergie) sont prêts !${NC}"
echo -e "${CYAN}💡 Le capteur d'énergie sera visible dans le Dashboard Énergie de Home Assistant${NC}"
