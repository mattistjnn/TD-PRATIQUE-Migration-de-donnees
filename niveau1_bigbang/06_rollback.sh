#!/bin/bash
echo '=== [NIVEAU 1] ROLLBACK – Retour a Montpellier ==='
echo 'ATTENTION : Cette operation annule la migration !'

read -p 'Confirmer le rollback ? (oui/non) : ' CONFIRM
if [ "$CONFIRM" != 'oui' ]; then
  echo 'Rollback annule.'
  exit 0
fi

# Remettre la base source en lecture/ecriture
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = off;"
echo 'OK : Base source remise en lecture/ecriture'
echo 'OK : Le service peut reprendre sur Montpellier'

# Vider la base cible pour eviter toute confusion
echo ''
echo '--- Vidage de la base cible (Toulouse) ---'
docker exec pg_toulouse psql -U admin -d techcorp_db -c \
  "DROP SCHEMA public CASCADE; CREATE SCHEMA public; GRANT ALL ON SCHEMA public TO admin;"
echo 'OK : Base cible videe'

# Enregistrer la raison du rollback
mkdir -p logs
read -p 'Raison du rollback : ' RAISON
echo "[$(date '+%Y-%m-%d %H:%M:%S')] ROLLBACK effectue - Raison : $RAISON" >> logs/rollback.log
echo "OK : Raison enregistree dans logs/rollback.log"
cat logs/rollback.log
