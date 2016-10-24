use Test::More tests=>7;
use DBI;
use AnyEvent;
use AnyEvent::Fork;
use AnyEvent::Fork::Pool;
use Getopt::Long;
use Config::General;

use Dir::Self;
use lib __DIR__.'/../lib';
use Anypinger;

my $mod = 'Pinger';
my $sub = 'ping';
my $config_file = __DIR__.'/../t/anypinger.conf';

my ($ap, $conf, $dbh, $hosts, $res);

#Get config
ok (
   $conf = +{ Config::General->new($config_file)->getall() }, 'Get config'
);

#Create object
ok (
   $ap = Anypinger->new($conf), 'Create object'
);

#DB connect
ok (
   $dbh = $ap->db_connect(), 'DB connect'
);

#Deploy DB
ok (
   _deploy_db($dbh), 'Deploy DB'
);

#Get hosts
ok (
   $hosts = $ap->get_hosts($dbh), 'Get hosts from DB'
);

#SKIP: {
#    skip 'icmp ping requires root privilege', 2 if $<;
    #Ping hosts
    ok (
       $res = $ap->do( module  => $mod,
                       sub     => $sub,
                       hosts   => $hosts,
                       dbh     => $dbh ),
       'Ping hosts'
    );
    
    #Validate result
    is ($res, "127.0.0.1 : 0 -> 0\n1.1.1.1 : 0 -> 1\n", 'Validate result');
#};
    

done_testing;

sub _deploy_db{
    my $dbh = shift;
    $dbh->do("create table devices(id int, ip text, status int)");
    $dbh->do("insert into devices(id, ip, status) values(1, '127.0.0.1', 0),(2, '1.1.1.1', 0)");    
}