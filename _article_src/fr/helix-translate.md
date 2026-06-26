---
title: HelixTranslate
slug: helix-translate
repo: https://github.com/HelixDevelopment/HelixTranslate
tech: Go, HTTP/3, WebSocket, REST, SSH, LLM providers
teaser: "Translate an entire ebook into any language — over a verified-best LLM, streamed live over WebSocket, with no silent local fallbacks."
---

## L’accroche

Donnez-lui un livre dans n’importe quel format, indiquez une langue cible, et HelixTranslate se charge du reste : il achemine votre texte vers le meilleur *LLM vérifié* disponible, diffuse l’avancement en temps réel sur un tableau de bord interactif, et refuse catégoriquement de sacrifier la qualité en silence. C’est un outil de traduction d’ebooks universel, haute performance et de niveau entreprise, doté d’une API REST, d’une prise en charge HTTP/3 et d’événements WebSocket en temps réel.

## Pourquoi c’est fascinant

Les outils de traduction classiques vous obligent à choisir un fournisseur en espérant qu’il sera à la hauteur aujourd’hui. HelixTranslate inverse cette logique. Son parcours par défaut est **sélectionné par pont** : il puise dans le modèle API le plus performant et vérifié – assorti d’une chaîne de repli classée par score – automatiquement, grâce à une intégration avec mon projet LLMsVerifier. Vous ne choisissez pas de fournisseur ; le système opte pour le meilleur actuellement prouvé, et bascule vers une liste classée en cas d’échec du premier choix.

Autour de ce noyau s’articule un **système de surveillance en temps réel** complet : un hub WebSocket diffuse en direct l’avancement, les événements et les erreurs vers un tableau de bord web, gère plusieurs sessions de traduction simultanées avec des identifiants uniques, et prend en charge les connexions multi-clients avec reconnexion automatique. Vous pouvez suivre la traduction d’un long livre paragraphe par paragraphe, au lieu de fixer un terminal bloqué. Il communique avec de nombreux fournisseurs – OpenAI, Anthropic, DeepSeek, Zhipu, Qwen, Gemini, et bien d’autres – tous accessibles via une découverte vérifiée.

## Les défis complexes

Le premier défi majeur est **l’honnêteté face à l’échec**. La solution de facilité, quand une clé API est manquante ou qu’un fournisseur tombe en panne, consiste à basculer discrètement vers un modèle local faible et à faire semblant que tout va bien. Résultat : des traductions médiocres qui semblent réussies. J’ai fait le choix inverse, une règle intangible : sans clé API de fournisseur configurée, le pont renvoie une erreur franche – jamais de repli local silencieux. Appliquer cette contrainte de manière cohérente sur l’ensemble du pipeline relève d’une décision de conception, pas d’une simple vérification en une ligne.

Le deuxième défi est **la traduction distribuée via SSH**. Traduire de gros livres en série est lent, alors le système prend en charge des travailleurs distants SSH – connexion sécurisée, répartition des tâches de traduction, suivi de l’avancement côté distant, et gestion des erreurs et des replis. Coordonner ces travailleurs distants tout en émettant des événements temps réel cohérents vers le tableau de bord est le genre d’intégration qui se brise de cent façons différentes.

Le troisième défi est **l’événementiel temps réel bien conçu**. Diffuser en direct l’avancement de plusieurs sessions concurrentes vers plusieurs clients du tableau de bord – avec reconnexion, historique des sessions et suivi par session – est un véritable problème d’architecture WebSocket, pas une simple barre de progression.

## Ce qui en fait un outil révolutionnaire

La stratégie du *modèle vérifié le plus performant* est l’idée à retenir. Plutôt que de s’en remettre à un choix de fournisseur statique, HelixTranslate s’appuie en continu sur une vérification externe pour acheminer les requêtes vers ce qui *fonctionne réellement*, avec une chaîne de repli déterministe en cas d’échec. Cela transforme la question *« Quel LLM utiliser pour la traduction ? »* d’une devinette en une décision mesurée et automatique – et signifie que l’outil s’améliore à mesure que le paysage des modèles sous-jacents évolue, sans modification du code.

Il est aussi délibérément ciblé. À un moment donné, le projet prenait en charge des fournisseurs en exécution locale et une voie SSH locale ; lors d’une phase ultérieure du pont, j’ai **supprimé** les fournisseurs en exécution locale (Ollama, LlamaCpp) ainsi que la voie de traduction SSH locale. Les sélectionner renvoie désormais une erreur honnête *« plus pris en charge »* plutôt que d’exécuter un modèle local dégradé. C’est le même principe d’honnêteté appliqué à la feuille de route : je préfère supprimer une fonctionnalité que de la laisser produire discrètement des résultats de moindre qualité.

## Comment j’ai résolu les parties les plus ardues

La pierre angulaire architecturale est le **paquet pont** (`pkg/bridge`), qui relie la traduction à LLMsVerifier. Plutôt que de coder en dur des préférences de fournisseurs, le traducteur demande au pont le modèle vérifié le plus performant et une chaîne de repli classée, puis traduit en fonction de ceux-ci. C’est ce qui rend concrète l’idée *« vous n’avez pas à choisir de fournisseur »*, et c’est là que la règle du *pas de repli silencieux* est appliquée – le pont renvoie une erreur explicite au lieu de substituer un modèle local.

Pour la surveillance en temps réel, j’ai séparé les responsabilités en paquets dédiés : un hub `websocket` gérant les connexions et la diffusion, un système `events` définissant et émettant le flux d’événements, et un paquet `sshworker` pour l’exécution distante. Un serveur de surveillance autonome consomme le flux WebSocket et pilote le tableau de bord, de sorte que l’exécution des traductions et la surveillance sont découplées – la CLI émet des événements, le serveur les redistribue, et un nombre illimité de clients du tableau de bord s’y abonnent avec reconnexion automatique.

Pour la distribution, la couche des travailleurs SSH gère la connexion sécurisée et l’exécution distante tout en renvoyant l’avancement via le même système d’événements, si bien qu’une traduction distante apparaît identique à une traduction locale du point de vue du tableau de bord. L’ensemble est exposé via une API REST avec prise en charge HTTP/3 et s’appuie sur une suite de tests complète pour la surveillance WebSocket – car un système de traduction que l’on ne peut pas observer est un système de traduction auquel on ne peut pas se fier.
