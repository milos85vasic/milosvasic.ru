---
title: GrabTube
slug: grab-tube
repo: https://github.com/vasic-digital/GrabTube
tech: Dart/Flutter
teaser: "One yt-dlp backend, five native clients — download from 1000+ sites on web, Android, iOS, Windows, macOS and Linux, even by scanning a QR code."
---

## L’accroche

`yt-dlp` est le téléchargeur vidéo le plus performant au monde, et c’est une ligne de commande. Pour la plupart des gens, c’est un mur. GrabTube abat ce mur : il enveloppe ce moteur dans une application multiplateforme soignée, permettant à quiconque de télécharger depuis YouTube et plus d’un millier d’autres sites avec sélection de qualité, choix de format et suivi en temps réel. Sur mobile, il suffit de pointer son appareil photo sur un QR code pour lancer le téléchargement. C’est un téléchargeur universel pour les services de streaming, doté d’une interface moderne de bout en bout.

## Pourquoi c’est fascinant

L’architecture est l’élément clé. GrabTube repose sur un moteur puissant alimentant plusieurs clients. L’interface web d’origine est développée en Python (aiohttp) couplé à Angular 19. Puis il y a un client Flutter 3.24+ écrit en Dart, qui se déploie *nativement* sur Android, iOS, Windows, macOS et Linux à partir d’une seule base de code. Tous les clients – web et Flutter confondus – communiquent avec le même moteur yt-dlp. Ainsi, la logique complexe de téléchargement réside en un seul endroit, tandis que l’expérience utilisateur s’adapte naturellement à l’appareil que vous tenez en main.

Le client Flutter est là où tout devient vraiment passionnant. Il gère les téléchargements en arrière-plan avec notifications, une file d’attente hors ligne, Material Design 3 avec thématisation adaptative, des performances natives sur chaque plateforme, et une intégration de l’appareil photo pour scanner les QR codes : un lien à l’écran se transforme en téléchargement en un seul geste. Il bénéficie d’un pipeline CI/CD et d’une couverture de tests dépassant 80 %, validée par l’IA – un niveau de finition rare pour un téléchargeur. De plus, il s’intègre à l’écosystème ShareConnect pour le partage universel de liens et la synchronisation des files d’attente et de l’historique entre appareils.

## Les défis majeurs

Le premier défi réside dans le fait que télécharger depuis « plus de 1000 sites » est une cible mouvante. Les structures des sites évoluent, les formats se multiplient, les méthodes d’extraction se cassent. La réponse de GrabTube repose sur une humilité architecturale : il ne réimplémente pas l’extraction, mais s’appuie sur yt-dlp et concentre ses efforts sur tout ce qui *entoure* le téléchargement – la mise en file d’attente, le suivi de progression, la négociation des formats et la présentation.

Le deuxième défi est le véritable multiplateforme à partir d’une seule base de code Dart. « Écrire une fois, exécuter partout » est facile à dire, mais impitoyable dans les détails : l’exécution en arrière-plan et les notifications fonctionnent différemment sur Android, iOS et chaque système d’exploitation de bureau ; l’accès à l’appareil photo et aux QR codes obéit à des modèles de permissions spécifiques à chaque plateforme ; le stockage des fichiers et la sémantique des téléchargements divergent partout. Offrir des performances natives avec une seule base de code Flutter sur cinq plateformes implique d’absorber toutes ces différences sous une interface épurée.

Le troisième défi concerne le contrat backend. Avec plusieurs clients hétérogènes (une application web Angular et une application Flutter) interrogeant un même service aiohttp, l’API doit servir de couture stable – la progression en temps réel, l’état de la file d’attente et l’historique doivent être diffusés proprement vers chaque client, quel que soit son mode de rendu.

## Ce qui en fait un outil révolutionnaire

Le changement de paradigme réside dans la portée sans réécriture. La plupart des outils de téléchargement choisissent une voie – une interface web, une application de bureau ou une application mobile. GrabTube refuse de trancher : la même fonctionnalité se présente sous forme d’interface web, d’application mobile native et d’application de bureau native, toutes alimentées par le même moteur. Ajoutez le flux de scan QR et la synchronisation multi-appareils via ShareConnect, et le téléchargement cesse d’être une corvée liée à un appareil pour devenir une expérience fluide qui vous suit de l’écran de votre ordinateur portable au smartphone dans votre poche.

Il est aussi tenu à des standards que la plupart des utilitaires n’atteignent jamais. Un client Flutter prêt pour la production, avec plus de 80 % de couverture de tests, une validation assistée par IA et un pipeline CI/CD automatisé, signifie que GrabTube se comporte comme un logiciel maintenu, et non comme un script du week-end qui se dégrade dès qu’un site change.

## Comment j’ai résolu les parties les plus ardues

La décision fondatrice a été de faire de yt-dlp la seule source de vérité pour les téléchargements et de ne jamais le contredire. En considérant l’extraction comme un problème résolu, géré par le backend, j’ai libéré tous les clients pour qu’ils se concentrent uniquement sur l’expérience utilisateur – et j’ai rendu le projet résilient, car lorsqu’un site change, la correction se trouve en amont, et non dispersée dans cinq interfaces.

Pour le multiplateforme, j’ai misé sur Flutter et Dart afin qu’une seule base de code puisse être déployée nativement sur Android, iOS, Windows, macOS et Linux, puis j’ai traité les aspects véritablement spécifiques à chaque plateforme – téléchargements en arrière-plan avec notifications, file d’attente hors ligne, scan QR via l’appareil photo, thématisation adaptative Material Design 3 – comme des intégrations natives délibérées, plutôt que de faire semblant que les plateformes sont identiques. C’est la différence entre une application Flutter qui *fonctionne* partout et une qui *semble* native partout.

J’ai maintenu le backend aiohttp comme une API propre et agnostique aux clients, afin que le client web Angular et le client Flutter puissent évoluer indépendamment tout en partageant un comportement de téléchargement identique, une progression en temps réel et un historique commun. Et j’ai intégré GrabTube à l’écosystème ShareConnect pour qu’un lien partagé sur un appareil se retrouve dans une file d’attente synchronisée sur un autre – transformant un simple téléchargeur en une partie intégrante d’un flux de travail connecté et multi-appareils. Enfin, j’ai imposé au client Flutter une couverture de tests supérieure à 80 %, avec validation par IA et un pipeline CI/CD, car un outil sur lequel les utilisateurs comptent pour récupérer leurs médias doit être testé comme tel.
