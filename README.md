# TD-PRATIQUE-Migration-de-donnees

# 🚀 Projet de Migration d'Infrastructure - TechCorp Formation

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)
![Bash](https://img.shields.io/badge/GNU%20Bash-4EAA25?style=for-the-badge&logo=GNU%20Bash&logoColor=white)

## 📋 Description du Projet

Ce projet a été réalisé dans le cadre de la modernisation de l'infrastructure de **TechCorp Formation**, une entreprise proposant des cours en ligne. L'objectif principal était de migrer l'ensemble des données et des services depuis le data center vieillissant de Montpellier vers un nouveau data center sécurisé à Toulouse.

Nous avons simulé, testé et comparé trois stratégies de migration de base de données PostgreSQL afin de déterminer la plus adaptée aux contraintes métiers (fenêtre de coupure de 2 heures maximum, garantie de non-perte de données, et bande passante de 200 Mbps).

## 🛠️ Stratégies Évaluées

1. **Niveau 1 : Big Bang** 💥
   - Arrêt total du service, export complet (`pg_dump`), transfert et import.
   - _Résultat_ : Temps de coupure trop long et risqué pour la production.
2. **Niveau 2 : Migration Progressive** 🔄
   - Pré-synchronisation des données et fichiers en amont, suivie d'une courte coupure pour le transfert du différentiel (delta).
   - _Résultat_ : Temps de coupure maîtrisé (~30 min), processus sécurisé avec rollback facile. **(Stratégie recommandée)**
3. **Niveau 3 : Réplication Logique** ⚡
   - Utilisation des mécanismes natifs de PostgreSQL (`PUBLICATION` / `SUBSCRIPTION`) pour une synchronisation en temps réel.
   - _Résultat_ : Temps de coupure quasi nul (~4 secondes mesurées) mais mise en œuvre plus complexe.

## 🎯 Conclusion de l'équipe

Mission accomplie ! L'équipe a mené à bien l'ensemble des tests et a fourni un plan de migration complet. Après analyse des résultats de nos scripts, nous recommandons la méthode **Progressive (Niveau 2)**. Elle offre le meilleur compromis entre la réduction du temps de coupure, la simplicité de mise en œuvre et la sécurité des données grâce à sa procédure de rollback robuste.

## 👨‍💻 Équipe Projet

Ce projet a été mené avec succès grâce à la collaboration de notre équipe d'experts en infrastructure :

- **Magyd Baroni**
- **Omar Diallo Bachir**
- **Filda Nzuzi Ngoma**
- **Anderson Kouadio**
- **Mattis Tajan**

---

_Projet réalisé dans le cadre du module ASRBD / Tests d'intégration & Migration de données._
