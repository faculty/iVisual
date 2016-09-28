#!/usr/bin/env perl
########################################################################
## This script is provided for users of QIIME. After getting rarefaction (the collated_alpha) from QIIME pipeline and getting the rarefaction data for plotting (, either from QIIME pipeline or from my script), you may use this script to convert the file format to make downstream plotting with my Rscript
## The input is the output of 'Convert_collatedAlpha2averageTable.SE.multiGroup.r'
## The output can be directly used for my plotting Rscript
## This step is after 'Convert_collatedAlpha2averageTable.SE.multiGroup.r'
########################################################################

use File::Basename;
die("Argument: average_table.txt\n") if (@ARGV != 1);
my $file = shift @ARGV;
my ($fn ,$dir, undef) = fileparse($file, qw/.txt/);

my @output;
my $header = "xaxis";
open FILE,"<$file";
my $metric_file = <FILE>;
chomp $metric_file;
if($metric_file =~ s/^# //){
	$metric_file =~ s/\.txt$//;
}else{
	die("Format wrong at line 1!\n");
}
my $catergory = <FILE>;
chomp $catergory;
if($catergory =~ s/^# //){
	$catergory =~ s/\&\&/\-/g;
}else{
	die("Format wrong at line 2!\n");
}
my $xaxis = <FILE>;
if($xaxis =~ s/^xaxis: //g){
	my @xaxis = split /\s+/, $xaxis;
	@output = @xaxis;
}else{
	die("Format wrong at line 3!\n");
}
my $xmax = <FILE>;
die("Format wrong at line 4!\n") if ($xmax !~ /^xmax: /);
while(chomp($line = <FILE>)){
	if($line =~ s/^>> //){
		$header .= "\t${line}.mean\t${line}.se";
	}elsif($line =~ s/^color //){
		# do nothing
	}elsif($line =~ s/^series\s//){
		my @means = split /\s+/, $line;
		foreach $i (0..$#means){
			$output[$i] .= "\t$means[$i]";
		}
	}elsif($line =~ s/^error\s//){
		my @ses = split /\s+/, $line;
		foreach $i (0..$#ses){
			$output[$i] .= "\t$ses[$i]";
		}
	}else{
		die("Format wrong!\n");
	}
}
close FILE;

my $output = $dir . $metric_file . ".${catergory}.R4mat.txt";
open OUTPUT,">$output";
print OUTPUT "$header\n";
foreach (@output){
	print OUTPUT "$_\n";
}
close OUTPUT;
print "Converted! Please plot by R!\n";
