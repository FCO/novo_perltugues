package perltugues::parser;
#use 5.10.0;
use Carp;
use strict;
use warnings;
use Data::Dumper;

#use perltugues::operadores;

my %tipos = (inteiro => {default => 0}, caracter => {default => ''});

my $ops;
my $fim_cmd    = ";";
my @inicio_prio = ("(");
my @fim_prio    = (")");
my @inicio_bloco = ("{", "inicio");
my @fim_bloco    = ("}", "fim");
my @funcoes    = qw/escreva/;

sub re_escapa {
   my $str = shift;
   $str =~ s/([](){}+?*.[-])/\\$1/g;
   return $str;
}

sub reduz_lista {
   my $list = shift;
   if(ref $list eq "ARRAY"){
      return map{reduz_lista($_)} @$list;
   }
   return $list unless exists $list->{lista} and ref $list->{lista} eq "ARRAY";
   my @ret;
   for my $val (@{$list->{lista}}){
      next unless ref $val eq "HASH";
      if(exists $val->{lista}){
         push @ret, reduz_lista($val);
      } else {
         push @ret, $val;
      }
   }
   return @ret;
}

sub separa {
   my $str = shift;
   my @oper = @_;
   my @strs;

   if(ref $str eq "ARRAY"){
      push @strs, @$str;
   } else {
      push @strs, $str;
   }
   my @ret;
   CODE: for(@strs){
      for my $op (@oper){
         my $op_re = re_escapa($op);
         if(/$op_re/){
            if(defined $`){
               if(defined $'){
                  push @ret, $`, $&, $';
               }else{
                  push @ret, $`, $&;
               }
            }elsif(defined $'){
               push @ret, $&, $';
            }
            undef $_;
            next CODE;
         }
      }
      push @ret, $_ if defined $_;
   }
   @ret
}

sub parse {
   my $class = shift;
   my $lang  = shift;
   my $code  = shift;
   my @code  = split /\b/, join "", $code;
   my @code2;
   my $base = "perltugues::linguagem::$lang";
   $lang = eval "use $base; $base->new";
   $ops = $lang->operadores;
   CODE: for (@code){
      my $ret =   [separa($_  , sort {length $b <=> length $a} $ops->ops)];
      $ret    =   [separa($ret, @inicio_bloco, @fim_bloco)];
      $ret    =   [separa($ret, @inicio_prio, @fim_prio)];
      push @code2, separa($ret, $fim_cmd);
   }
   @code = @code2;
   @code2 = ();
   my(@abred, @fechad);
   my(@abres, @fechas);
   for(0..$#code){
      if($code[$_] =~ /^\W*"\W*"\W*$/){
         next;
      }elsif(@abred == @fechad){
         push @abred, $_ if $code[$_] =~ /"\W*$/ and not $code[$_] =~ /\\"\W*$/;
      }else{
         push @fechad, $_ if $code[$_] =~ /^\W*"/
      }
      if($code[$_] =~ /^\s*'\W*'\s*$/){
         next;
      }elsif(@abres == @fechas){
         push @abres, $_ if $code[$_] =~ /'\W*$/ and not $code[$_] =~ /\\'\s*$/;
      }else{
         push @fechas, $_ if $code[$_] =~ /^\W*'/
      }
   }
   croak "Faltou aspas duplas (\")" if @abred != @fechad;
   croak "Faltou aspas simples (\')" if @abres != @fechas;
   
   my %strings;
   while(@abred){
      my @aspas;
      my $prim = shift @abred;
      my $ulti = shift @fechad;
      for my $indice($prim .. $ulti){
         push @aspas, $code[$indice];
      }
      $strings{$prim} = {str => join("", @aspas), qtd => ($ulti - $prim) + 1};
   }
   while(@abres){
      my @aspas;
      my $prim = shift @abres;
      my $ulti = shift @fechas;
      for my $indice($prim .. $ulti){
         push @aspas, $code[$indice];
      }
      $strings{$prim} = {str => join("", @aspas), qtd => ($ulti - $prim) + 1};
   }
   
   for my $indice(keys %strings){
      splice @code, $indice, $strings{$indice}->{qtd}, $strings{$indice}->{str};
   }
   
   for(@code){
      s/^\s+|\s+$//g;
   }
   
   @code = grep {!/^\s*$/} @code;
   
   #print "($_)$/"for@code;

   my @arvore;
   @arvore = cria_arvore(\@code);
   print Dumper \@arvore;
}

sub separa_cmd {
   my @code = @_;
   my $indice = 0;
   my @retorno;
   for my $cmd (@code){
      if($cmd eq $fim_cmd){
         $indice++;
         next;
      }
      push @{$retorno[$indice]}, $cmd;
   }
   @retorno;
}

sub pega_prio {
   my $code = shift;
   my %var = @_;
   my @prio;
   my $cmd = shift @$code;
   while(defined $cmd and not grep {$cmd eq $_} @fim_prio){
      if(grep {$cmd eq $_} @inicio_prio){
         push @prio, pega_prio($code, %var);
      } else {
         push @prio, $cmd;
      }
      $cmd = shift @$code;
   }
   return cria_arvore(\@prio, 0, %var)
}

sub pega_bloco {
   my $code = shift;
   my %var = @_;
   my @bloco;
   my $cmd = shift @$code;
   while(defined $cmd and not grep {$cmd eq $_} @fim_bloco){
      if(grep {$cmd eq $_} @inicio_bloco){
         push @bloco, pega_bloco($code, %var);
      } else {
         push @bloco, $cmd;
      }
      $cmd = shift @$code;
   }
   return {bloco => [cria_arvore(\@bloco, 0, %var)]}
}

sub cria_arvore {
   my $code = shift;
   my $um_cmd = shift || 0;
   my %vars = @_;
   my @code_tree;
   my @cmd_atual;
   while(@$code) {
      my $cmd = shift @$code;
      next unless defined $cmd;
      if(0){
      }elsif(ref $cmd){
         push @cmd_atual, $cmd;
      }elsif(grep {$cmd eq $_} @funcoes){
      }elsif(grep {$cmd eq $_} @inicio_prio){
         push @cmd_atual, pega_prio($code, %vars);
      }elsif(grep {$cmd eq $_} @fim_prio){
         die qq|Bloco de prioridade fechado ("$cmd") mas não aberto|;
      }elsif(grep {$cmd eq $_} @inicio_bloco){
         push @cmd_atual, pega_bloco($code, %vars);
      }elsif(grep {$cmd eq $_} @fim_bloco){
         die qq|Bloco de prioridade fechado ("$cmd") mas não aberto|;
      }elsif(exists $vars{$cmd}){
         push @cmd_atual, {var => $cmd};
      }elsif($ops->eh_op($cmd)){
         my(@ant, @pos);
         push @ant, grep {defined $_} @cmd_atual;
         @cmd_atual = ();
         @pos = cria_arvore($code, $um_cmd + 1, %vars);
         my $local_vars;
         push @cmd_atual, grep {defined $_} $ops->meth($cmd, [reduz_lista(\@ant)], [reduz_lista(\@pos)]);
         #push @cmd_atual, grep {defined $_} $ops->meth($cmd, \@ant, \@pos);
         #($local_vars) = $operadores{$cmd}->{parse}->(@ant, reduz_lista(@pos_parse))
         #   if exists $operadores{$cmd}->{parse};
         #@vars{keys %$local_vars} = values %$local_vars;
      }elsif($cmd eq $fim_cmd){
         push @code_tree, @cmd_atual;
         @cmd_atual = ();
         if($um_cmd){
            unshift @$code, $cmd;
            last if $um_cmd;
         }
      }else{
         push @cmd_atual, {"const" => $cmd};
      }
   }
   push @code_tree, @cmd_atual;
   @cmd_atual = ();
   @code_tree;
}
