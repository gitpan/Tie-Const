use ExtUtils::MakeMaker ;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile(
    'NAME'         => 'Tie::Const',
    'VERSION_FROM' => 'Const.pm', # finds $VERSION
    'DISTNAME'     => 'Tie-Const',
    ($] >= 5.005 ?
        (
            ABSTRACT => 'Constants with consistent syntax',
            AUTHOR   => 'Mark Summerfield <summer@chest.ac.uk>',
        ) : () ),
    'LIBS'         => [''],   # e.g., '-lm'
    'DEFINE'       => '',     # e.g., '-DHAVE_SOMETHING'
    'INC'          => '',     # e.g., '-I/usr/include/other'
    'dist'         => { COMPRESS => "gzip -9", SUFFIX => "gz" }
) ;
