#!/usr/bin/perl -w

use strict ;

use Tie::Const ':ALL' ;

=pod

Test harness for Tie::Const.pm.

These tests are not comprehensive, but then tests never are :-)
In particular they do not test for things that Perl itself will
catch with strict and/or -w.

Copyright(c) Mark Summerfield 1998/9. All Rights Reserved. This program is
free software; you can redistribute it and/or modify it under the GPL. 

=cut

my $debugging = 0 ; # Use this to debug this test script.
my $test      = 1 ;

$debugging = 1 if $ARGV[0] and $ARGV[0] eq '-d' ;

print "1..35\n" ;

my $S1 ;

&create_a_const_scalar ;
&create_a_const_scalar_with_invalid_syntax ;
&const_a_const_scalar ;
&assign_to_a_const_scalar ;
&reconst_a_const_scalar ;
&reconst_a_const_scalar_with_invalid_syntax ;
&unconst_a_const_scalar ;
&untie_a_const_scalar ;
&undef_a_const_scalar ;

&newpage if $debugging ;

my %H ;

&create_a_const_hash_with_a_list ;
&create_a_const_hash_with_an_anonymous_hash ;
&create_a_const_hash_with_a_list_with_invalid_syntax ;
&create_a_const_hash_with_a_list_with_an_odd_num_of_elements ;
&const_a_const_hash ;
&assign_to_a_const_hash ;

&newpage if $debugging ;

&clear_a_const_hash_using_assignment ;
&clear_a_const_hash_using_undef ;
&delete_an_element_from_a_const_hash ;
&assign_to_an_element_from_a_const_hash ;
&reconst_a_const_hash ;
&reconst_a_const_hash_with_invalid_syntax ;
&unconst_a_const_hash ;
&untie_a_const_hash ;
&undef_a_const_hash ;

&newpage if $debugging ;

unconst \%H ;

&create_a_const_hash_element_scalar ;
&const_a_const_hash_element_scalar ;
&assign_to_a_const_hash_element_scalar ;
&reconst_a_const_hash_element_scalar ;
&unconst_a_const_hash_element_scalar ;
&untie_a_const_hash_element_scalar ;
&undef_a_const_hash_element_scalar ;

&newpage if $debugging ;

&reconst_non_reconstable_scalar ;
&reconst_non_reconstable_hash ;
&unconst_non_unconstable_scalar ;
&unconst_non_unconstable_hash ;

exit ;

################################
### SCALAR TESTS

################################
sub create_a_const_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        const $S1 => "Test $test" ;
        die if $S1 ne "Test $test" ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub create_a_const_scalar_with_invalid_syntax {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            const my $S2 = "Test $test" ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub const_a_const_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            const $S1 => "Test $test" ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub assign_to_a_const_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            $S1 = "Test $test" ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub reconst_a_const_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        reconst $S1 => "Test $test" ;
        die if $S1 ne "Test $test" ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub reconst_a_const_scalar_with_invalid_syntax {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            reconst $S1 = "Test $test" ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub unconst_a_const_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            const my $S2 => "Test $test" ;
            unconst $S2 ;
            die "Failed to retain unconst'ed value" if $S2 ne "Test $test" ;
            $S2 = 0 ; # This should be allowed now.
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub untie_a_const_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            untie $S1 ;
            $S1 = 0 ; # This should be allowed now.
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub undef_a_const_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            const $S1 => "Test $test" ;
            undef $S1 ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}


################################
### HASH TESTS

################################
sub create_a_const_hash_with_a_list {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        const \%H => ( A => 1, B => 2, C => 3 ) ;
        die if $H{C} != 3 ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub create_a_const_hash_with_an_anonymous_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        my %H1 ;
        const \%H1 => { %H, D => 4 } ;
        die if $H1{C} != 3 or $H1{D} != 4 ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub create_a_const_hash_with_a_list_with_invalid_syntax {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            const %H1 => ( A => 1, B => 2, C => 3 ) ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub create_a_const_hash_with_a_list_with_an_odd_num_of_elements {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            const \%H1 => ( 'A' => 1, 'B' => 2, 'C' ) ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub const_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            const \%H => ( A => 1, B => 2 ) ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub assign_to_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            %H = ( A => 1, B => 2 ) ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub clear_a_const_hash_using_assignment {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            %H = () ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub clear_a_const_hash_using_undef {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            undef %H ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub delete_an_element_from_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            delete $H{A} ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub assign_to_an_element_from_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            $H{A} = 100 ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub reconst_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        reconst \%H => ( X => 100, Y => 200, Z => 300 ) ;
        die if $H{Z} != 300 or exists $H{A} ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub reconst_a_const_hash_with_invalid_syntax {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            reconst %H => ( X => 100, Y => 200, Z => 300 ) ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub unconst_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            const \%H1 => ( P => 2, Q => 4 ) ;
            unconst \%H1 ;
            die "Failed to retain unconst'ed value" if $H1{P} != 2 or $H1{Q} != 4 ;
            %H1 = () ; # This should be allowed now.
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub untie_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            const \%H1 => ( P => 2, Q => 4 ) ;
            untie %H1 ;
            %H1 = () ; # This should be allowed now.
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub undef_a_const_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            const \%H1 => ( P => 2, Q => 4 ) ;
            undef %H1 ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}


################################
### SCALAR TESTS ON A HASH ELEMENT

################################
sub create_a_const_hash_element_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        const $H{X} => "Test $test" ;
        die if $H{X} ne "Test $test" ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub const_a_const_hash_element_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            const $H{X} => "Test $test" ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub assign_to_a_const_hash_element_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            $H{X} = "Test $test" ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub reconst_a_const_hash_element_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        reconst $H{X} => "Test $test" ;
        die if $H{X} ne "Test $test" ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub unconst_a_const_hash_element_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            $H1{P} = 5 ;
            const $H1{P} => $H1{P} ;
            unconst $H1{P} ;
            die "Failed to retain unconst'ed value" if $H1{P} != 5 ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub untie_a_const_hash_element_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            const $H1{P} => 5 ;
            untie $H1{P} ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub undef_a_const_hash_element_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 ;
            $H1{P} = 5 ;
            const $H1{P} => $H1{P} ;
            undef $H1{P} ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
### EXTRA MISCELLANEOUS TESTS


################################
sub reconst_non_reconstable_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my $S ;
            reconst $S => 1 ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub reconst_non_reconstable_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 = ( A => 1, B => 2 ) ;
            reconst \%H1 => \%H1 ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}


################################
sub unconst_non_unconstable_scalar {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my $S ;
            unconst $S ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}

################################
sub unconst_non_unconstable_hash {
    print +( caller( 0 ) )[3], ": " if $debugging ;
    eval {
        eval {
            my %H1 = ( A => 1, B => 2 ) ;
            unconst \%H1 ;
        } ;
        warn "\ncaught: $@" if $@ and $debugging ;
        die if not $@ ;
        print "ok $test\n" ;
    } ;
    print "not ok $test\n" if $@ ;
    $test++ ;
}




sub newpage {
    print "[MORE]" ;
    my $dummy = <STDIN> ;
}

__END__

