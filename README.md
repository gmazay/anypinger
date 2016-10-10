# anypinger
**Asynchronous multiprocessing pinger**


**Dependencyes:**
...
AnyEvent
AnyEvent::Fork
AnyEvent::Fork::Pool
Net::Ping
DBI
Config::General
Getopt::Long
Dir::Self
Module::Build
...

**Building & installing modules:**
...
perl Builder.PL
./Build installdeps
./Build manifest
./Build test
./Build install
...

**Run:**
...
./scripts/anypinger.pl -c anypinger.conf
...
