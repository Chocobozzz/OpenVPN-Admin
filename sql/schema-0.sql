CREATE TABLE IF NOT EXISTS `application` ( `id` INT(11) AUTO_INCREMENT, `sql_schema` INT(11) NOT NULL, PRIMARY KEY (id) );

CREATE TABLE IF NOT EXISTS `admin` (
  `admin_id` varchar(255) NOT NULL,
  `admin_pass` varchar(255) NOT NULL,
  PRIMARY KEY (`admin_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `log` (
  `log_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `log_trusted_ip` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_trusted_port` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_remote_ip` varchar(32) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_remote_port` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `log_start_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `log_end_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `log_received` float NOT NULL DEFAULT '0',
  `log_send` float NOT NULL DEFAULT '0',
  PRIMARY KEY (`log_id`),
  KEY `user_id` (`user_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci AUTO_INCREMENT=1 ;

CREATE TABLE IF NOT EXISTS `user` (
  `memberID` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(64) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(16) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subscription` varchar(16) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Free',
  `online` tinyint(1) NOT NULL DEFAULT '0',
  `enable` tinyint(1) NOT NULL DEFAULT '1',
  `startdate` date NOT NULL DEFAULT CURDATE(),
  `enddate` date NOT NULL CURDATE() + INTERVAL 1 MONTH,
  `activate` varchar(255) NOT NULL,
  `resetToken` varchar(255) DEFAULT NULL,
  `resetComplete` varchar(3) DEFAULT 'No',
  PRIMARY KEY (`memberID`),
  KEY `username` (`username`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
