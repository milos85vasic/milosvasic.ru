---
title: LLMs Verifier
slug: llms-verifier
repo: https://github.com/vasic-digital/LLMsVerifier
tech: Go
teaser: "Before any LLM touches production, it has to prove it can actually see your code — across 12 providers, in real time."
---

## L’accroche

Chaque équipe qui se branche sur « le dernier modèle » fait discrètement confiance à un fichier de configuration. Le nom du modèle dans votre YAML indique `gpt-4o` ou `claude-sonnet`, l’endpoint renvoie un 200, et vous partez du principe que ce qui se trouve de l’autre côté est réel, opérationnel et capable d’assumer la tâche que vous vous apprêtez à lui confier. LLMs Verifier existe parce que cette hypothèse est suffisamment souvent fausse pour causer des dégâts. Il s’agit d’une plateforme d’entreprise en Go qui refuse catégoriquement l’intégration d’un modèle non vérifié dans votre pipeline – chaque modèle doit d’abord réussir un test littéral du type *« Vois-tu mon code ? »* avant d’être autorisé à l’emploi.

## Pourquoi c’est fascinant

L’aspect intéressant, c’est que « vérifier un LLM » ne se résume pas à un seul test – c’est toute une batterie d’épreuves, et chacune échoue de manière différente, insidieuse. LLMs Verifier exécute des vérifications d’existence, de réactivité, de latence, de streaming, d’appels de fonctions, de vision et d’embeddings, chacune considérée comme un test de validation distinct. Un modèle peut exister sans gérer le streaming. Il peut streamer mais s’étouffer sur les appels d’outils. Il peut prétendre prendre en charge la vision et ignorer silencieusement l’image. En traitant chaque capacité comme une propriété de premier ordre, vérifiable indépendamment, la plateforme transforme *« ce modèle est-il bon ? »* – une question de feeling – en un résultat mesurable et reproductible.

Par ailleurs, elle s’interface avec 12 adaptateurs de fournisseurs – OpenAI, Anthropic, Cohere, Groq, Together AI, Mistral, xAI, Replicate, DeepSeek, Cerebras, Cloudflare Workers AI et SiliconFlow – via une seule interface normalisée. La même suite de vérification, le même système de notation, appliqués à des API radicalement différentes. Cette normalisation est là où se concentre l’essentiel du travail d’ingénierie, car aucun fournisseur ne s’accorde sur ce à quoi ressemblent le streaming, les appels de fonctions ou les embeddings au niveau du protocole.

## Les défis majeurs

Le premier défi est l’hétérogénéité. Une couche de détection des capacités doit savoir que le streaming peut arriver sous forme d’événements serveur (SSE), de trames WebSocket, d’un générateur asynchrone, de JSONL ou d’un flux brut – et elle doit identifier ce qu’un fournisseur donné délivre réellement, et non ce que promettent les documentations. Elle suit la prise en charge de la compression (gzip, brotli, ainsi que la compression sémantique ou au niveau des conversations), les comportements de mise en cache (comme le *prompt caching* d’Anthropic et de DashScope) et la disponibilité de HTTP/3 par fournisseur. Rien de tout cela n’est uniforme ; tout doit être découvert empiriquement.

Le deuxième défi est la confiance en situation d’échec. En production, les fournisseurs limitent les requêtes, dégradent leurs performances ou disparaissent purement et simplement. La plateforme superpose une surveillance de santé en temps réel avec un basculement intelligent et un *circuit-breaker* pour éviter qu’un fournisseur instable ne fasse s’effondrer toute la séquence de vérification – ou l’application qui l’utilise.

Le troisième défi est le contexte à long terme. Le système prend en charge des sessions de 24 heures ou plus, avec des résumés générés par LLM et une optimisation RAG, ainsi qu’un modèle superviseur/travailleur qui utilise un LLM pour découper les gros travaux de vérification en tâches distribuées. Maintenir la cohérence de l’état sur une journée entière d’activité d’agents, sans exploser la fenêtre de contexte, relève d’un véritable problème de systèmes distribués déguisé en fonctionnalité LLM.

## Ce qui en fait un game-changer

Le changement de paradigme réside dans le passage de *« configuré »* à *« prouvé »*. La plupart des piles exportent une liste de noms de modèles et espèrent. LLMs Verifier produit un export de configuration vérifiée où seuls les modèles ayant effectivement passé les tests sont inclus – et elle marque chaque fournisseur et modèle généré avec un suffixe obligatoire `(llmsvd)`, de sorte qu’il n’y ait jamais d’ambiguïté sur ce qui a été vérifié par machine et ce qui a été modifié manuellement. Cette seule discipline élimine toute une catégorie d’incidents : le scénario *« nous avons livré avec un modèle incapable de faire ce dont nous avions besoin »* ne peut tout simplement pas survivre à une porte d’exportation aussi stricte.

Par ailleurs, elle est conçue comme une infrastructure, pas comme un simple script. Déploiement via Docker et Kubernetes, métriques Prometheus avec tableaux de bord Grafana, authentification LDAP/SSO avec SAML/OIDC, chiffrement de base de données avec SQLCipher, et intégrations avec Splunk, DataDog, New Relic et ELK. Elle propose des SDK Python et JavaScript, ainsi qu’une surface OpenAPI/Swagger. C’est une plateforme que vous pouvez confier à une équipe sécurité et à une équipe plateforme en obtenant un hochement de tête approbateur de leur part.

## Comment j’ai résolu les parties les plus ardues

J’ai fait de la vérification le contrat, et non une réflexion après coup. La décision centrale a été que rien – aucun modèle, aucun fournisseur – n’a le droit d’être utilisé avant d’avoir passé la suite de tests, et le *« Vois-tu mon code ? »* en est la porte d’entrée incontournable. Ce cadrage a imposé une séparation nette : les adaptateurs de fournisseurs sont de simples transporteurs, et le moteur de vérification détient la vérité.

Pour dompter 12 fournisseurs incompatibles, j’ai construit la détection des capacités comme une sonde empirique plutôt que comme une table statique de fonctionnalités. Le système interroge chaque fournisseur sur ce qu’il peut faire en le testant concrètement – en ouvrant un flux et en classifiant son encodage (SSE vs WebSocket vs JSONL vs générateur asynchrone), en tentant un appel de fonction, en envoyant une image – et enregistre la réalité observée, y compris les particularités de compression et de mise en cache. Ajouter un 13ᵉ fournisseur revient à *« écrire un transporteur et laisser la sonde le caractériser »*, et non à *« réauditer toute la matrice »*.

Pour la résilience, je me suis appuyé sur des patterns éprouvés : des *circuit breakers* autour de chaque appel sortant vers un fournisseur, des vérifications de santé pilotant un basculement automatique, et des points de contrôle sauvegardés dans le cloud (S3, Google Cloud, Azure) pour qu’une session supervisée de 24 heures survive à un redémarrage. Et je l’ai écrit en Go à dessein – son modèle de concurrence se prête naturellement à *« exécuter de nombreuses sondes de vérification indépendantes contre de nombreux services distants instables en parallèle »*, ce qui correspond exactement au workload. Le résultat est un vérificateur lui-même de niveau production, car un outil qui contrôle la production n’a pas le droit d’être instable.
