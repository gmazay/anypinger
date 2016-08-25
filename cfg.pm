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
%db = (
    'localhost'  => {
        'db'     => 'db_name',
        'user'   => 'db_user',
        'passwd' => 'db_password'
    }
);
#####################################################

sub q_connect {
#-- Usage: q_connect([Connection_name],[DB_name]);
    my $cn=($_[0]?$_[0]:'localhost');
    my $database=($_[1]?$_[1]:$db{$cn}{'db'});
    my $dbh=DBI->connect( "DBI:mysql:$database:$db{$cn}{'host'}",$db{$cn}{'user'}, $db{$cn}{'passwd'},
                         { mysql_enable_utf8 => 1, on_connect_do => [ "SET NAMES 'utf8'"] } )
        || die print "Can't connect database";
    return $dbh;
}

1;
 
