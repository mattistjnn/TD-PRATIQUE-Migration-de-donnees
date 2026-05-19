#!/bin/bash 
# niveau3_replication/06_bascule_chaud.sh 
 
echo '=== [NIVEAU 3] Bascule a chaud ===' echo "Debut : $(date)" 
 
# 1. Verifier que la replication est a jour 
echo '--- Verification du lag de replication ---' docker exec pg_montpellier psql -U admin -c \ 
  "SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn    FROM pg_stat_replication;" 
 
# 2. Passer la source en lecture seule (coupure minimale) 
docker exec pg_montpellier psql -U admin -d techcorp_db -c \ 
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = on;" echo 'OK : Source en lecture seule' 
 
# 3. Attendre que la replication soit complete sleep 3 
 
# 4. Supprimer la subscription sur la cible 
docker exec pg_toulouse psql -U admin -d techcorp_db -c \ 
  "DROP SUBSCRIPTION sub_techcorp;" echo 'OK : Subscription supprimee' 
 
# 5. Activer la cible en lecture/ecriture 
docker exec pg_toulouse psql -U admin -d techcorp_db -c \ 
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = off;" echo 'OK : Cible activee' 
 
echo "Fin de la bascule : $(date)" 
echo 'OK : Migration avec replication terminee' 
 
# TODO : Mesurer la duree totale de la coupure 
# TODO : Comparer avec les durees des Niveaux 1 et 2 
