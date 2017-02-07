CREATE TABLE IF NOT EXISTS `user_ldap` (
  `user_ldap_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `user_ldap_online` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_ldap_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
