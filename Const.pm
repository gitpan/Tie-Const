package Tie::Const ; # Documented at the __END__.

# $Id: Const.pm,v 1.1 1999/09/09 17:38:47 root Exp root $

require 5.004 ;

use strict ;

use Carp ;

use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS ) ;

$VERSION = '1.05' ; 


use Exporter() ;

@ISA       = qw( Exporter ) ;

@EXPORT    = qw( const ) ;
@EXPORT_OK = qw( const reconst unconst ) ;

%EXPORT_TAGS = ( ALL => [ qw( const reconst unconst ) ] ) ;


#############################
sub const {

    croak "Usage: const [my] \$SCALAR|\\\%HASH => <scalar>|[\\]<hash>"
        if scalar @_ < 2 ;
    croak "Too many arguments: first hash MUST be passed by reference"
        if scalar @_ > 2 and not ref $_[0] ;
    croak "Can only make scalars and hash references const"
        if ref $_[0] and ref $_[0] ne 'HASH' ;
    if( ( not ref $_[0] and tied $_[0] ) or
        ( ref $_[0] eq 'HASH'  and tied %{ $_[0] } ) ) {
        # If a programmer uses const on an already const variable we want
        # to tell them since its probably an error.
        croak "Use reconst to redefine a constant's value" ;
    }

    if( not ref $_[0] ) {
        tie $_[0], 'Tie::Const::_Scalar', $_[1] ;
    }
    elsif( ref $_[0] eq 'HASH' ) {
        croak "Attempt to assign odd number of elements to const hash"
            if not ref $_[1] and scalar @_ % 2 == 0 ;
        tie %{ $_[0] }, 'Tie::Const::_Hash', ref $_[1] ? %{ $_[1] } : @_[1..$#_] ;
    }
}


#############################
sub reconst {

    croak "Usage: reconst \$SCALAR|\\\%HASH => <scalar>|[\\]<hash>"
        if scalar @_ < 2 ;
    croak "Too many arguments: first hash MUST be passed by reference"
        if scalar @_ > 2 and not ref $_[0] ;
    croak "Can only reconst scalars and hash references"
        if ref $_[0] and ref $_[0] ne 'HASH' ;
    if( ( not ref $_[0] and not tied $_[0] ) or
        ( ref $_[0] eq 'HASH'  and not tied %{ $_[0] } ) ) {
        croak "Can only reconst a const" ;
    }

    if( not ref $_[0] ) {
        untie $_[0] ;      # Probably redundant, but let's be safe.
        tie $_[0], 'Tie::Const::_Scalar', $_[1] ;
    }
    elsif( ref $_[0] eq 'HASH' ) {
        croak "Attempt to assign odd number of elements to const hash"
            if not ref $_[1] and scalar @_ % 2 == 0 ;
        # We remember the new contents in case they're from the old hash
        # whose values will disappear when we untie it.
        my %hash = ref $_[1] ? %{ $_[1] } : @_[1..$#_] ;
        untie %{ $_[0] } ; # Probably redundant, but let's be safe.
        tie %{ $_[0] }, 'Tie::Const::_Hash', %hash ;
    }
}
    

#############################
sub unconst {

    croak "Usage: unconst \$SCALAR|\\\%HASH" if scalar @_ != 1 ;
    croak "Can only unconst scalars and hash references"
        if ref $_[0] and ref $_[0] ne 'HASH' ;
    if( ( not ref $_[0] and not tied $_[0] ) or
        ( ref $_[0] eq 'HASH'  and not tied %{ $_[0] } ) ) {
        croak "Can only unconst a const" ;
    }

    if( not ref $_[0] ) {
        my $scalar = $_[0] ;
        untie $_[0] ;
        $_[0] = $scalar ;
    }
    elsif( ref $_[0] eq 'HASH' ) {
        my %hash = %{ $_[0] } ; # Would "my @hash = %{ $_[0] } ;"
        untie %{ $_[0] } ;
        %{ $_[0] } = %hash ; # and "%{ $_[0] } = @hash ;" be more efficient?
    }
}


### Sub-package #############################

package Tie::Const::_Scalar ; # Do not use directly!


use Carp ;


#############################
sub TIESCALAR {
# We don't need this since the callers do the checks.
#    croak "Usage: tie [my] \$SCALAR, 'Tie::Const::Scalar', <scalar>"
#        if scalar @_ < 2 ;
    my $pkg  = shift ;
    my $self = shift ;

    bless \$self, $pkg ;
}


#############################
sub FETCH {
    my $self = shift ;

    $$self ;
}


#############################
sub STORE {

    croak "Attempt to overwrite const scalar" ;
}


### Sub-package #############################

package Tie::Const::_Hash ; # Do not use directly!


use Carp ;


#############################
sub TIEHASH {
# We don't need these since the callers do the checks.
#    croak "Usage: tie [my] \%HASH, 'Tie::Const::Hash', <hash>"
#        if scalar @_ < 2 ;
#    croak "Attempt to assign odd number of elements to const hash"
#        if scalar @_ % 2 == 0 ;
    my $pkg  = shift ;
    my %self = @_ ;

    bless \%self, $pkg ;
}


#############################
sub CLEAR {

    croak "Attempt to clear const hash" ;
}


#############################
sub STORE {

    croak "Attempt to overwrite an element of a const hash" ;
}


#############################
sub DELETE {

    croak "Attempt to delete an element of a const hash" ;
}


#############################
sub EXISTS {
    my $self = shift ;
    my $key  = shift ;

    exists $self->{$key} ;
}
    

#############################
sub FETCH { 
    my $self = shift ;
    my $key  = shift ;

    exists $self->{$key} ? $self->{$key} : undef ;
}


#############################
sub FIRSTKEY {
    my $self = shift ;

    my $reset_the_iterator = keys %$self ;
    each %$self ;
}


#############################
sub NEXTKEY {
    my $self = shift ;

    each %$self ;
}


1 ;


__END__

=head1 NAME

Tie::Const - Perl module to provide constant scalars and hashes.

=head1 SYNOPSIS

    use Tie::Const ; # Imports const.

    const my $SCALAR1 => 10 ;

    
    use Tie::Const qw( const reconst unconst ) ; # Or "use Tie::Const ':ALL' ;"

    const my $SCALAR2 => "Hello" ; # Note the =>, NOT =.
    
    const my $SCALAR3 => 42 ;

    const $SCALAR4    => $SCALAR3 ;

    reconst $SCALAR4  => 57 ;

    unconst $SCALAR4 ;

We can't use "my" to declare constant hashes directly so do the my first.

    my %HASH1 ;
    const \%HASH1   => \%HASH2 ; # Note that the first must be a reference.

    my( %HASH3, %HASH4 ) ;
    const \%HASH3   => ( a => 1, b => 2, c => 3 ) ; # Can pass literal hash
    const \%HASH4   => { a => 1, b => 2, c => 3 } ; # or hash ref.

    reconst \%HASH4 => ( %HASH4, d => 4, e => 5 ) ;
    
    unconst \%HASH4 ;

=head1 DESCRIPTION

=head2 Constant Scalars

    use Tie::Const ':ALL' ; # or "use Tie::Const qw( const reconst unconst ) ;"

    const my $CONSTANT => "Hello" ;

    my $var = $CONSTANT . "\n" ;

    my $val = $hash{$CONSTANT} ;
    
    print "$CONSTANT World" ;

Constants declared with C<const> look and behave like ordinary variables
and can be used anywhere a variable is used except that you can't
overwrite them. (You can however redefine them with C<reconst>, or turn
them back into ordinary variables again with C<unconst>.)

    use Tie::Const qw( const reconst unconst ) ;

Create a new scalar variable.

    my $SCALAR = "Hello" ;   

We can modify it anytime.

    $SCALAR .= " World" ;

Make that scalar variable a constant, assigning it a value.

    const $SCALAR => $SCALAR ;

Any attempt to overwrite C<$SCALAR>'s value will result in a trappable
(with eval) runtime error, so from here on in we are guaranteed that
no-one can change C<$SCALAR>'s value.

However, why merely embrace the definition of const that applies in
other computer languages when we can do so much more in Perl? It may be
that we want a variable to be constant most of the time, but in certain
circumstances we would like it to be changed. We can redefine its value
using C<reconst>.

    reconst $SCALAR => $SCALAR . "!\n" ;

C<$SCALAR> is I<still> read-only, but now it has a new constant value.

It may occur however that we have reached a point where we want it to be
an ordinary variable after all. There are two ways of achieving that.
One way is to use C<unconst>.

    unconst $SCALAR ;

C<$SCALAR> is now an ordinary variable again, and its value is the value
it held when it was made C<const>, or last C<reconst>'ed. If you don't
want to preserve the value you can untie it instead.

    untie $SCALAR ; # Works now but deprecated so don't rely on it.

The value that C<$SCALAR> holds now is the last value assigned to it
before it was made C<const> which could be C<undef> if it was defined
and declared at the same time. B<Do not rely on this behaviour>; you
should assume that an untie'd const must be redefined before reusing it.

Thus in subroutines where we would normally write:

    my $value = shift ;

or similar, we can now write

    const my $value = shift ;

to make it clear we only want to read the value not write to it.

=head2 Constant Hashes

    use Tie::Const qw( const reconst unconst ) ;

Create a new hash variable.

    my %HASH ;

Make that variable a constant and assign to it.

    const \%HASH => ( cyan => 4, magenta => 5, yellow => 6, black => 7 ) ;

Any attempt to overwrite any of C<%HASH>'s values or to clear C<%HASH>
itself will result in a trappable (with eval) runtime error, so from
here on in we are guaranteed that no-one can change C<%HASH> or its
values. Unless we C<reconst> it of course.

    reconst \%HASH => ( %HASH, red => 1, green => 2, blue => 3 ) ;

C<%HASH> is I<still> read-only, but now it has new constant values.

We can C<unconst> a hash just like a scalar.

    unconst \%HASH ;

C<%HASH> is now an ordinary variable again, and its values are the values
it held when it was made C<const>, or last C<reconst>'ed.
If you don't want to preserve the values you can untie it instead. (This
is more efficient.)

    untie %HASH ; # Works now but deprecated so don't rely on it.

=head2 Constant elements of I<non-const> hashes

Individual elements of non-const hashes can be made constant. They can be
C<reconst>'ed and C<unconst>'ed too of course. B<But beware that if the
non-const hash is cleared the const(s) will be lost along with it! Also const
hash elements can be deleted.>

B<Warning:> const hash elements can be deleted by C<%HASH = ()> and by
C<delete $HASH{$KEY}>.

    const $HASH{$KEY}    => "hash" ;

=head1 WHY ANOTHER CONSTANT MODULE?

Although Perl is my favourite programming language I find it annoying
that constants are not a built-in part of the language. For non-trivial 
programs I feel that constants are a real help. Hopefully one day 
they'll be part of the core language - maybe using the syntax offered 
here?

You can of course declare constants like this:

    sub CONSTANT () { "Constant" }

I am not keen on this approach because to get the values of your constants you
have to write them in one of several different ways depending on the context.
For example if I want to use the constant that I've just declared above in an
expression I can use it like this:

    my $var = CONSTANT . "\n" ;

This looks nice for C programmers. But if I want to use it as a hash key
I must use one of the following approaches so that it isn't treated as
the bareword C<CONSTANT> and converted by perl into the literal
C<"CONSTANT">:

    my $key = $hash{CONSTANT()} ;
    my $key = $hash{&CONSTANT} ;

And if I want to print the constant I have to use yet another syntax:

    print "@{[CONSTANT]}\n"

I wanted to be able to define a constant in such a way that I can use it
in any context that a variable can appear using a single syntax. Hence I
wrote this module.

=head2 EXAMPLES

(See DESCRIPTION.)

=head1 BUGS

Perl has a few built-in hashes, e.g. C<@ARGV>, C<%ENV>, and many built-in
scalars, e.g. C<$_>.

B<I would not recommend applying >C<const>
B< to any built-in scalar or hash with the possible exception of C<%ENV>!>

The only built-in hash which it might be sensible to apply C<const> to
is C<%ENV>; who knows it might even make a script slightly more secure
in some cases?

    const \%ENV => \%ENV ; # This seems OK.

You can even apply C<const> to particular keys of a I<non-const> hash.

    const $ENV{PATH} => '/usr/bin:/usr/local/bin' ;

Arrays are not included because support for tied arrays in Perl 5.004 is too
incomplete.

Hashes also have some problems: if a non-const hash is cleared any const
scalars in the non-const hash will be lost along with it! Also const hash
elements can be deleted.

=head1 CHANGES

1998/6/18   First release.

1998/6/25   First public release.

1999/01/18  Second public release. Arrays dropped: too incomplete.

1999/07/29  Third release. Minor changes.

1999/07/30  No effective changes. Corrections for CPAN and automatic testing.

1999/08/08  Changed licence to LGPL.

1999/09/09  Renamed package Tie::Const.pm as per John Porter's (CPAN) suggestion.


=head1 AUTHOR

Mark Summerfield. I can be contacted as <summer@chest.ac.uk> -
please include the word 'const' in the subject line.

=head1 COPYRIGHT

Copyright (c) Mark Summerfield 1998/9. All Rights Reserved.

This module may be used/distributed/modified under the LGPL.

=cut

