#!/usr/bin/perl
###################################################################
# Asynchronous multiprocessing pinger
#
# Files: anypinger.pl, anypinger.pm, cfg.pm
# Author: Mazay <gmazay@gmail.com>
###################################################################
use strict;
use warnings;
use AnyEvent;
use AnyEvent::Fork;
use AnyEvent::Fork::Pool;

use lib substr($0,0,-13); # Change to "use lib '/dir/of/cfg'"
use cfg;


my $mod = 'anypinger';	# Модуль воркера (anypinger.pm)
my $sub = 'ping';	# Функция воркера
my %dev;		# Хеш под статусы хостов (keys - IP): 0 - OK, 1 - dead



my $dbh=q_connect('localhost');

my $sth = $dbh->prepare("select ip,st from devices") || die print $dbh->errstr();
$sth->execute || die print $sth->errstr();
while (my($k,$v) = $sth->fetchrow_array) { $dev{$k} = $v; }
$sth->finish;

# Создать событийную мошыну
my $done = AnyEvent->condvar;

# Создать пул воркеров
my $pool = AnyEvent::Fork
	->new
	->require ($mod)
	->AnyEvent::Fork::Pool::run(
		"${mod}::$sub",         # Модуль::Функция - рабочая функция воркера
		init => "${mod}::init", # Модуль::init - функция инициализации воркера
		max  => $num_proc,      # Количество воркеров в пуле
		idle => 0,              # Количество воркеров при простое
		load => 1,              # Размер очереди воркера

		on_destroy => sub { $dbh->disconnect; $done->send; } # $done->send - выход из мошыны
	);


# Набить в пул задачи
foreach my $ke (keys %dev) {
	$pool->($ke, sub {
		my $st = shift;
		if( $st ne $dev{$ke} ){
			$dbh->do("update devices set st='$st' where address='$ke'") || die print $dbh->errstr;
		}
			print "$ke : $dev{$ke} -> $st\n";
	});
};


undef $pool;
 
# Перейти в режим блокирующего ожидания событий (запуск мошыны)
$done->recv;