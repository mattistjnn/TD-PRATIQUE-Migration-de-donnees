# Niveau 2 – Migration Progressive

**Contexte** : Migration de TechCorp Formation du data center de Montpellier (SOURCE, port 5432) vers Toulouse (CIBLE, port 5433), simulée avec deux containers PostgreSQL via Docker.

---

## Phase d'analyse obligatoire

### A1 – Inventaire de la base de données
| Table | Nb lignes | Dépend de | Critique ? |
|---|---|---|---|
| `utilisateurs` | 5 | — | Oui (référencée par toutes les autres tables) |
| `formations` | 4 | — | Oui (référencée par toutes les autres tables) |
| `progressions` | 6 | `utilisateurs` + `formations` | Oui |
| `resultats_examens` | 3 | `utilisateurs` + `formations` | Oui |

Taille de la base source : ~8 Ko (environnement simulé)

### A2 – Inventaire des fichiers
| Fichier | Type | Taille | Critique ? |
|---|---|---|---|
| `excel_module1.pdf` | PDF | 33 octets | Non |
| `cyber_intro.pdf` | PDF | 38 octets | Non |
| `gestion_methodes.pdf` | PDF | 38 octets | Non |
| `linux_video1.mp4` | Vidéo | 34 octets | Non |
| `logo.png` | Image | 21 octets | Non |
| **Total** | | **164 octets** | |

### A3 – Identification des contraintes
| Contrainte | Réponse |
|---|---|
| Bande passante disponible | Réseau Docker local (bridge), pas de limitation réelle |
| Durée maximale de coupure | 2 heures (fenêtre de maintenance) |
| Disponibilité requise | Dès la fin de la fenêtre de coupure |
| Tables à ordre imposé | `progressions` et `resultats_examens` dépendent de `utilisateurs` et `formations` |
| Si on migre `progressions` avant `utilisateurs` | Erreur de clé étrangère — la FK vers `utilisateurs.id` n'existe pas encore |

### A4 – Ordre de migration des tables
| Ordre | Table | Raison |
|---|---|---|
| 1 | `utilisateurs` | Aucune dépendance |
| 2 | `formations` | Aucune dépendance |
| 3 | `progressions` | Dépend de `utilisateurs` et `formations` |
| 4 | `resultats_examens` | Dépend de `utilisateurs` et `formations` |

---

## Résultats obtenus

### Comptages avant/après migration
| Table | Source (avant) | Cible (après migration) |
|---|---|---|
| `utilisateurs` | 7 | 7 |
| `formations` | 4 | 4 |
| `progressions` | 6 | 6 |
| `resultats_examens` | 4 | 4 |

### Durée de coupure mesurée
| Événement | Heure |
|---|---|
| Début coupure | 12:28:28 |
| Fin synchronisation finale | 12:28:29 |
| Fin bascule complète | 12:29:22 |
| **Durée totale** | **54 secondes** |

---

## Réponses aux questions d'analyse

**1. Comparez la durée de coupure entre le Niveau 1 et le Niveau 2.**
Le Niveau 1 (Big Bang) effectue l'export et la restauration complète pendant la coupure, ce qui peut prendre plusieurs dizaines de minutes sur une base de production volumineuse. Le Niveau 2 réduit la coupure à 54 secondes car l'essentiel des données est synchronisé en amont. Le service est donc indisponible beaucoup moins longtemps.

**2. Pourquoi l'option `--delete` de rsync est-elle importante lors de la synchronisation finale ?**
Sans `--delete`, les fichiers supprimés côté source resteraient présents sur la cible. La cible ne serait pas un miroir exact de la source, ce qui pourrait laisser des fichiers obsolètes ou orphelins en production.

**3. Que se passe-t-il si un utilisateur s'inscrit entre la sync initiale et la coupure ?**
Ses données existent sur la source mais pas encore sur la cible. C'est le décalage qu'on a simulé avec François et Gaëlle (2 utilisateurs ajoutés après la sync initiale). Ce delta est rattrapé lors de la synchronisation finale pendant la coupure.

**4. Pourquoi vérifie-t-on les comptages AVANT de basculer ?**
Pour s'assurer que toutes les données ont bien été transférées avant de rediriger le trafic vers la cible. Si les comptages divergent, on effectue un rollback plutôt que de basculer sur une base incomplète, ce qui évite toute perte de données.

**5. Dans quel cas la migration progressive ne suffit-elle pas ?**
Quand la base est trop volumineuse ou trop active pour qu'une coupure de quelques secondes suffise à rattraper le delta. Par exemple, une base recevant des milliers d'insertions par seconde accumulerait trop de changements pendant la fenêtre de coupure. Dans ce cas, la réplication logique (Niveau 3) est nécessaire pour une bascule à chaud sans interruption.

---

## Partie du tableau comparatif (N2)
| Critère | Progressive (N2) |
|---|---|
| Durée de coupure mesurée | **54 secondes** |
| Complexité de mise en œuvre | Moyenne |
| Risque de perte de données | Moyen |
| Rollback possible ? | Oui |
| Adapté à 2h de coupure ? | Oui (largement) |
| Outils utilisés | `pg_dump` + `rsync` |
| Recommandé pour ce projet ? | Oui, bon compromis simplicité/disponibilité |

---

## Conclusion (N2)
La migration progressive est une approche efficace pour TechCorp Formation. En synchronisant l'essentiel des données avant la coupure, elle réduit l'interruption de service à moins d'une minute, bien en deçà de la fenêtre de 2 heures autorisée. Elle est plus complexe qu'un Big Bang mais nettement moins risquée, car le rollback reste possible à tout moment. Pour une base de la taille de TechCorp (quelques milliers d'enregistrements), c'est la méthode la mieux adaptée : simple à mettre en œuvre avec des outils standards (`pg_dump`, `rsync`), fiable, et sans nécessiter une infrastructure de réplication permanente.