#!/bin/bash 
# niveau3_replication/03_structure_cible.sh 
 
echo '=== [NIVEAU 3] Creation de la structure sur la cible ===' 
 
# Exporter uniquement le schema (sans les donnees) 
docker exec pg_montpellier pg_dump \ 
  -U admin -d techcorp_db \ 
  --schema-only --no-owner \ 
  -f /tmp/schema_only.sql 
 
docker cp pg_montpellier:/tmp/schema_only.sql ./backups/schema_only.sql 
 
# Appliquer le schema sur la cible 
docker cp ./backups/schema_only.sql pg_toulouse:/tmp/schema_only.sql 
docker exec pg_toulouse psql -U admin -d techcorp_db -f /tmp/schema_only.sql 
 
echo 'OK : Structure creee sur la cible' docker exec pg_toulouse psql -U admin -d techcorp_db -c '\dt' 
 
# Verifier que les tables sont vides (pas encore de donnees) 
docker exec pg_toulouse psql -U admin -d techcorp_db -c \   'SELECT COUNT(*) AS nb_utilisateurs FROM utilisateurs;' 
