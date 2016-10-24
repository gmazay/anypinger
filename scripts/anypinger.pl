#!/usr/bin/perl
###################################################################
# Asynchronous multiprocessing pinger
#
# Author: Mazay <gmazay@gmail.com>
###################################################################
use strict;
use warnings;
use DBI;
use AnyEvent;
use AnyEvent::Fork;
use AnyEvent::Fork::Pool;
use Getopt::Long;
use Config::General;

use Dir::Self;
use lib __DIR__.'/../lib';
use Anypinger;

my $config_file;

my $opt = GetOptions(
    "config|c=s"        => \$config_file
) || usage_exit();
usage_exit() unless (defined $config_file);

sub usage_exit { print "Usage: $0 --config={CONFIG_FILE}\n"; exit; }

my $conf = +{ Config::General->new($config_file)->getall() };

my $mod = $conf->{worker_module} || 'Pinger';                 # Модуль воркера (Pinger.pm)
my $sub = $conf->{worker_sub}    || 'ping';                   # Функция воркера

my $ap = Anypinger->new($conf);

my $dbh = $ap->db_connect();

my $hosts = $ap->get_hosts($dbh);  # Хеш под статусы хостов (keys - IP): 0 - OK, 1 - dead

my $res = $ap->do(
            module  => $mod,
            sub     => $sub,
            hosts   => $hosts,
            dbh     => $dbh );
print $res;

exit (0);

