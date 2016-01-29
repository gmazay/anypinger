package anypinger;

use strict;
use warnings;

use Net::Ping;
my $p;

sub init {
	$p = Net::Ping->new("icmp");

	return;
}

sub ping {
	my $str = shift;
	if ( $p->ping($str, 3) ){$str = 0;}
	else {$str = 1;}

	return $str;
}

1;

