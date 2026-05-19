#!/bin/bash
# niveau2_progressive/04_coupure_finale.sh
echo '=== [NIVEAU 2] COUPURE – Synchronisation finale ==='
echo "Debut de la fenetre de coupure : $(date)" | tee logs/coupure_n2.log

# 1. Passer la source en lecture seule
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "ALTER DATABASE techcorp_db SET default_transaction_read_only = on;"
echo 'OK : Source en lecture seule'

# 2. Dernière synchronisation des fichiers
rsync -avh --checksum --delete \
  ./data_montpellier/supports/ \
  ./data_toulouse/supports/
echo 'OK : Fichiers synchronises'

# 3. Dernier export de la base
docker exec pg_montpellier pg_dump \
  -U admin -d techcorp_db \
  --format=custom -f /tmp/sync_finale.dump
docker cp pg_montpellier:/tmp/sync_finale.dump ./backups/sync_finale.dump
echo 'OK : Export final cree'

# 4. Restauration finale sur la cible
docker cp ./backups/sync_finale.dump pg_toulouse:/tmp/sync_finale.dump
docker exec pg_toulouse pg_restore \
  -U admin -d techcorp_db \
  --clean --if-exists -v \
  /tmp/sync_finale.dump
echo 'OK : Restauration finale terminee'

echo "Fin de la synchronisation finale : $(date)" | tee -a logs/coupure_n2.log

# Calculer et afficher la durée de la coupure
DEBUT=$(head -1 logs/coupure_n2.log | awk '{print $NF, $(NF-1), $(NF-2), $(NF-3)}')
echo "Coupure terminee — voir logs/coupure_n2.log pour la duree"

# Vérifier que les comptages source = cible avant de basculer
SOURCE=$(docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;' | tr -d ' ')
CIBLE=$(docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;' | tr -d ' ')

if [ "$SOURCE" = "$CIBLE" ]; then
  echo "OK : Comptages identiques ($SOURCE) – bascule autorisee"
else
  echo "ERREUR : Source=$SOURCE / Cible=$CIBLE – bascule annulee"
  exit 1
fi