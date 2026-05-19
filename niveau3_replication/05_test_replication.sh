#!/bin/bash
# niveau3_replication/05_test_replication.sh

echo '=== [NIVEAU 3] Test de la replication en temps reel ==='

echo '--- Avant insertion ---'
echo -n 'Source : '
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'
echo -n 'Cible : '
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'

# Inserer un nouvel utilisateur sur la SOURCE
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "INSERT INTO utilisateurs (nom, email)
  VALUES ('Test Replication', 'test.replication@techcorp.fr');"

sleep 2

echo '--- Apres insertion (2 secondes plus tard) ---'
echo -n 'Source : '
docker exec pg_montpellier psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'
echo -n 'Cible : '
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'

echo 'Si les deux comptages sont identiques, la replication fonctionne !'

# Tester une UPDATE
echo '--- Test UPDATE ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "UPDATE utilisateurs SET nom = 'Test Replication MAJ' WHERE email = 'test.replication@techcorp.fr';"

sleep 2

echo -n 'Cible apres UPDATE : '
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  "SELECT nom FROM utilisateurs WHERE email = 'test.replication@techcorp.fr';"

# Tester une DELETE
echo '--- Test DELETE ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "DELETE FROM utilisateurs WHERE email = 'test.replication@techcorp.fr';"

sleep 2

echo -n 'Cible apres DELETE (doit etre 5) : '
docker exec pg_toulouse psql -U admin -d techcorp_db -t -c \
  'SELECT COUNT(*) FROM utilisateurs;'

# Mesurer le delai de replication (lag)
echo '--- Delai de replication (lag) sur la source ---'
docker exec pg_montpellier psql -U admin -d techcorp_db -c \
  "SELECT * FROM pg_stat_replication;"
