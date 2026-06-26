---
title: ShareConnect
slug: share-connect
repo: https://github.com/vasic-digital/ShareConnect
tech: Kotlin
teaser: "Share any media link from your phone straight to your own download stack — 20 production-ready apps, eight things kept in sync across all of them."
---

## L’accroche

Vous tombez sur une vidéo, un torrent, un fichier à conserver — sur votre téléphone, dans un navigateur, dans une discussion. Puis vient la friction : copier le lien, changer d’appareil, trouver le bon client, coller, configurer, espérer. ShareConnect supprime tout cela. Il s’intègre au menu de partage natif d’Android pour que toute URL téléchargeable atterrisse directement sur *votre* infrastructure — MeTube, YT-DLP, qBittorrent, Transmission, jDownloader et bien d’autres — reliant la découverte de contenu à vos propres services de téléchargement. Le nom résume la thèse : **partage** rencontre **connexion**.

## Pourquoi c’est fascinant

ShareConnect n’est pas une simple application ; c’est un écosystème de 20 applications Android prêtes pour la production, déployées selon un plan délibéré en trois phases. La phase une constitue le cœur : le ShareConnector principal, accompagné de clients dédiés pour qBittorrent, Transmission et uTorrent. La phase deux ajoute huit services cloud — JDownloader (via l’API MyJDownloader), MeTube, YT-DLP (supportant plus de 1 800 sites de streaming), Nextcloud, FileBrowser, Plex, Jellyfin et Emby. La phase trois complète le tout avec huit services spécialisés, dont Seafile, Syncthing, Matrix, Paperless-NG, Duplicati, WireGuard, un contrôleur de serveur Minecraft et OnlyOffice.

L’ingénierie la plus captivante réside cependant dans la couche de synchronisation sous-jacente. ShareConnect maintient huit éléments distincts synchronisés entre toutes les applications de l’écosystème : thème, profils, historique, flux RSS, signets, préférences, langue et état de partage des torrents. Ainsi, votre thème sur l’application principale est le même sur qBitConnect ; votre historique de téléchargement vous suit partout ; vos profils restent cohérents. Vingt applications qui se comportent comme un seul produit.

## Les défis majeurs

Le premier défi réside dans l’ampleur des intégrations. Chaque backend — qBittorrent, Transmission, jDownloader, Plex, Jellyfin, Nextcloud, Matrix, Syncthing — possède sa propre API, son modèle d’authentification et ses particularités. Développer 20 clients capables de communiquer correctement avec leur cible respective, tout en partageant suffisamment de structure commune pour rester maintenables, relève autant de la discipline que de la programmation.

Le deuxième défi est la synchronisation inter-applications elle-même. Synchroniser huit catégories d’état entre plusieurs applications Android installées séparément implique de résoudre de véritables questions de systèmes distribués, sur un seul appareil et au-delà : comment des applications indépendantes se découvrent-elles, s’accordent-elles sur un état partagé et réconciliant-elles les modifications sans se marcher dessus ? Thème, profils, historique, RSS, signets, préférences, langue et partage de torrents ont chacun des schémas de mise à jour et des sémantiques de conflit différents.

Le troisième défi consiste à prouver que tout fonctionne. Avec 20 applications et une couche de synchronisation partagée, la surface de test est immense — et le projet ne recule pas : il affiche 100 % de réussite aux tests unitaires, d’instrumentation et d’automatisation, ainsi qu’un passage QA assisté par IA, une note A+ sur SonarQube, aucune vulnérabilité critique selon Snyk, une couverture de code d’environ 95 % et un ratio de dette technique de 0,2 %. Maintenir ce niveau d’exigence sur l’ensemble d’un écosystème est le défi que la plupart des projets évitent discrètement.

## Ce qui en fait un changement de jeu

Le véritable atout, c’est la commodité de l’auto-hébergement sans compromis. Les fonctionnalités commerciales « envoyer vers mes appareils » vous enferment dans le cloud de quelqu’un d’autre. ShareConnect dirige cette simplicité en un seul geste vers une infrastructure *que vous possédez* — votre client torrent, votre serveur multimédia, votre Nextcloud — et la rend native sur Android. Il transforme une collection dispersée de services auto-hébergés en une surface unique, cohérente et partageable.

Et comme la couche de synchronisation en est le tissu conjonctif, l’écosystème évolue avec élégance : un client compagnon comme qBitConnect ou TransmissionConnect n’est pas un silo, il hérite automatiquement du thème partagé, des profils et de l’historique. L’ensemble repose sur une stack Android moderne — Kotlin 2.0, Java 17, API Android 26+ — ce qui en fait non pas une preuve de concept, mais 20 applications estampillées prêtes pour la production.

## Comment j’ai résolu les parties les plus ardues

J’ai traité la couche de synchronisation comme le cœur du produit, et non comme une simple fonctionnalité. Plutôt que de greffer la synchronisation à chaque application, je l’ai conçue sous forme de modules dédiés et partagés — ThemeSync, ProfileSync, HistorySync, RSSSync, BookmarkSync, PreferencesSync, LanguageSync et TorrentSharingSync — auxquels chaque application de l’écosystème se connecte. Cette décision explique pourquoi un nouveau client bénéficie de la cohérence « gratuitement » : il adopte les modules au lieu de les réinventer.

Pour gérer la prolifération des intégrations, j’ai utilisé un modèle de connecteurs : chaque backend (qBittorrent, Transmission, MeTube, YT-DLP, JDownloader, Plex, etc.) est un module connecteur autonome, derrière un contrat commun. C’est ainsi que 20 clients restent individuellement corrects tout en étant collectivement maintenables. Le déploiement par phases — clients principaux, puis services cloud, puis services spécialisés — a permis à chaque couche de se stabiliser avant que la suivante ne s’appuie dessus.

Enfin, j’ai refusé de laisser la qualité se dégrader à mesure que la surface s’étendait. Les suites de tests unitaires, d’instrumentation et d’automatisation affichant 100 % de réussite, ainsi que l’étape QA assistée par IA, ne sont pas des badges de vanité ; ce sont les seuls moyens d’empêcher un écosystème de 20 applications avec une couche de synchronisation partagée de s’effondrer sous le poids des régressions. Maintenir une couverture de code d’environ 95 % et un ratio de dette technique de 0,2 % sur l’ensemble du projet est ce qui a permis d’affirmer, en toute crédibilité, que chacune de ces 20 applications était prête pour la production.
