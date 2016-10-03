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
use Dir::Self;
use lib __DIR__;
use cfg;


my $mod = 'anypinger';    # Модуль воркера (anypinger.pm)
my $sub = 'ping';         # Функция воркера
my %dev;                  # Хеш под статусы хостов (keys - IP): 0 - OK, 1 - dead



my $dbh = q_connect('localhost');

my $sth = $dbh->prepare("SELECT ip, st FROM devices") || die $dbh->errstr();
$sth->execute || die $sth->errstr();
while ( my($k,$v) = $sth->fetchrow_array ) { $dev{$k} = $v; }
$sth->finish;

# Создать событийную машину
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

        on_destroy => sub { $dbh->disconnect; $done->send; } # $done->send - выход из машины
    );


# Набить в пул задачи
foreach my $key (keys %dev) {
    $pool->($key, sub {
        my $status = shift;
        if( $status ne $dev{$key} ){
            $dbh->do("UPDATE devices SET st=? WHERE address=?", undef, $status, $key) || die $dbh->errstr;
        }
        print "$key : $dev{$key} -> $status\n";
    });
};


undef $pool;
 
# Перейти в режим блокирующего ожидания событий (запуск машины)
$done->recv;
