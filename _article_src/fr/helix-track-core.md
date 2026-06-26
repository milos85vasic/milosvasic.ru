---
title: HelixTrack Core
slug: helix-track-core
repo: https://github.com/Helix-Track/Core
tech: Go, Gin, PostgreSQL, SQLite, SQLCipher, PLpgSQL, WebSocket
teaser: "The open-source JIRA alternative — extreme-performance issue tracking with military-grade encryption and a single action-routed API."
---

## L’accroche

Imaginez reconstruire JIRA et Confluence de zéro, en un seul microservice Go, et le rendre suffisamment rapide pour gérer des dizaines de milliers de requêtes par seconde avec une base de données chiffrée en arrière-plan. Voici HelixTrack Core : *« L’alternative open source à JIRA pour un monde libre »*. Ce n’est pas un clone jouet – il intègre des épopées, des sous-tâches, des sprints, des journaux de travail, des champs personnalisés, des tableaux de bord, des schémas de permissions et un moteur complet de documents façon Confluence, le tout derrière une seule API REST.

## Pourquoi c’est fascinant

La plupart des outils de suivi de projets finissent par devenir des monolithes tentaculaires, avec des dizaines de points de terminaison qui divergent au fil des années. Moi, j’ai pris le contre-pied. HelixTrack Core expose un unique point de terminaison `/do` avec un **routage basé sur les actions** : les clients envoient une action nommée et une charge utile, et le serveur la distribue via un pipeline cohérent de middlewares et de gestionnaires. Cette seule décision de conception maintient la surface de l’API unifiée sur des centaines d’opérations – tickets, tableaux agiles, votes, schémas de notification, flux d’activité, mentions dans les commentaires – sans l’éparpillement des points de terminaison qui rend les grandes API ingérables.

Au-dessus de cela, une véritable alternative à Confluence. L’extension Documents V2 implémente des espaces, des pages riches en HTML/Markdown/texte brut, un historique complet des versions avec diffs et retour arrière, des commentaires en ligne, des @mentions, des réactions, des modèles et des analyses – le tout soutenu par ses propres tables de base de données et validé par des centaines de tests de modèles. Construire l’un de ces systèmes est un projet ; les construire tous les deux comme modules coopératifs dans un même binaire, voilà ce qui est intéressant.

## Les défis de taille

Trois aspects rendent ce projet véritablement complexe.

Premièrement, **la sécurité sans compromis sur les performances**. Les outils de suivi d’entreprise contiennent des données sensibles, donc la base de données est chiffrée au repos avec SQLCipher (AES-256). Le chiffrement implique généralement un coût en latence – le défi technique consistait à minimiser cette surcharge tout en maintenant des requêtes rapides sous forte concurrence.

Deuxièmement, **la réalité multi-bases de données**. Les développeurs veulent SQLite pour un environnement local sans friction ; la production exige PostgreSQL pour sa concurrence et sa durabilité. Supporter les deux – avec des optimisations au niveau de PLpgSQL et un schéma ayant évolué à travers plusieurs migrations versionnées (de V1 à V4, dépassant désormais quatre-vingt-dix tables) – signifie que chaque fonctionnalité doit fonctionner correctement sur deux moteurs radicalement différents.

Troisièmement, **la collaboration en temps réel avec cohérence**. Dès que plusieurs personnes modifient le même ticket, on se heurte au problème classique de l’état distribué : pertes de mises à jour et conflits d’écriture. Le résoudre sans bloquer les utilisateurs les uns par rapport aux autres exige un modèle de concurrence réfléchi, et non une solution improvisée.

## Ce qui en fait un outil révolutionnaire

HelixTrack Core traite les permissions comme un moteur de premier plan, interchangeable. Il implémente des **permissions hiérarchiques basées sur le contexte**, avec héritage, et son système de permissions est pluggable – vous pouvez l’exécuter localement dans le service ou le déléguer à un service d’autorisation HTTP externe. Cette séparation permet aux organisations d’intégrer le tracker dans une infrastructure d’identité et de politique existante, plutôt que de se battre contre un modèle intégré.

Il fait aussi ce que la plupart des trackers ignorent : **la découverte automatique de services**. Les clients trouvent les serveurs Core sur le réseau local via diffusion UDP, de sorte que les applications multiplateformes (web, bureau, Android, iOS) peuvent se connecter sans configuration manuelle. Combiné à l’authentification par JWT, un système d’extensions pour le suivi du temps, les documents et le chat, ainsi qu’une intégration Git qui lie les commits aux tickets, il se comporte comme une plateforme plutôt que comme une simple application.

## Comment j’ai résolu les problèmes les plus ardus

Pour l’API, j’ai adopté très tôt le **modèle de routage par actions**. Chaque opération passe par le même cycle de vie `/do` – middleware d’authentification et de permissions, puis un gestionnaire indexé par le nom de l’action. C’est pourquoi le système peut ajouter des fonctionnalités (priorités et résolutions en Phase 1, épopées et journaux de travail en Phase 2, votes et schémas de notification en Phase 3, édition parallèle en Phase 4) sans que l’API ne se fragmente. Les nouvelles fonctionnalités enregistrent de nouvelles actions ; le transport et les middlewares restent inchangés.

Pour l’édition concurrente, j’ai mis en place un **verrouillage optimiste avec gestion des conflits de version**, couplé à une couche complète d’historique des modifications. Chaque entité modifiable porte un numéro de version ; une écriture ciblant une version obsolète est rejetée avec un conflit que le client peut résoudre, et les tables d’historique (ajoutées dans le schéma V4) enregistrent l’intégralité des changements. J’ai ajouté une gestion explicite des verrous d’entités et des actions de résolution de conflits, et j’ai intégré le tout à la couche WebSocket existante pour que les collaborateurs voient les mises à jour en temps réel. Cela permet une collaboration instantanée sans écraser silencieusement les modifications d’autrui.

Pour concilier chiffrement et performance, la conception s’appuie sur SQLCipher pour un AES-256 transparent au niveau du stockage, tout en optimisant les chemins critiques via du cache, de sorte que les schémas de lecture courants restent rapides même avec une base chiffrée. Le code est soutenu par une vaste suite de tests automatisés – plus d’un millier de tests répartis sur les différentes phases – ce qui me permet de modifier un schéma de plus de quatre-vingt-dix tables, dans un système chiffré, multi-bases de données et à édition concurrente, tout en ayant confiance dans la stabilité du comportement. Des diagrammes d’architecture, un manuel utilisateur et un guide de déploiement accompagnent le code, car une alternative à JIRA que personne ne peut exploiter n’est pas une alternative.
