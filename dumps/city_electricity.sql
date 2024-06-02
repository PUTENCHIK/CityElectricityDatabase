drop database city_electricity;
create database city_electricity CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
use city_electricity;

SET FOREIGN_KEY_CHECKS=0;


DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `lastname` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `secondname` varchar(255) NOT NULL,
  `login` varchar(255) UNIQUE NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `balance` decimal(10,2) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `balance_changes_log`;
CREATE TABLE IF NOT EXISTS `balance_changes_log` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL,
  `type_id` int(10) UNSIGNED NOT NULL,
  `sum` decimal(10,2),
  `old_balance` decimal(10,2),
  `new_balance` decimal(10,2),
  `completed_at` timestamp NOT NULL
);

DROP TABLE IF EXISTS `payment_types`;
CREATE TABLE IF NOT EXISTS `payment_types` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `services`;
CREATE TABLE IF NOT EXISTS `services` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(1000),
  `price` decimal(10,2) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `services_orders`;
CREATE TABLE IF NOT EXISTS `services_orders` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL,
  `service_id` int(10) UNSIGNED NOT NULL,
  `address` varchar(1000) NOT NULL,
  `ordered_at` timestamp NOT NULL,
  `execute_at` timestamp NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `services_orders_executions`;
CREATE TABLE IF NOT EXISTS `services_orders_executions` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `order_id` int(10) UNSIGNED UNIQUE NOT NULL,
  `worker_id` int(10) UNSIGNED NOT NULL,
  `executed_at` timestamp NOT NULL
);

DROP TABLE IF EXISTS `tariffs`;
CREATE TABLE IF NOT EXISTS `tariffs` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(1000),
  `internet_speed` int(10) NOT NULL DEFAULT 100 COMMENT 'Speed in MBit/s',
  `price` decimal(10,2) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `channels`;
CREATE TABLE IF NOT EXISTS `channels` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255),
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `channels_tariffs`;
CREATE TABLE IF NOT EXISTS `channels_tariffs` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `tariff_id` int(10) UNSIGNED NOT NULL,
  `channel_id` int(10) UNSIGNED NOT NULL
);

DROP TABLE IF EXISTS `movies`;
CREATE TABLE IF NOT EXISTS `movies` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255),
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `movies_tariffs`;
CREATE TABLE IF NOT EXISTS `movies_tariffs` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `tariff_id` int(10) UNSIGNED NOT NULL,
  `movie_id` int(10) UNSIGNED NOT NULL
);

DROP TABLE IF EXISTS `tariffs_connections`;
CREATE TABLE IF NOT EXISTS `tariffs_connections` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL,
  `tariff_id` int(10) UNSIGNED NOT NULL,
  `month_amount` tinyint(2) NOT NULL DEFAULT 1 COMMENT 'Maximum is 12 months',
  `connected_at` timestamp NOT NULL,
  `canceled_at` timestamp NOT NULL
);

DROP TABLE IF EXISTS `devices`;
CREATE TABLE IF NOT EXISTS `devices` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(1000),
  `type_id` int(10) UNSIGNED,
  `producer_id` int(10) UNSIGNED,
  `price` decimal(10,2) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `device_models`;
CREATE TABLE IF NOT EXISTS `device_models` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `model_number` varchar(255) UNIQUE NOT NULL,
  `device_id` int(10) UNSIGNED NOT NULL,
  `storage_id` int(10) UNSIGNED NOT NULL,
  `sold_at` timestamp DEFAULT null
);


DROP TABLE IF EXISTS `storages`;
CREATE TABLE IF NOT EXISTS `storages` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `address` varchar(1000) NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `device_types`;
CREATE TABLE IF NOT EXISTS `device_types` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255),
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `device_producers`;
CREATE TABLE IF NOT EXISTS `device_producers` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255),
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `devices_orders`;
CREATE TABLE IF NOT EXISTS `devices_orders` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL,
  `device_id` int(10) UNSIGNED NOT NULL,
  `amount` int(10) NOT NULL DEFAULT 1,
  `ordered_at` timestamp NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

DROP TABLE IF EXISTS `devices_deliveries`;
CREATE TABLE IF NOT EXISTS `devices_deliveries` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `order_id` int(10) UNSIGNED UNIQUE NOT NULL,
  `deliveryman_id` int(10) UNSIGNED NOT NULL,
  `delivered_at` timestamp NOT NULL
);

DROP TABLE IF EXISTS `employees`;
CREATE TABLE IF NOT EXISTS `employees` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `lastname` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `secondname` varchar(255) NOT NULL,
  `hired_at` timestamp NOT NULL,
  `fired_at` timestamp DEFAULT null
);


DROP TABLE IF EXISTS `employees_posts`;
CREATE TABLE IF NOT EXISTS `employees_posts` (
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `employee_id` int(10) UNSIGNED NOT NULL,
  `post_id` int(10) UNSIGNED NOT NULL,
  `deleted_at` timestamp DEFAULT null
);
DROP TABLE IF EXISTS `work_posts`;
  `id` int(10) UNSIGNED PRIMARY KEY NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `deleted_at` timestamp DEFAULT null
);

CREATE UNIQUE INDEX `tariff_id_channel_id` ON `channels_tariffs` (`tariff_id`, `channel_id`);

CREATE UNIQUE INDEX `tariff_id_movie_id` ON `movies_tariffs` (`tariff_id`, `movie_id`);

CREATE UNIQUE INDEX `name_type_id_producer_id` ON `devices` (`name`, `type_id`, `producer_id`);

CREATE UNIQUE INDEX `employee_id_post_id` ON `employees_posts` (`employee_id`, `post_id`);

ALTER TABLE `services_orders` ADD FOREIGN KEY (`service_id`) REFERENCES `services` (`id`);

ALTER TABLE `tariffs_connections` ADD FOREIGN KEY (`tariff_id`) REFERENCES `tariffs` (`id`);

ALTER TABLE `devices` ADD FOREIGN KEY (`type_id`) REFERENCES `device_types` (`id`);

ALTER TABLE `devices` ADD FOREIGN KEY (`producer_id`) REFERENCES `device_producers` (`id`);

ALTER TABLE `device_models` ADD FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`);

ALTER TABLE `device_models` ADD FOREIGN KEY (`storage_id`) REFERENCES `storages` (`id`);

ALTER TABLE `devices_orders` ADD FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`);

ALTER TABLE `devices_orders` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `tariffs_connections` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `services_orders` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `services_orders_executions` ADD FOREIGN KEY (`order_id`) REFERENCES `services_orders` (`id`);

ALTER TABLE `services_orders_executions` ADD FOREIGN KEY (`worker_id`) REFERENCES `employees` (`id`);

ALTER TABLE `devices_deliveries` ADD FOREIGN KEY (`order_id`) REFERENCES `devices_orders` (`id`);

ALTER TABLE `devices_deliveries` ADD FOREIGN KEY (`deliveryman_id`) REFERENCES `employees` (`id`);

ALTER TABLE `balance_changes_log` ADD FOREIGN KEY (`type_id`) REFERENCES `payment_types` (`id`);

ALTER TABLE `balance_changes_log` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `channels_tariffs` ADD FOREIGN KEY (`tariff_id`) REFERENCES `tariffs` (`id`);

ALTER TABLE `channels_tariffs` ADD FOREIGN KEY (`channel_id`) REFERENCES `channels` (`id`);

ALTER TABLE `movies_tariffs` ADD FOREIGN KEY (`movie_id`) REFERENCES `movies` (`id`);

ALTER TABLE `movies_tariffs` ADD FOREIGN KEY (`tariff_id`) REFERENCES `tariffs` (`id`);

ALTER TABLE `employees_posts` ADD FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`);

ALTER TABLE `employees_posts` ADD FOREIGN KEY (`post_id`) REFERENCES `work_posts` (`id`);
