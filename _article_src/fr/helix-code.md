---
title: HelixCode
slug: helix-code
repo: https://github.com/HelixDevelopment/HelixCode
tech: Go, PostgreSQL, Redis, SSH, MCP, WebSocket, Gin
teaser: "A distributed AI coding agent that splits work across an SSH worker network, checkpoints everything, and never loses progress on a crash."
---

## L’hameçon

Et si votre agent de codage IA ne s’exécutait pas sur une seule machine, mais à travers un réseau de travailleurs qu’il provisionne lui-même — découpant une tâche complexe en fragments, les distribuant, et sauvegardant régulièrement l’avancement pour qu’un plantage ne fasse jamais perdre le travail accompli ? Voici HelixCode : une plateforme de développement IA distribuée de niveau entreprise, écrite en Go, avec des pools de travailleurs basés sur SSH, une sauvegarde automatique, un retour en arrière, et une intégration multi-fournisseurs de LLM.

## Pourquoi c’est fascinant

La plupart des « agents de codage IA » ne sont qu’un seul processus dialoguant avec un seul modèle. HelixCode repose sur l’idée que le travail de développement réel est divisible et distribuable. Il réalise une **division intelligente des tâches** avec gestion des dépendances, puis préserve le travail grâce à une sauvegarde automatique, permettant à une tâche de longue durée de survivre à une interruption. La plateforme s’expose via quatre interfaces client — API REST, CLI, une interface terminal et WebSocket — et implémente le **Model Context Protocol (MCP)** avec prise en charge multi-transports, ce qui lui permet de s’intégrer à l’écosystème plus large des outils d’agents.

Elle est également véritablement multiplateforme dans un sens inhabituellement large : Linux, macOS, Windows, ainsi qu’Aurora OS et SymphonyOS, avec des frameworks en préparation pour iOS et Android. Le dépôt combine un cœur en Go entouré de Shell, Kotlin, Swift et d’actifs web — la structure d’une plateforme conçue pour être pilotée depuis n’importe où.

## Les défis ardus

Le défi central est celui de la **distribution sans fragilité**. Dès que l’on répartit une tâche de codage entre des travailleurs distants, on hérite de tous les problèmes complexes des systèmes distribués : comment diviser le travail en respectant les véritables frontières de dépendance, comment suivre quel travailleur possède quelle partie, comment se rétablir lorsqu’un travailleur disparaît en cours de tâche, et comment fusionner les résultats de manière cohérente.

La gestion des travailleurs constitue un problème à part entière. HelixCode ne suppose pas l’existence d’un cluster préconstruit — il propose un **pool de travailleurs SSH avec installation automatique**, ce qui signifie qu’il doit atteindre un hôte distant, s’y installer, enregistrer le travailleur et surveiller son état de santé, le tout de manière sécurisée via SSH. Rendre ce déploiement fiable sur des machines hétérogènes est bien plus difficile qu’il n’y paraît.

Vient ensuite la couche LLM. Prendre en charge plusieurs fournisseurs derrière une seule interface, détecter le matériel (CPU/GPU/mémoire) pour choisir les modèles de manière intelligente, et superposer des raisonnements avancés — chaîne de pensée et arbre de pensées — signifie que l’agent doit raisonner sur le *où* et le *avec quoi* il s’exécute, et pas seulement sur le *quoi* générer.

## Ce qui en fait un changement de jeu

La combinaison de la **préservation du travail et du retour en arrière** fait toute la différence. Un agent IA capable de reprendre exactement là où il s’est arrêté, et d’annuler une modification erronée, transforme les longues exécutions autonomes d’un pari risqué en un processus maîtrisable. HelixCode associe cela à des modes complets de workflow de développement — planification, construction, test et refactoring — soutenus par des projets persistés en base de données et un suivi de contexte multi-sessions. Ce n’est pas simplement « générer du code » ; c’est un cycle de vie complet.

L’implémentation du MCP compte également. En parlant le Model Context Protocol avec plusieurs transports, HelixCode peut agir à la fois comme consommateur et acteur dans l’univers des outils d’agents, et ses notifications multi-canaux (Slack, Discord, Email, Telegram) permettent à une exécution distribuée de rendre compte de son avancement là où les humains surveillent réellement.

## Comment j’ai résolu les parties les plus difficiles

J’ai structuré le système en modules internes clairs — gestion de l’authentification et des sessions, gestion du pool de travailleurs, gestion des tâches et des sauvegardes, gestion des projets et des workflows, et intégration des fournisseurs de LLM — chacun résidant dans son propre paquet. Cette séparation est ce qui rend le comportement distribué gérable : la division des tâches et la sauvegarde sont des préoccupations que je peux appréhender indépendamment du fournisseur de LLM ou du transport utilisé.

Pour le réseau de travailleurs, j’ai construit le **pool de travailleurs SSH à auto-installation**. Plutôt que d’exiger des opérateurs qu’ils préparent chaque nœud, la plateforme se connecte via SSH, installe ce dont elle a besoin, enregistre le travailleur, puis surveille en continu son état de santé. Cette surveillance alimente en retour la gestion des tâches, permettant de réaffecter le travail lorsqu’un nœud montre des signes de défaillance.

Pour la résilience, la **sauvegarde est l’épine dorsale**. La gestion des tâches écrit des points de contrôle au fur et à mesure de l’avancement, de sorte qu’une tâche interrompue reprend à partir de son dernier état valide au lieu de redémarrer, et le retour en arrière peut annuler une étape erronée. C’est ce mécanisme qui rend les longues exécutions distribuées et autonomes sûres à tenter.

Pour la couche modèle, j’ai placé chaque fournisseur derrière une **interface unifiée** et ajouté une détection matérielle pour que l’agent adapte le choix du modèle à la machine qui l’exécute réellement. Par-dessus cette interface, j’ai superposé l’appel d’outils et les raisonnements en chaîne de pensée et en arbre de pensées, de sorte qu’améliorer la stratégie de raisonnement ne nécessite pas de toucher à la plomberie des fournisseurs. La couche de persistance repose sur PostgreSQL avec Redis en option, ce qui maintient les projets, les sessions et l’état des workflows durables à travers toute la flotte distribuée — la différence entre une démonstration astucieuse et une plateforme sur laquelle on peut vraiment compter.
