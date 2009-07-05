package perltugues::operador;

sub new {
   my $class = shift;
   my %par   = @_;
   my $self  = bless {%par}, $class;
   $self
}

sub op {
   my $self = shift;
   if(@_){
      $self->{op} = shift;
   }else{
      $self->{op};
   }
}

sub parse {
   my $self = shift;
   if(@_){
      $self->{parse} = shift;
   }else{
      $self->{parse};
   }
}

sub antes {
   my $self = shift;
   if(@_){
      $self->{antes} = shift;
   }else{
      $self->{antes};
   }
}

sub depois {
   my $self = shift;
   if(@_){
      $self->{depois} = shift;
   }else{
      $self->{depois};
   }
}

sub assinatura {
   my $self = shift;
   return ($self->{antes}, $self->{depois});
}

sub meth {
   my $self = shift;
   if(@_){
      $self->{meth} = shift;
   }else{
      $self->{meth};
   }
}

42
