# OpenVPN Admin

## Résumé
Administrer son OpenVPN via une interface web (visualisation des logs, modifications des utilisateurs pouvant se connecter...) selon un VPN configuré pour fonctionner avec SQL (un article de blog va venir).

## Prérequis
Serveur web, php et mysql.

## Installation
* Importer les bases SQL via le fichier sql/import.sql
* Ajouter un administrateur en spécifiant un nom et un mot de passe (hashé avec sha1)
* Modifier le fichier connexion_bdd.php.example et le renommer en connexion_bdd.php

## Notes
Utilisation du projet [SlickGrid](https://github.com/mleibman/SlickGrid) ainsi que de [SlickGridEnhancementPager](https://github.com/kingleema/SlickGridEnhancementPager) pour la pagination.
Utilisation des scripts de [pajhome](http://pajhome.org.uk/crypt/md5/index.html) pour l'algorithme sha1 en JavaScript.
