---
title: Helix-Flow Platform
slug: helix-flow-platform
repo: https://github.com/Helix-Flow/Platform
tech: Go, gRPC, HTTP, TLS 1.3, mTLS, PostgreSQL, SQLite, JWT
teaser: "One OpenAI-compatible gateway for all your AI inference — TLS 1.3, mutual-auth service mesh, predictable costs, drop-in API."
---

## L’accroche

« Une plateforme unique pour tous vos besoins d’inférence IA — exécutez des modèles puissants plus rapidement, plus intelligemment, à n’importe quelle échelle, avec des coûts prévisibles. » Helix-Flow Platform est une passerelle d’inférence IA d’entreprise qui parle l’API OpenAI, permettant à vos clients existants de fonctionner sans modification, tout en s’appuyant sur un maillage de microservices durci et mutuellement authentifié, avec un chiffrement TLS 1.3 de bout en bout.

## Pourquoi c’est fascinant

La promesse de l’inférence IA est simple à formuler, mais brutale à tenir : offrir aux équipes un moyen unique, rapide et sécurisé d’appeler des modèles, sans les enfermer dans les tarifs ou l’environnement d’exécution d’un seul fournisseur. Helix-Flow l’aborde comme une **architecture de microservices de niveau entreprise** — une passerelle API exposant des services indépendants pour l’authentification, un pool d’inférence et la supervision — accessible simultanément en HTTP et en gRPC.

L’essentiel est sa **conformité à la spécification de l’API OpenAI**. Cela signifie que la surface familière — `/v1/models`, `/v1/chat/completions`, l’authentification par jeton Bearer — est présente, de sorte que toute application déjà construite sur l’API OpenAI peut pointer vers Helix-Flow à la place. Vous obtenez un point de terminaison plug-and-play, mais avec votre propre authentification, votre propre supervision et vos propres contrôles de coûts en arrière-plan.

## Les défis majeurs

Le défi central réside dans la **sécurité au niveau du maillage de services, et pas seulement en périphérie**. Il est facile de mettre en place TLS sur un point de terminaison public ; il est bien plus difficile de chiffrer et d’authentifier chaque saut *entre* les services internes. Helix-Flow construit une PKI complète et utilise TLS 1.3 avec **mTLS (TLS mutuel)** sur l’ensemble de son maillage gRPC, de sorte que les services s’authentifient mutuellement, et pas seulement vis-à-vis du monde extérieur. Cela nécessite une gestion automatisée des certificats — génération, distribution et rotation — car un maillage sécurisé manuellement ne résiste pas au contact de la production.

Le deuxième défi majeur est la **parité entre les deux protocoles**. Proposer à la fois une passerelle HTTP et une passerelle gRPC implique que les mêmes fonctionnalités doivent être correctement implémentées sur deux transports très différents, avec une authentification et un comportement cohérents. Les équipes préférant REST et celles optant pour le gRPC haute performance doivent pouvoir utiliser la même plateforme.

Le troisième défi est la **prévisibilité des coûts et l’exploitabilité**. La promesse de « coûts prévisibles » ne tient que si la plateforme intègre une supervision réelle, une limitation de débit et un journal d’audit — afin que les dépenses et les comportements soient observables et maîtrisés, plutôt que de constituer une mauvaise surprise en fin de mois.

## Ce qui en fait une révolution

Helix-Flow parie sur le fait que l’inférence IA doit devenir **de l’infrastructure**, et non une intégration par application. En présentant une API compatible OpenAI devant un pool d’inférence agnostique vis-à-vis des fournisseurs, elle permet à une organisation de centraliser la manière dont elle appelle les modèles : une seule passerelle, un seul modèle d’authentification, un seul endroit pour appliquer les limitations de débit, une seule piste d’audit. Changer ou ajouter des backends de modèles devient une décision d’infrastructure, et non une modification de code dispersée dans chaque application cliente.

Et cela, sans sacrifier les fondamentaux de l’entreprise : validation des JWT, limitation de débit, journalisation des audits, gestion élégante des erreurs et un backend multi-bases de données (SQLite pour le développement, PostgreSQL pour la production). Ainsi, la plateforme peut passer d’un ordinateur portable à un cluster sans modifier le contrat sur lequel s’appuient les clients.

## Comment j’ai résolu les problèmes les plus ardus

J’ai intégré la sécurité dès les fondations, plutôt que de l’ajouter après coup. La plateforme embarque une **PKI complète avec TLS 1.3 et mTLS**, et le provisionnement des certificats est automatisé, permettant au maillage de services de s’authentifier sans manipulation manuelle des certificats. Chaque saut gRPC interne est mutuellement authentifié ; la passerelle termine le trafic externe en TLS et valide les JWT avant que quoi que ce soit n’atteigne le pool d’inférence. La sécurité est une propriété intrinsèque du maillage, et non une couche ajoutée par-dessus.

Pour le support des deux protocoles, j’ai conçu la **passerelle API pour servir HTTP et gRPC côte à côte**, les services les plus lourds — authentification et pool d’inférence — étant exposés en gRPC pour les performances, tandis que l’interface publique reste accessible en HTTP pour la compatibilité. Cette séparation permet aux appels internes sensibles à la latence d’utiliser gRPC, tandis que les clients externes conservent l’interface REST simple et familière de type OpenAI.

Pour l’exploitabilité et la promesse de « coûts prévisibles », j’ai fait du **service de supervision un composant de premier plan**, au même titre que l’authentification et l’inférence, en y intégrant des vérifications d’état, la collecte de métriques, la limitation de débit et la journalisation des audits. Ainsi, l’utilisation et la santé du système sont visibles et maîtrisées par défaut. Le design multi-bases de données — SQLite pour des exécutions locales sans friction, PostgreSQL pour la production — permet à la même plateforme de valider son fonctionnement sur une seule machine avant de monter en charge, ce qui est précisément ce qu’une plateforme d’inférence « à n’importe quelle échelle » doit pouvoir faire.
