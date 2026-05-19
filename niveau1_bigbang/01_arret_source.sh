#!/bin/bash
echo '=== [NIVEAU 1] Arret du service source ==='
echo "Heure de debut de coupure : $(date)" | tee logs/coupure_debut.log

docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = on;"

echo 'OK : Base source passee en lecture seule'

echo '--- Transactions actives ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT pid, usename, state, query FROM pg_stat_activity WHERE state = 'active';"