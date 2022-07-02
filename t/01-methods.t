#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;
use Test::Exception;

use_ok 'MIDI::Bassline::Walk';

subtest throws => sub {
    throws_ok { MIDI::Bassline::Walk->new(guitar => 'foo') }
        qr/not a boolean/, 'bogus guitar';
    throws_ok { MIDI::Bassline::Walk->new(modal => 'foo') }
        qr/not a boolean/, 'bogus modal';
    throws_ok { MIDI::Bassline::Walk->new(chord_notes => 'foo') }
        qr/not a boolean/, 'bogus chord_notes';
    throws_ok { MIDI::Bassline::Walk->new(tonic => 'foo') }
        qr/not a boolean/, 'bogus tonic';
    throws_ok { MIDI::Bassline::Walk->new(verbose => 'foo') }
        qr/not a boolean/, 'bogus verbose';
    throws_ok { MIDI::Bassline::Walk->new(keycenter => 'foo') }
        qr/not a valid key/, 'bogus keycenter';
    throws_ok { MIDI::Bassline::Walk->new(intervals => 'foo') }
        qr/not an array reference/, 'bogus intervals';
    throws_ok { MIDI::Bassline::Walk->new(octave => 'foo') }
        qr/not a positive integer/, 'bogus octave';
    throws_ok { MIDI::Bassline::Walk->new(scale => 'foo') }
        qr/not a code reference/, 'bogus scale';
};

subtest attrs => sub {
    my $obj = new_ok 'MIDI::Bassline::Walk' => [
        verbose => 1,
    ];

    is $obj->octave, 2, 'octave';
    is $obj->verbose, 1, 'verbose';
    is ref $obj->scale, 'CODE', 'scale';

    my $got = $obj->scale->('C7b5');
    is $got, 'major', 'scale';

    my $expect = [qw(-3 -2 -1 1 2 3)];
    is_deeply $obj->intervals, $expect, 'intervals';
};

subtest generate => sub {
    my $obj = new_ok 'MIDI::Bassline::Walk' => [
        verbose => 1,
    ];

    my $got = $obj->generate('C7b5', 4);
    is scalar(@$got), 4, 'generate';

    my $expect = [qw(41 43 45)]; # C-F note intersection
    $got = $obj->generate('C', 4, 'F');
    $got = grep { $_ eq $got->[-1] } @$expect;
    ok $got, 'intersection';

    $obj = new_ok 'MIDI::Bassline::Walk' => [
        verbose => 1,
        tonic   => 1,
    ];
    $expect = [qw(36 40 43)]; # I,III,V of the C2 major scale
    $got = $obj->generate('C', 4);
    $got = grep { $_ eq $got->[0] } @$expect;
    ok $got, 'tonic';

    $obj = new_ok 'MIDI::Bassline::Walk' => [
        verbose => 1,
        modal   => 1,
    ];
    $expect = 46; # = A#2
    $got = $obj->generate('Dm7', 99); # An A# would surely not turn up in 99 rolls! Right? Uhh...
    $got = grep { $_ != $expect } @$got;
    ok $got, 'modal';

    $obj = new_ok 'MIDI::Bassline::Walk' => [
        verbose     => 1,
        modal       => 1,
        chord_notes => 0,
    ];
    $expect = 44; # = G#2
    $got = $obj->generate('Dm7b5', 99); # A G# would surely not...
    $got = grep { $_ != $expect } @$got;
    ok $got, 'chord_notes';

    #$obj = MIDI::Bassline::Walk->new(
    #    verbose   => 1,
    #    guitar    => 1,
    #    modal     => 1,
    #    keycenter => 'Bb',
    #);
    #$got = $obj->generate('F7', 4);
};

done_testing();
