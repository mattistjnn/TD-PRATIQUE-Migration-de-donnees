#!/bin/bash
echo '=== [NIVEAU 1] Transfert des fichiers ==='

SOURCE='./data_montpellier/supports/'
CIBLE='./data_toulouse/supports/'

mkdir -p "$CIBLE"

# Copie des fichiers (equivalent rsync basique)
cp -v "$SOURCE"* "$CIBLE"

echo ''
echo '=== Verification du transfert ==='

NB_SOURCE=$(find $SOURCE -type f | wc -l)
NB_CIBLE=$(find $CIBLE -type f | wc -l)

echo "Fichiers source : $NB_SOURCE"
echo "Fichiers cible  : $NB_CIBLE"

if [ $NB_SOURCE -eq $NB_CIBLE ]; then
  echo 'OK : meme nombre de fichiers'
else
  echo 'ERREUR : nombre de fichiers different !'
  exit 1
fi

# Comparaison MD5
echo ''
echo '=== Verification integrite MD5 ==='
md5sum "$SOURCE"* | sort > /tmp/checksums_source.txt
md5sum "$CIBLE"*  | sort > /tmp/checksums_cible.txt
sed -i "s|$SOURCE||g" /tmp/checksums_source.txt
sed -i "s|$CIBLE||g"  /tmp/checksums_cible.txt

diff /tmp/checksums_source.txt /tmp/checksums_cible.txt \
  && echo 'OK : checksums MD5 identiques' \
  || echo 'ERREUR : fichiers corrompus !'
