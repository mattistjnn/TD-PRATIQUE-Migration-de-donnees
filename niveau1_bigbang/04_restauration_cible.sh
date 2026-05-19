#!/bin/bash
# niveau1_bigbang/04_restauration_cible.sh
echo '=== [NIVEAU 1] Restauration sur la cible (Toulouse) ==='
BACKUP_FILE=$(ls -t ./backups/techcorp_bigbang_*.dump | head -1)
if [ -z "$BACKUP_FILE" ]; then
echo 'ERREUR : aucun fichier de sauvegarde trouve !'
exit 1
fi
echo "Fichier utilise : $BACKUP_FILE"