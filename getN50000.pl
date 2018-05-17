#!/usr/bin/perl
use strict;
use warnings;

my @stas = glob("*.stats");
foreach  my $s (@stas) {
	$s=~/(\d*[a-zA-Z]+\d+)/;
	my $scaf = $1 .".fas";
	open IN,"$s" || die;
	while (<IN>) {
		chomp;
        if(/^N50/){
            $_=~/N50 length\s+(\d+)/;
             if ($1 >= 50000) {
				 system("move $scaf Ngt50000");
#				 system("move $s Ngt50000");
             }
		}
    }
	close IN;
}
