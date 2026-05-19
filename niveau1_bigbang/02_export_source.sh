#!/bin/bash
echo '=== [NIVEAU 1] Export de la base source ==='

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR_WIN="$(pwd -W)/backups"
BACKUP_FILE_WIN="$BACKUP_DIR_WIN/techcorp_bigbang_$TIMESTAMP.dump"

mkdir -p "$(pwd)/backups"

docker exec pg_montpellier pg_dump \
  -U admin -d techcorp_db \
  -F c -v \
  -f //tmp/techcorp_backup.dump

# Docker cp vers le dossier (pas le fichier directement)
docker cp pg_montpellier://tmp/techcorp_backup.dump "$BACKUP_DIR_WIN/"

# Renommer le fichier deposé par Docker
mv "$(pwd)/backups/techcorp_backup.dump" "$(pwd)/backups/techcorp_bigbang_$TIMESTAMP.dump"

echo "OK : Sauvegarde creee : $BACKUP_FILE_WIN"
ls -lh "$(pwd)/backups/"*.dump
