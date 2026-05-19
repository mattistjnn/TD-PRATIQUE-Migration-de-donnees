#!/bin/bash
# niveau2_progressive/03_sync_differentielle.sh
echo '=== [NIVEAU 2] Synchronisation differentielle ==='

# Fichiers : rsync ne retransfère que les nouveaux/modifiés
rsync -avh --progress --checksum \
  ./data_montpellier/supports/ \
  ./data_toulouse/supports/

# Base : export des données récentes
docker exec pg_montpellier pg_dump \
  -U admin -d techcorp_db \
  --format=plain --data-only \
  -f /tmp/sync_diff.sql

docker cp pg_montpellier:/tmp/sync_diff.sql ./backups/sync_diff.sql

echo 'OK : Synchronisation differentielle terminee'

# Comparer le nombre de lignes entre source et cible
echo '--- Differences restantes source vs cible ---'
echo 'SOURCE :'
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  "SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
  UNION ALL SELECT 'formations', COUNT(*) FROM formations
  UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
  UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"


echo 'CIBLE :'
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  "SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
  UNION ALL SELECT 'formations', COUNT(*) FROM formations
  UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
  UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"