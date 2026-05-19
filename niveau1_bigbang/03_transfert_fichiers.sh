#!/bin/bash
# niveau1_bigbang/03_transfert_fichiers.sh
echo '=== [NIVEAU 1] Transfert des fichiers ==='
SOURCE='./data_montpellier/supports/'
CIBLE='./data_toulouse/supports/'
# Options rsync :
# -a : mode archive (preserve permissions, dates, liens symboliques)
# -v : verbose (affiche les fichiers transferes)
# -h : tailles lisibles (Ko, Mo, Go)
# --progress : affiche la progression fichier par fichier
# --checksum : verifie l'integrite par checksum (plus sur)
rsync -avh --progress --checksum $SOURCE $CIBLE
echo ''
echo '=== Verification du transfert ==='
NB_SOURCE=$(find $SOURCE -type f | wc -l)
NB_CIBLE=$(find $CIBLE -type f | wc -l)
echo "Fichiers source : $NB_SOURCE"
echo "Fichiers cible : $NB_CIBLE"
if [ $NB_SOURCE -eq $NB_CIBLE ]; then
echo 'OK : meme nombre de fichiers'
else
echo 'ERREUR : nombre de fichiers different !'
exit 1
fi
# TODO : Ajouter une comparaison des checksums MD5
# Indice : md5sum data_montpellier/supports/* > checksums_source.txt
# md5sum data_toulouse/supports/* > checksums_cible.txt
# diff checksums_source.txt checksums_cible.txt