---
title: Panoptic
slug: panoptic
repo: https://github.com/vasic-digital/Panoptic
tech: Go
teaser: "One Go framework that drives, screenshots, and screen-records web, desktop, iOS and Android — the all-seeing eye for UI automation."
---

## L’accroche

L’automatisation des interfaces utilisateur est fragmentée. Vous apprenez Selenium ou Playwright pour le web, Appium et XCUITest pour le mobile, un autre outil pour le desktop, et un enregistreur séparé si vous voulez une vidéo de ce qui s’est passé. Chaque frontière est un nouvel outil, une nouvelle abstraction, une nouvelle source d’instabilité. Panoptic – nommé d’après l’œil omniprésent – réduit tout ce zoo à un seul framework en Go qui automatise, capture des captures d’écran et enregistre des sessions sur le web, le desktop et le mobile avec un seul modèle de programmation.

## Pourquoi c’est fascinant

Ce qui rend Panoptic captivant, c’est qu’il traite *« observer ce que fait le logiciel »* comme une capacité de premier plan, au même titre que *« piloter le logiciel »*. Il ne se contente pas de cliquer sur des boutons : il capture des captures d’écran horodatées en haute qualité et enregistre des vidéos complètes de session dans plusieurs formats. Cela signifie qu’une seule exécution de test peut produire à la fois les assertions et les preuves visuelles – l’enregistrement n’est pas un ajout optionnel, il fait partie intégrante du framework.

Il est véritablement multiplateforme. L’automatisation web couvre Chrome, Firefox, Safari et Edge. Le mobile prend en charge l’automatisation des applications iOS et Android avec enregistrement d’écran. Le desktop bénéficie de l’automatisation d’interface et de la capture d’écran. Et tout cela est exposé via une API Go propre : `web.NewBrowser()`, `browser.Navigate(...)`, `browser.Screenshot(...)`, des sélecteurs CSS et XPath personnalisés, des stratégies d’attente explicites – ainsi qu’une CLI pour les cas courants (`panoptic record --platform ios --device iPhone13 --output mobile_demo.mp4`). Le fait que la même API conceptuelle s’étende d’une fenêtre Chrome en mode headless à une session iPhone enregistrée est précisément l’objectif.

## Les défis complexes

Le premier défi majeur réside dans le fait qu’« un élément » ne signifie pas la même chose sur chaque plateforme. Un bouton web est un nœud DOM accessible via CSS ou XPath. Un contrôle iOS vit dans l’arbre d’accessibilité. Un widget desktop est un handle natif du système d’exploitation. Panoptic doit proposer un modèle unifié de détection et d’interaction avec les éléments, tout en parlant, en coulisses, quatre dialectes complètement différents pour *« trouver cet élément et cliquer dessus »*.

Le deuxième défi est celui du timing. Les interfaces utilisateur sont asynchrones partout, mais de manière différente selon les plateformes. Panoptic intègre des stratégies d’attente explicites – `WaitForElement` avec un délai d’expiration, et `WaitForCondition` qui interroge une prédicat arbitraire jusqu’à ce qu’il devienne vrai – car les pauses fixes sont la première cause d’instabilité dans l’automatisation. Concevoir des primitives d’attente qui se comportent de manière identique, qu’il s’agisse d’attendre la disparition d’un `div.loading` ou le rendu d’une vue native, relève d’un travail subtil.

Le troisième défi est l’enregistrement pendant l’exécution. Capturer une vidéo à 30 images par seconde en haute qualité, avec une fenêtre d’affichage configurable, sans perturber le timing de l’automatisation enregistrée, représente un véritable défi de performance et de synchronisation – surtout sur mobile, où l’on enregistre l’écran d’un appareil ou d’un simulateur, et non simplement un canevas contrôlé.

## Ce qui en fait un outil révolutionnaire

Le changement de paradigme réside dans la consolidation associée à la preuve visuelle. Quand l’automatisation repose sur un seul framework pour toutes les plateformes, une équipe adopte un seul modèle mental au lieu de quatre, et obtient des preuves visuelles gratuitement. Un test instable cesse d’être une trace d’exécution à décrypter – il devient une vidéo à regarder. Cela change radicalement la façon dont les équipes diagnostiquent les échecs.

Il est aussi conçu pour s’intégrer aux pipelines : une architecture de plugins extensible, des hooks avant/après pour la configuration et le nettoyage, un fichier YAML pour les paramètres du navigateur, de l’enregistrement et des réglages mobiles par plateforme, ainsi qu’une intégration explicite avec les outils CI/CD. Vous pouvez brancher la même suite de tests en CI que celle exécutée localement, et les artefacts – captures d’écran et fichiers MP4 – sont exactement ce que vous souhaitez joindre à une build en échec.

## Comment j’ai résolu les problèmes les plus ardus

J’ai choisi Go délibérément. L’automatisation multiplateforme repose, sous le capot, sur une multitude d’E/S concurrentes – communication avec les pilotes de navigateur, les ponts vers les appareils (ADB pour Android, les outils Xcode pour iOS) et un encodeur pour l’enregistrement – le tout simultanément. Les goroutines et les channels de Go rendent possible et efficace l’orchestration de *« piloter l’UI sur cette goroutine, extraire les frames d’écran sur celle-là, surveiller une condition d’attente sur une troisième »*, et le binaire statique unique simplifie le déploiement de la CLI dans les environnements CI.

Pour unifier les quatre modèles d’éléments, j’ai fait en sorte que les pilotes de plateforme implémentent une interface d’interaction commune, tout en conservant des sélecteurs expressifs plutôt qu’un dénominateur commun minimal – CSS et XPath pour le web, des localisateurs natifs pour le mobile et le desktop. Ainsi, l’abstraction ne vous prive jamais du sélecteur précis dont vous avez besoin. Les primitives d’attente sont construites au-dessus de cette interface, c’est pourquoi `WaitForCondition` fonctionne de manière identique, quelle que soit la plateforme inspectée par le prédicat.

Pour enregistrer sans distorsion, j’ai traité la capture comme un pipeline indépendant, configurable séparément (format, qualité, images par seconde dans `panoptic.yaml`), de sorte que l’enregistreur s’exécute en parallèle de l’automatisation plutôt qu’au sein de son chemin critique. Et j’ai conçu l’ensemble pour qu’il soit extensible dès le départ via des hooks et un système de plugins, car la seule certitude en automatisation, c’est que quelqu’un aura besoin de faire quelque chose que je n’avais pas anticipé – et le framework doit le permettre, plutôt que d’imposer une bifurcation du code.
