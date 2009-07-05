package perltugues::operadores;
use perltugues::operador;
use perltugues::parser;

sub new {
   my $class = shift;
   my $self  = bless {ops => {}}, $class;
   $self;
}

sub novo_op {
   my $self = shift;
   my $op = perltugues::operador->new(@_);
   if(exists $self->{ops}->{$op->op}){
      push @{ $self->{ops}->{$op->op} }, $op;
   }
   else {
      $self->{ops}->{$op->op} = [$op];
   }
}

sub op {
   my $self = shift;
   my $op   = shift;

   return unless exists $self->{ops}->{$op};
   @{ $self->{ops}->{$op} }
}

sub eh_op {
   my $self = shift;
   my $op   = shift;

   scalar $self->op($op);
}

sub escolhe_op {
   my $self   = shift;
   my $op     = shift;
   my $antes  = shift || 0;
   my $depois = shift || 0;

   return unless $self->eh_op($op);
   
   my @ops =
                 grep {
                    if($_->antes eq "*"){
                       return $_ if $_->depois <= $depois;
                    }elsif($_->depois eq "*"){
                       return $_ if $_->antes == $antes;
                    } else {
                       return $_ if $_->antes == $antes and $_->depois <= $depois;
                    }
                   } @{ $self->{ops}->{$op} };
   die qq|Uso redundante do operador "$op"$/| if @meth > 1;
   die qq|Uso desconhecido do operador "$op"$/| unless @meth;
   $ops[0]
}

sub meth {
   my $self   = shift;
   my $op     = shift;
   my @antes  = @{ shift() };
   my @depois = @{ shift() };

   @antes  = grep {defined $_} @antes;
   @antes  = grep {not ref $_ or (ref $_ eq "HASH" and keys %$_)} @antes;
   @depois = grep {defined $_} @depois;
   @depois = grep {not ref $_ or (ref $_ eq "HASH" and keys %$_)} @depois;

   my $eop = $self->escolhe_op($op, scalar @antes, scalar @depois);
   my @resto_antes  = @antes;
   my @resto_depois = @depois;
   my $ant = $eop->antes  eq "*" ? @depois : $eop->antes;
   my $dep = $eop->depois eq "*" ? @depois : $eop->depois;
   @antes  = splice @resto_antes , @resto_antes - $ant, $ant;
   @depois = splice @resto_depois, 0, $dep;
   my @ret = grep {defined $_} ({$eop->meth => [@resto_antes, grep {defined $_} @antes, @depois]}, @resto_depois);
   my($vars) = $eop->parse(@resto_antes, grep {defined $_} @antes, @depois);
   ($vars, \@ret)
}

sub ops {
   my $self = shift;
   keys %{ $self->{ops} }
}


42;
