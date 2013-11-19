package FFI::AgainstType::ModuleBuild;

use strict;
use warnings;
use base qw( Module::Build );

sub new
{
  my($class, %args) = @_;
  
  $args{c_source} = 'xs';
  
  $class->SUPER::new(%args);
}

1;
