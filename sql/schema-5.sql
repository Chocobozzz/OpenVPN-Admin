CREATE TABLE IF NOT EXISTS `application` ( `id` INT(11) AUTO_INCREMENT, `sql_schema` INT(11) NOT NULL, PRIMARY KEY (id) );

ALTER TABLE `user` CHANGE `startdate` `startdate` DATE NULL DEFAULT NULL;
ALTER TABLE `user` CHANGE `enddate` `enddate` DATE NULL DEFAULT NULL;
ALTER TABLE `log` CHANGE `log_end_time` `log_end_time` TIMESTAMP NULL DEFAULT NULL;

UPDATE `user` SET `startdate` = NULL WHERE `startdate` = '0000-00-00';
UPDATE `user` SET `enddate` = NULL WHERE `enddate` = '0000-00-00';
UPDATE `log` SET `log_end_time` = NULL WHERE `log_end_time` = '0000-00-00';
