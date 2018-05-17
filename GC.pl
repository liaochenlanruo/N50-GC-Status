#! /usr/bin/perl

use strict;
use warnings;
use List::Util qw(sum min max);
use Getopt::Long;
use File::Basename;

my $As = 0;
my $Ts = 0;
my $Gs = 0;
my $Cs = 0;
my $Ns = 0;

# Parameter variables
my $file;
my $helpAsked;
my $outFile = "";

GetOptions(
			"i=s" => \$file,
			"h|help" => \$helpAsked,
			"o|outputFile=s" => \$outFile,
		  );
if(defined($helpAsked)) {
	prtUsage();
	exit;
}
if(!defined($file)) {
	prtError("No input files are provided");
}

my ($fileName, $filePath) = fileparse($file);
$outFile = $file . "_n50_stat" if($outFile eq "");

open(I, "<$file") or die "Can not open file: $file\n";
open(O, ">$outFile") or die "Can not open file: $outFile\n";

my @len = ();

my $prevFastaSeqId = "";
my $fastaSeqId = "";
my $fastaSeq = "";

while(my $line = <I>) {
	chomp $line;
	if($line =~ /^>/) {
		$prevFastaSeqId = $fastaSeqId;
		$fastaSeqId = $line;
		if($fastaSeq ne "") {
			push(@len, length $fastaSeq);
			baseCount($fastaSeq);
		}
		$fastaSeq = "";
	}
	else {
		$fastaSeq .= $line;
	}
}
if($fastaSeq ne "") {
	$prevFastaSeqId = $fastaSeqId;
	push(@len, length $fastaSeq);
	baseCount($fastaSeq);
}

my $bases = sum(@len);

printf O "%-25s %0.2f %s\n", "(G + C)s", ($Gs+$Cs)/$bases*100, "%";

print "N50 Statisitcs file: $outFile\n";

exit;


sub baseCount {
	my $seq = $_[0];
	my $tAs += $seq =~ s/A/A/gi;
	my $tTs += $seq =~ s/T/T/gi;
	my $tGs += $seq =~ s/G/G/gi;
	my $tCs += $seq =~ s/C/C/gi;
	$Ns += (length $seq) - $tAs - $tTs - $tGs - $tCs;
	$As += $tAs;
	$Ts += $tTs;
	$Gs += $tGs;
	$Cs += $tCs;
}

sub prtHelp {
	print "\n$0 options:\n\n";
	print "### Input reads/sequences (FASTA) (Required)\n";
	print "  -i <Read/Sequence file>\n";
	print "    Read/Sequence in fasta format\n";
	print "\n";
	print "### Other options [Optional]\n";
	print "  -h | -help\n";
	print "    Prints this help\n";
	print "  -o | -outputFile <Output file name>\n";
	print "    Output will be stored in the given file\n";
	print "    default: By default, N50 statistics file will be stored where the input file is\n";
	print "\n";
}

sub prtError {
	my $msg = $_[0];
	print STDERR "+======================================================================+\n";
	printf STDERR "|%-70s|\n", "  Error:";
	printf STDERR "|%-70s|\n", "       $msg";
	print STDERR "+======================================================================+\n";
	prtUsage();
	exit;
}

sub prtUsage {
	print "\nUsage: perl $0 <options>\n";
	prtHelp();
}
