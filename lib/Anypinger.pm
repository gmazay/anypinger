package Anypinger;
use Exporter();
@ISA = qw(Exporter);
@EXPORT = qw(&db_connect &get_hosts &do);
use strict;
use warnings;

use AnyEvent;
use AnyEvent::Fork;
use AnyEvent::Fork::Pool;
use DBI;

use version; our $VERSION = 'v0.2.0';

sub db_connect {
	my $conf = shift;
	my $dbh = DBI->connect( $conf->{DB}->{dsn}, $conf->{DB}->{user}, $conf->{DB}->{password}, $conf->{DB}->{params} ) || die DBI::errstr();
	
	return $dbh;
}

sub get_hosts {
	my ($conf, $dbh) = @_;
	my $hosts = +{};
	my $sth = $dbh->prepare( $conf->{query_select} ) || die $dbh->errstr();
	$sth->execute || die $sth->errstr();
	while ( my($k,$v) = $sth->fetchrow_array ) { $hosts->{$k} = $v; }
	$sth->finish;
	
	return $hosts;
}

sub do {
	my (%args) = @_;
	my ($conf, $mod, $sub, $hosts, $dbh) = @args{ qw/conf module sub hosts dbh/ };
	my $num_proc = $conf->{num_proc} || 7;
	$ENV{ping_proto} = $conf->{ping_proto} || 'tcp';
	$ENV{ping_timeout} = $conf->{ping_timeout} || 3;
	my $res = '';
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
	foreach my $key (keys %$hosts) {
		$pool->($key, sub {
			my $status = shift;
			if( $status ne $hosts->{$key} ){
				$dbh->do( $conf->{query_update}, undef, $status, $key ) || die $dbh->errstr;
			}
			$res .= "$key : $hosts->{$key} -> $status\n";
		});
	};
	
	
	undef $pool;
	 
	# Перейти в режим блокирующего ожидания событий (запуск машины)
	$done->recv;
	
    return $res;
}

1;

