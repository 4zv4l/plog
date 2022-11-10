#!/bin/env perl

use DateTime;
use File::Basename;
use Getopt::Long;

# Check Arguments
$ARGV[0] || usage(0);
GetOptions (
    "h" => \$help,
    "o=s" => \$output,
    "D=s" => \$tree,
    "v" => \$verbose,
) or usage(1);
if($help) {usage(0)}

# Setup patterns, opening logfile and output dir (redirect stdout)
$ARGV[1] || usage(2);
if ($output) {open STDOUT, '>', $output or die "couldn't redirect stdout: $!\n"}
if($tree && ! -d "$tree") {mkdir $tree or die "couldn't create the dir: $!\n"}
my @patterns = @ARGV[1..$#ARGV];
open my $input, $ARGV[0] or die "couldn't open the file: $!\n";

# Main Loop
while($file = <$input>) {
    chomp $file;
    open my $tmp, $file or do {warn "$file: $!\n"; next};
    
    # setup tree root
    if($tree) {
        $dt = DateTime->now();
        $time = $dt->ymd.' '.$dt->hms;
        $out = basename($file, '.log');
        $out = $tree.'/'.$out."${time}_.log";
        open STDOUT, '>', $out or do {warn "$file: $!\n"; next};
    }

    # show match for each files
    if($verbose) {print "looking in $file\n"}
    print "$file: ";
    my $is_any_match = 0;
    while(<$tmp>) {
        foreach $pattern (@patterns) {
            do {
            print "\n" unless $is_any_match;
            print; $is_any_match = 1
            } if $_ =~ qr/$pattern/i;
        }
    }
    print "no pattern found...\n" unless $is_any_match;
    close $tmp;
}
close $input;

sub usage {
    my ($exit_code) = @_;
    print
"logParser [OPTIONS] [FILE] [PATTERN...]

OPTIONS:
   -h              show this help
   -o <file>       output file
   -D <dir>        fs tree with match
   -v              set verbose mode
FILE:
   file containing the logfilenames to analyse
PATTERN:
   can be a regex or a simple word to look for\n";
    exit $exit_code;
}
