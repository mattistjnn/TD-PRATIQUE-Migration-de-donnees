#!/bin/bash

echo '=== [NIVEAU 1] ROLLBACK – Retour a Montpellier ==='
echo 'ATTENTION : Cette operation annule la migration !'
read -p 'Confirmer le rollback ? (oui/non) : ' CONFIRM

if [ "$CONFIRM" != 'oui' ]; then
  echo 'Rollback annule.'
  exit 0
fi

docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = off;"
echo 'OK : Base source remise en lecture/ecriture'

echo 'Nettoyage de la base cible...'
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "DROP TABLE IF EXISTS resultats_examens, progressions, formations, utilisateurs CASCADE;"
echo 'OK : Base cible videe'

echo "Rollback effectue le : $(date)" >> logs/rollback.log
read -p 'Raison du rollback : ' RAISON
echo "Raison : $RAISON" >> logs/rollback.log
echo 'OK : Raison enregistree dans logs/rollback.log'

echo 'OK : Le service peut reprendre sur Montpellier'