package Pinger;

use strict;
use warnings;

use Net::Ping;

my $p;
my $timeout;

sub init {
	my $ping_proto = $ENV{ping_proto} || 'tcp';
	$timeout = $ENV{ping_timeout} || 3;
	$p = Net::Ping->new($ping_proto);
}

sub ping {
	my $str = shift;
	
	my $res = 1;
	$res = 0 if $p->ping($str, $timeout);

	return $res;
}

1;

