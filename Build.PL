use strict;
use warnings;

use Module::Build;

my $b = Module::Build->subclass(
      class => "Module::Build::Custom",
      code => <<'SUBCLASS' );

  sub ACTION_test {
      my $self = shift;
      # YOUR CODE HERE
      unshift (@INC, './t', );
      $self->SUPER::ACTION_test;
  }
SUBCLASS


my $build = $b->new(
    module_name   => 'Anypinger',
    dist_abstract => 'Asynchronous multiprocessing pinger',
    dist_author   => 'mazay',
    license       => 'perl',
    requires => {
        'perl'                   => '5.8.0',
        'AnyEvent'               => 0,
        'AnyEvent::Fork'         => 0,
        'AnyEvent::Fork::Pool'   => 0,
	    'Net::Ping'              => 0,
        'DBI'                    => 0,
        'Config::General'        => 0,
        'Getopt::Long'           => 0,
        'Dir::Self'              => 0,
    },
    build_requires => {
        'Module::Build'          => 0,
        'Test::More'             => 0
    },
    script_files => {
        'scripts/anypinger.pl'  => undef,
    },
    recursive_test_files => 1,
    #install_base => '/opt/anypinger',
);
#$build->install_path(script => $build->install_base . "/scripts");
$build->create_build_script();
