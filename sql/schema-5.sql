CREATE TABLE IF NOT EXISTS `application` ( `id` INT(11) AUTO_INCREMENT, `sql_schema` INT(11) NOT NULL, PRIMARY KEY (id) );

ALTER TABLE `user` CHANGE `user_start_date` `user_start_date` DATE NULL DEFAULT NULL;
ALTER TABLE `user` CHANGE `user_end_date` `user_end_date` DATE NULL DEFAULT NULL;
ALTER TABLE `log` CHANGE `log_end_time` `log_end_time` TIMESTAMP NULL DEFAULT NULL;

UPDATE `user` SET `user_start_date` = NULL WHERE `user_start_date` = '0000-00-00';
UPDATE `user` SET `user_end_date` = NULL WHERE `user_end_date` = '0000-00-00';
UPDATE `log` SET `log_end_time` = NULL WHERE `log_end_time` = '0000-00-00';
