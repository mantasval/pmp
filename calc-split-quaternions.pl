#!/usr/bin/perl
use strict;
use warnings;

# Define the quaternion stack
my @stack;
my $svn_info = `svn info`;

# Read input from file or STDIN
while (my $line = <>) {
    chomp $line;
    # Ignore comments and empty lines
    next if $line =~ /^#/ || $line =~ /^\s*$/;
    # Real number regex pattarn
    my $n_p = q([-+]?(?:\d+(\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?);
    # Match quaternion pattern
    if ($line =~ /($n_p)\s($n_p)\s($n_p)\s($n_p)/) {
        # Parse quaternion components
        my @quaternion = ($1, $3, $5, $7);
        # Push quaternion to stack
        push @stack, \@quaternion;
    } else {
        # Handle multiplication
        if ($line eq '*') {
            multiply();
        # Handle unknown symbols
        } else {
            die "ERROR: Unknown operation '$line' on line $.\n";
        }
    }
}

# Check if there's a result on the stack
if (scalar @stack != 1) {
    die "ERROR: Invalid number of values on the stack at the end of input.\n";
}

# Output the result
print($svn_info);
print "#@ 1 i J K\n";
print join(" ", @{$stack[0]}) . "\n";

sub multiply {
    if (scalar @stack < 2) {
        die "ERROR: Not enough values for multiplication on line $.\n";
    }
    my $quaternion1 = pop(@stack);
    my $quaternion0 = pop(@stack);
    my ($a, $b, $c, $d) = @{$quaternion0};
    my ($e, $f, $g, $h) = @{$quaternion1};
    my @result = (
        $a*$e - $b*$f + $c*$g + $d*$h,
        $a*$f + $b*$e + $c*$h - $d*$g,
        $a*$g + $b*$h + $c*$e - $d*$f,
        $a*$h - $b*$g + $c*$f + $d*$e
    );
    push @stack, \@result;
}
