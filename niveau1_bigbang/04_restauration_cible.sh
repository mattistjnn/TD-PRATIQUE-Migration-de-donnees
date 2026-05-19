#!/bin/bash

echo '=== [NIVEAU 1] Restauration sur la cible (Toulouse) ==='

BACKUP_FILE=$(ls -t ./backups/techcorp_bigbang_*.dump | head -1)

if [ -z "$BACKUP_FILE" ]; then
  echo 'ERREUR : aucun fichier de sauvegarde trouve !'
  exit 1
fi

echo "Fichier utilise : $BACKUP_FILE"

docker cp $BACKUP_FILE pg_toulouse:/tmp/techcorp_backup.dump

docker exec pg_toulouse pg_restore \
  -U admin -d techcorp_db \
  -v --clean --if-exists \
  /tmp/techcorp_backup.dump

echo 'OK : Restauration terminee'

echo ''
echo '=== Tables restaurees sur la cible ==='
docker exec pg_toulouse psql -U admin -d techcorp_db -c '\dt'

echo ''
echo '=== Nombre de lignes sur la cible ==='
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "SELECT 'utilisateurs', COUNT(*) FROM utilisateurs
   UNION ALL SELECT 'formations', COUNT(*) FROM formations
   UNION ALL SELECT 'progressions', COUNT(*) FROM progressions
   UNION ALL SELECT 'resultats_examens', COUNT(*) FROM resultats_examens;"