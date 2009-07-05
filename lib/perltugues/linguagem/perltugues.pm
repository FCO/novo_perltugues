package perltugues::linguagem::perltugues;
use base "perltugues::linguagem";

use perltugues::operadores::algoritmo;

sub new {
   my $class = shift;
   my $self  = bless {}, $class;

   $self->operadores(perltugues::operadores::algoritmo->new);

   $self;
}

42
