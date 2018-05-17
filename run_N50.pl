#!/usr/bin/perl
use strict;
use warnings;

my @fas = glob("*.fas");
foreach  (@fas) {
	$_=~/(\d*[a-zA-Z]+\d+)/;
	my $out = $1 . ".stats";
	system("perl N50Stat.pl -i $_ -o $out");
}
