package cfg;
use Exporter();
@ISA = qw(Exporter);
@EXPORT = qw(%db $num_proc &q_connect);
use strict;
use DBI;
our(%db,$num_proc);

########### Configuration parameters ################

# Number of child processes
$num_proc=42;

# DB connection variables
$db{'localhost'}{'host'} = 'localhost';
$db{'localhost'}{'db'} = 'db_name';
$db{'localhost'}{'user'} = 'db_user';
$db{'localhost'}{'passwd'} = 'db_password';

#####################################################

sub q_connect {
#-- Usage: q_connect([Connection_name],[DB_name]);
	my $cn=($_[0]?$_[0]:'localhost');
	my $database=($_[1]?$_[1]:$db{$cn}{'db'});
	my $dbh=DBI->connect_cached("DBI:mysql:$database:$db{$cn}{'host'}",$db{$cn}{'user'}, $db{$cn}{'passwd'})
		|| die print "Can't connect database";
	$dbh->do("SET NAMES UTF8;") || die print $dbh->errstr();
	return $dbh;
}

1;
 
