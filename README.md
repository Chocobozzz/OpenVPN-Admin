# OpenVPN Admin

## Résumé
Administrer son OpenVPN via une interface web (visualisation des logs, modifications des utilisateurs pouvant se connecter...) selon un VPN configuré pour fonctionner avec SQL ([cf article de blog](http://blog.sandrocazzaniga.fr/?p=808)).

![Prévisualisation](/images/screen_adminvpn.png "Prévisualisation de l'interface web")

Les configurations ainsi que les scripts d'OpenVPN adaptés à cette interface sont présents dans le dossier openvpn-conf.


## Prérequis
Serveur Web (NGinx, Apache...), PHP, SQL (MySQL, Postgre...).

## Installation
* Importer les bases SQL via le fichier sql/import.sql
* Supprimer le dossier sql
* Ajouter un administrateur en spécifiant un nom et un mot de passe (hashé avec sha1)

        INSERT INTO admin (admin_id, admin_pass) VALUES ("superadmin", SHA1('monmdp'));

* Copier le fichier include/config.php.example vers include/config.php
* Modifier le fichier config.php en rentrant les identifiants de votre BDD
* Vous pouvez utiliser le dossier openvpn-conf, mais en production le site ne doit pas contenir ce dossier (supprimez le ou déplacez le)

## Notes
Utilisation du projet [SlickGrid](https://github.com/mleibman/SlickGrid) ainsi que de [SlickGridEnhancementPager](https://github.com/kingleema/SlickGridEnhancementPager) pour la pagination.
Utilisation des scripts de [pajhome](http://pajhome.org.uk/crypt/md5/index.html) pour l'algorithme sha1 en JavaScript.
