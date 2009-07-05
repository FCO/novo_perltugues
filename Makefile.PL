use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'novo_perltugues',
    AUTHOR              => 'Fernando C. de Oliveira <fco@cpan.org>',
    VERSION_FROM        => 'lib/novo_perltugues.pm',
    ABSTRACT_FROM       => 'lib/novo_perltugues.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'novo_perltugues-*' },
);
