#!/bin/bash
# niveau1_bigbang/05_verification.sh
echo '=== [NIVEAU 1] Verification de l integrite ==='
echo '--- Comptage SOURCE (Montpellier) ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
"SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
UNION ALL SELECT 'formations', COUNT(*) FROM formations
UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"
echo '--- Comptage CIBLE (Toulouse) ---'
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
"SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
UNION ALL SELECT 'formations', COUNT(*) FROM formations
UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"
echo "Heure de fin : $(date)" | tee -a logs/coupure_debut.log
# TODO : Calculer et afficher la duree totale de la coupure
# TODO : Verifier que les cles etrangeres sont intactes sur la cible