package perltugues::linguagem;

sub funcoes {
   my $self = shift;
   if(@_){
      $self->{funcoes} = shift;
   }else{
      $self->{funcoes};
   }
}

sub operadores {
   my $self = shift;
   if(@_){
      $self->{operadores} = shift;
   }else{
      $self->{operadores};
   }
}

42
