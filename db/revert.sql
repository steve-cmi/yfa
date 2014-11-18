# ************************************************************
# Sequel Pro SQL dump
# Version 4096
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.6.17)
# Database: campustheater
# Generation Time: 2014-11-11 14:30:12 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Drops
# ------------------------------------------------------------
DROP TABLE IF EXISTS auditions;
DROP TABLE IF EXISTS board_positions;
DROP TABLE IF EXISTS carousels;
DROP TABLE IF EXISTS film_positions;
DROP TABLE IF EXISTS films;
DROP TABLE IF EXISTS news;
DROP TABLE IF EXISTS people;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS schema_migrations;
DROP TABLE IF EXISTS showtimes;
DROP TABLE IF EXISTS takeover_requests;

# Dump of table auditions
# ------------------------------------------------------------

CREATE TABLE `auditions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `show_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT '2003-01-01 08:00:00',
  `name` varchar(100) COLLATE latin1_german2_ci DEFAULT NULL,
  `phone` varchar(50) COLLATE latin1_german2_ci DEFAULT NULL,
  `email` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `location` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci;



# Dump of table board_positions
# ------------------------------------------------------------

CREATE TABLE `board_positions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `position` varchar(255) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `extra` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_board_positions_on_year` (`year`),
  KEY `index_board_positions_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table news
# ------------------------------------------------------------

CREATE TABLE `news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  `poster` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `text` text COLLATE latin1_german2_ci NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci;



# Dump of table people
# ------------------------------------------------------------

CREATE TABLE `people` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(50) COLLATE latin1_german2_ci NOT NULL,
  `lname` varchar(50) COLLATE latin1_german2_ci NOT NULL,
  `email` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `college` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `bio` text COLLATE latin1_german2_ci,
  `password` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `confirm_code` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `email_allow` tinyint(1) NOT NULL DEFAULT '0',
  `site_admin` tinyint(1) DEFAULT '0',
  `picture_file_name` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `picture_content_type` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `picture_file_size` int(11) DEFAULT NULL,
  `picture_updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `netid` varchar(6) COLLATE latin1_german2_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_people_on_netid` (`netid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci COMMENT='Table for all people who participate in theater';



# Dump of table permissions
# ------------------------------------------------------------

CREATE TABLE `permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `show_id` int(11) NOT NULL,
  `person_id` int(11) NOT NULL,
  `level` enum('full','reservations','auditions') DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_permissions_on_show_id` (`show_id`),
  KEY `index_permissions_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table positions
# ------------------------------------------------------------

CREATE TABLE `positions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `position` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci COMMENT='Theater Positions';



# Dump of table reservation_types
# ------------------------------------------------------------

CREATE TABLE `reservation_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tix_type` varchar(50) COLLATE latin1_german2_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci COMMENT='Types of people who reserve tickets';



# Dump of table reservations
# ------------------------------------------------------------

CREATE TABLE `reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fname` varchar(50) COLLATE latin1_german2_ci NOT NULL,
  `lname` varchar(50) COLLATE latin1_german2_ci NOT NULL,
  `email` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  `num` tinyint(4) NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `showtime_id` int(11) NOT NULL,
  `reservation_type_id` smallint(6) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `used` int(11) NOT NULL DEFAULT '0',
  `token` text COLLATE latin1_german2_ci,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci COMMENT='Reservation System';



# Dump of table schema_migrations
# ------------------------------------------------------------

CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;



# Dump of table show_positions
# ------------------------------------------------------------

CREATE TABLE `show_positions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `show_id` int(11) NOT NULL,
  `position_id` smallint(6) NOT NULL,
  `character` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `assistant` enum('Associate','Assistant') COLLATE latin1_german2_ci DEFAULT NULL,
  `listing_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci COMMENT='Positions in a show';



# Dump of table shows
# ------------------------------------------------------------

CREATE TABLE `shows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `category` enum('theater','dance','film','comedy','casting') COLLATE latin1_german2_ci NOT NULL DEFAULT 'theater',
  `title` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  `writer` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  `tagline` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `location` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  `contact` varchar(255) COLLATE latin1_german2_ci NOT NULL,
  `auditions_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `aud_info` text COLLATE latin1_german2_ci,
  `aud_files` text COLLATE latin1_german2_ci,
  `public_aud_info` tinyint(1) NOT NULL DEFAULT '0',
  `description` text COLLATE latin1_german2_ci NOT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `pw` text COLLATE latin1_german2_ci,
  `url_key` varchar(25) COLLATE latin1_german2_ci DEFAULT NULL,
  `alt_tix` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `seats` int(11) NOT NULL DEFAULT '0',
  `cap` int(11) NOT NULL DEFAULT '0',
  `waitlist` tinyint(1) NOT NULL DEFAULT '0',
  `show_waitlist` tinyint(1) NOT NULL DEFAULT '0',
  `tix_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `freeze_mins_before` int(11) NOT NULL DEFAULT '120',
  `on_sale` date DEFAULT NULL,
  `archive` tinyint(1) NOT NULL DEFAULT '1',
  `archive_reminder_sent` tinyint(1) NOT NULL DEFAULT '0',
  `picture_meta` text COLLATE latin1_german2_ci,
  `flickr_id` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `poster_file_name` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `poster_content_type` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `poster_file_size` int(11) DEFAULT NULL,
  `poster_updated_at` datetime DEFAULT NULL,
  `poster_meta` text COLLATE latin1_german2_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `accent_color` enum('red','yellow','green','dark_blue','blue','light_blue','black') COLLATE latin1_german2_ci DEFAULT NULL,
  `charges_at_door` tinyint(1) DEFAULT NULL,
  `private_registration_token` varchar(255) COLLATE latin1_german2_ci DEFAULT NULL,
  `waitlist_seats` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci COMMENT='Table with main show information';



# Dump of table showtimes
# ------------------------------------------------------------

CREATE TABLE `showtimes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `show_id` int(11) NOT NULL,
  `email_sent` tinyint(1) NOT NULL DEFAULT '0',
  `timestamp` datetime DEFAULT NULL,
  `reminder_sent` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `show_index` (`show_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_german2_ci COMMENT='Showtimes by show';



# Dump of table takeover_requests
# ------------------------------------------------------------

CREATE TABLE `takeover_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `requested_person_id` int(11) NOT NULL,
  `approved` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_takeover_requests_on_person_id` (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


# Dump of table schema_migrations
# ------------------------------------------------------------

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;

INSERT INTO `schema_migrations` (`version`)
VALUES
  ('20120123004157'),
  ('20120123004158'),
  ('20120123004159'),
  ('20120123004160'),
  ('20120123004161'),
  ('20140327174348'),
  ('20140328181137'),
  ('20140403174239'),
  ('20140417145931');

/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
