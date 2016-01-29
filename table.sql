
CREATE TABLE `devices` (
  `id` int(255) NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `parent` varchar(255) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `description` varchar(255) NOT NULL,
  `st` tinyint(4) default '0',
  PRIMARY KEY  (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
 
