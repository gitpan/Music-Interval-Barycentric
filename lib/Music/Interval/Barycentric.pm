package Music::Interval::Barycentric;
BEGIN {
  $Music::Interval::Barycentric::AUTHORITY = 'cpan:GENE';
}
# ABSTRACT: Compute barycentric musical interval space

use strict;
use warnings;

use List::Util qw( min );

use constant {
    SIZE  => 3,  # Triad chord
    SCALE => 12, # Scale notes
};

our $VERSION = '0.0102';


sub barycenter {
    my $size  = shift || SIZE;  # Default to a triad
    my $scale = shift || SCALE; # Default to the common scale notes
    return ($scale / $size) x $size;
}


sub distance {
    my ($chord1, $chord2) = @_;
    my $distance = 0;
    for my $note (0 .. @$chord1 - 1) {
        $distance += ($chord1->[$note] - $chord2->[$note]) ** 2;
    }
    $distance /= 2;
    return sqrt $distance;
}


sub orbit_distance {
    my ($chord1, $chord2) = @_;
    my @distance = ();
    for my $perm (cyclic_permutation(@$chord2)) {
        push @distance, distance($chord1, $perm);
    }
    return min(@distance);
}


sub forte_distance {
    my ($chord1, $chord2) = @_;
    my @distance = ();
    for my $perm (cyclic_permutation(@$chord2)) {
        push @distance, distance($chord1, $perm);
        push @distance, distance($chord1, [reverse @$perm]);
    }
    return min(@distance);
}


sub cyclic_permutation {
    my @set = @_;
    my @cycles = ();
    for my $backward (reverse 0 .. @set - 1) {
        for my $forward (0 .. @set - 1) {
            push @{ $cycles[$backward] }, $set[$forward - $backward];
        }
    }
    return @cycles;
}


sub evenness_index {
    my $chord = shift;
    my @b = barycenter( scalar @$chord );
    my $i = distance( $chord, \@b );
    return $i;
}

__END__

=pod

=encoding UTF-8

=head1 NAME

Music::Interval::Barycentric - Compute barycentric musical interval space

=head1 VERSION

version 0.0102

=head1 SYNOPSIS

 print join(', ', barycenter(3)), "\n";
 @chords = [qw(3 4 5), qw(0 4 7)];
 printf "D: %.3f\n", distance($chords[0], $chords[1]);
 print evenness_index($chords[0]);
 print orbit_distance(@chords), "\n";
 print forte_distance(@chords), "\n";

=head1 DESCRIPTION

Barycentric chord analysis

=head1 FUNCTIONS

=head2 barycenter()

Return the barycenter (the "central coordinate")  given an integer representing
the number of notes in a chord.

=head2 distance()

Interval space distance metric between chords.

* This is used by the orbit_distance() and evenness_index() functions.

=head2 orbit_distance()

  $d = orbit_distance($chord1, $chord2);

Return the distance from C<chord1> to the minimum of the cyclic permutations
for C<chord2>.

=head2 forte_distance()

TODO

=head2 cyclic_permutation()

Return the list of cyclic permutations of the given intervals.

=head2 evenness_index()

Return a chord distance from the barycenter.

=head1 SEE ALSO

http://www.amazon.com/Geometry-Musical-Chords-Interval-Representation/dp/145022797X

=head1 AUTHOR

Gene Boggs E<lt>gene@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2012, Gene Boggs

This code is licensed under the same terms as Perl itself.

=head1 AUTHOR

Gene Boggs <gene@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Gene Boggs.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
