#!/bin/bash
# niveau1_bigbang/06_rollback.sh
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
# TODO : Vider la base cible pour eviter toute confusion
# TODO : Enregistrer la raison du rollback dans un fichier de log