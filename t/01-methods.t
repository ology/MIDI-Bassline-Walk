#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

use_ok 'MIDI::Bassline::Walk';

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

$got = $obj->generate('C7b5', 4);
is scalar(@$got), 4, 'generate';

$expect = [qw(41 43 45)]; # C-F note intersection
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
$got = $obj->generate('Dm7', 99);
$got = grep { $_ == $expect } @$got;
ok !$got, 'modal';

done_testing();
