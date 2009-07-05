package perltugues::operadores::algoritmo;
use base "perltugues::operadores";
use perltugues::operador;

sub new {
   my $class = shift;
   my $self  = bless $class->SUPER::new, $class;
   $self->novo_op(
      "op" => ":", antes => 1, depois => "*", meth => "cria",
      parse => sub{
                   my %vars;
                   my @pars;
                   for my $p (@_){
                      next unless exists $p->{const};
                      push @pars, $p->{const};
                   }
                   my $tipo = shift @pars;
                   @vars{@pars} = ($tipo) x @pars;
                   return \%vars;
                  },
   );
   $self->novo_op(
      "op" => "++", antes => 0, depois => 1,  meth => "preincr",
      parse => sub{
                   @_ = grep {keys %$_} @_;
                   my $var = shift;
                   my($var_nome) = values %$var;
                   unless(exists $var->{var}){
                      #die qq|"$var_nome" não é uma variavel e não pode ser incrementada$/|
                   }
                   return;
      },
   );
   $self->novo_op(
      "op" => "++", antes =>1, depois => 0,  meth => "posincr",
      parse => sub{
                   @_ = grep {keys %$_} @_;
                   my $var = shift;
                   my($var_nome) = values %$var;
                   unless(exists $var->{var}){
                      #die qq|"$var_nome" não é uma variavel e não pode ser incrementada$/|
                   }
                   return;
      },
   );
   $self->novo_op(
      "op" => "=", antes => 1, depois => 1, meth => "atrib",
      parse => sub{
                   my $var1 = shift;
                   my $var2 = shift;
                   my($var_tipo, $var_nome) = %$var1;
                   unless(exists $var1->{var}){
                      die qq|O(a) $var_tipo "$var_nome" não pode receber uma atribuição$/|
                   }
                   return;
                  },
   );
   $self->novo_op(
      "op" => "," , antes => 1, depois => 1, meth => "lista"
   );
   $self->novo_op(
      "op" => "=>", antes => 1, depois => 1, meth => "lista"
   );
   $self->novo_op(
      "op" => "+" , antes => 1, depois => 1, meth => "soma"
   );
   $self->novo_op(
      "op" => "*" , antes => 1, depois => 1, meth => "mult"
   );
   $self->novo_op(
      "op" => "/" , antes => 1, depois => 1, meth => "div"
   );
   $self->novo_op(
      "op" => "-" , antes => 1, depois => 1, meth => "subt"
   );
   $self;
}

42;
