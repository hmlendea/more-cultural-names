#!/bin/bash

REPO_DIR="$(pwd)"
SCRIPTS_DIR="${REPO_DIR}/scripts"
OUTPUT_DIR="${REPO_DIR}/out"
EXTRAS_DIR="${REPO_DIR}/extras"
VANILLA_FILES_DIR="${REPO_DIR}/vanilla"

LANGUAGES_FILE="${REPO_DIR}/languages.xml"
LOCATIONS_FILE="${REPO_DIR}/locations.xml"
TITLES_FILE="${REPO_DIR}/titles.xml"

if [ -d "${HOME}/.games/Steam/common" ]; then
    STEAM_APPS_DIR="${HOME}/.games/Steam"
elif [ -d "${HOME}/.local/share/Steam/steamapps/common" ]; then
    STEAM_APPS_DIR="${HOME}/.local/share/Steam/steamapps"
fi

STEAM_GAMES_DIR="${STEAM_APPS_DIR}/common"
STEAM_WORKSHOP_DIR="${STEAM_APPS_DIR}/workshop"
STEAM_WORKSHOP_CK3_DIR="${STEAM_WORKSHOP_DIR}/content/1158310"
STEAM_WORKSHOP_HOI4_DIR="${STEAM_WORKSHOP_DIR}/content/394360"
STEAM_WORKSHOP_IR_DIR="${STEAM_WORKSHOP_DIR}/content/859580"
CK2_LOCAL_MODS_DIR="${HOME}/.paradoxinteractive/Crusader Kings II/mod"

CK2_DIR="${STEAM_GAMES_DIR}/Crusader Kings II"
CK2_CULTURES_DIR="${CK2_DIR}/common/cultures"
CK2_LOCALISATIONS_DIR="${CK2_DIR}/localisation"
CK2_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck2_landed_titles.txt"

CK2HIP_DIR="${CK2_LOCAL_MODS_DIR}/Historical_Immersion_Project"
CK2HIP_CULTURES_DIR="${CK2HIP_DIR}/common/cultures"
CK2HIP_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck2hip_landed_titles.txt"

CK3_DIR="${STEAM_GAMES_DIR}/Crusader Kings III"
CK3_CULTURES_DIR="${CK3_DIR}/game/common/culture/cultures"
CK3_LOCALISATIONS_DIR="${CK3_DIR}/game/localization/english"
CK3_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3_landed_titles.txt"
CK3_VANILLA_LOCALISATION_FILE="${CK3_DIR}/game/localization/english/titles_l_english.yml"
CK3_VANILLA_CULTURAL_LOCALISATION_FILE="${CK3_LOCALISATIONS_DIR}/titles_cultural_names_l_english.yml"

CK3ATHA_DIR="${STEAM_WORKSHOP_CK3_DIR}/2618149514"
CK3ATHA_CULTURES_DIR="${CK3ATHA_DIR}/common/culture/cultures"
CK3ATHA_LOCALISATIONS_DIR="${CK3ATHA_DIR}/localization/english"
CK3ATHA_LANDED_TITLES_DIR="${CK3ATHA_DIR}/common/landed_titles"
CK3ATHA_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3atha_landed_titles.txt"
CK3ATHA_VANILLA_BARONIES_LOCALISATION_FILE="${CK3ATHA_DIR}/ATHA_titles_baronies_l_english.yml"
CK3ATHA_VANILLA_COUNTIES_LOCALISATION_FILE="${CK3ATHA_DIR}/ATHA_titles_counties_l_english.yml"
CK3ATHA_VANILLA_DUCHIES_LOCALISATION_FILE="${CK3ATHA_DIR}/ATHA_titles_duchies_l_english.yml"
CK3ATHA_VANILLA_KINGDOMS_LOCALISATION_FILE="${CK3ATHA_DIR}/ATHA_titles_kingdoms_l_english.yml"
CK3ATHA_VANILLA_EMPIRES_LOCALISATION_FILE="${CK3ATHA_DIR}/ATHA_titles_empires_l_english.yml"
CK3ATHA_VANILLA_SPECIAL_LOCALISATION_FILE="${CK3ATHA_DIR}/ATHA_titles_special_l_english.yml"

CK3IBL_DIR="${STEAM_WORKSHOP_CK3_DIR}/2416949291"
CK3IBL_CULTURES_DIR="${CK3IBL_DIR}/common/culture/cultures"
CK3IBL_LOCALISATIONS_DIR="${CK3IBL_DIR}/localization/english"
CK3IBL_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3ibl_landed_titles.txt"
CK3IBL_VANILLA_LOCALISATION_FILE="${CK3IBL_LOCALISATIONS_DIR}/replace/ibl_titles_l_english.yml"

CK3MBP_DIR="${STEAM_WORKSHOP_CK3_DIR}/2216670956"
CK3MBP_CULTURES_DIR="${CK3MBP_DIR}/common/culture/cultures"
CK3IBL_LOCALISATIONS_DIR="${CK3MBP_DIR}/localization/english"
CK3MBP_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3mbp_landed_titles.txt"
CK3MBP_VANILLA_LOCALISATION_FILE="${CK3MBP_DIR}/localization/english/titles_l_english.yml"

CK3TFE_DIR="${STEAM_WORKSHOP_CK3_DIR}/2243307127"
CK3TFE_CULTURES_DIR="${CK3TFE_DIR}/common/culture/cultures"
CK3TFE_LOCALISATIONS_DIR="${CK3TFE_DIR}/localization/english"
CK3TFE_VANILLA_LANDED_TITLES_FILE="${VANILLA_FILES_DIR}/ck3tfe_landed_titles.txt"
CK3TFE_VANILLA_LOCALISATION_FILE="${CK3TFE_LOCALISATIONS_DIR}/replace/TFE_titles_l_english.yml"

HOI4_DIR="${STEAM_GAMES_DIR}/Hearts of Iron IV"
HOI4_TAGS_DIR="${HOI4_DIR}/common/country_tags"
HOI4_STATES_DIR="${HOI4_DIR}/history/states"
HOI4_LOCALISATIONS_DIR="${HOI4_DIR}/localisation/english"

HOI4TGW_DIR="${STEAM_WORKSHOP_HOI4_DIR}/699709023"
HOI4TGW_TAGS_DIR="${HOI4TGW_DIR}/common/country_tags"
HOI4TGW_STATES_DIR="${HOI4TGW_DIR}/history/states"
HOI4TGW_LOCALISATIONS_DIR="${HOI4TGW_DIR}/localisation"

IR_DIR="${STEAM_GAMES_DIR}/ImperatorRome"
IR_CULTURES_DIR="${IR_DIR}/game/common/cultures"
IR_LOCALISATIONS_DIR="${IR_DIR}/game/localization/english"
IR_VANILLA_FILE="${VANILLA_FILES_DIR}/ir_province_names.yml"

IR_AoE_DIR="${STEAM_WORKSHOP_IR_DIR}/2578689167"
IR_AoE_CULTURES_DIR="${IR_AoE_DIR}/common/cultures"
IR_AoE_LOCALISATIONS_DIR="${IR_AoE_DIR}/localization/english"
IR_AoE_VANILLA_FILE="${VANILLA_FILES_DIR}/iraoe_province_names.yml"
