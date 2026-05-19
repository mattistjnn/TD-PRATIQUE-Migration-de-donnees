#!/bin/bash
echo '=== [NIVEAU 1] Restauration sur la cible (Toulouse) ==='

BACKUP_FILE_POSIX=$(ls -t "$(pwd)/backups/techcorp_bigbang_"*.dump | head -1)
BACKUP_FILE_WIN=$(cygpath -w "$BACKUP_FILE_POSIX")

if [ -z "$BACKUP_FILE_POSIX" ]; then
  echo 'ERREUR : aucun fichier de sauvegarde trouve !'
  exit 1
fi

echo "Fichier utilise : $BACKUP_FILE_POSIX"

# Copier le dump dans le container cible
docker cp "$BACKUP_FILE_WIN" pg_toulouse://tmp/techcorp_backup.dump

# Restaurer la base
docker exec pg_toulouse pg_restore \
  -U admin -d techcorp_db \
  -v --clean --if-exists \
  //tmp/techcorp_backup.dump

echo ''
echo '=== Verification des tables restaurees ==='
docker exec pg_toulouse psql -U admin -d techcorp_db -c '\dt'

echo 'OK : Restauration terminee'
