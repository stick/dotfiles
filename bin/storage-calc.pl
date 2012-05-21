#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Pod::Usage;
use Getopt::Long qw(:config auto_help auto_version );

$main::VERSION = "1.0";

=head1 NAME

storage-calc.pl - a script

=head1 SYNOPSIS

  storage-calc.pl [options]

  Options:
    --help brief help message
    --man full documentation
    --gb calculate cost based on this number of Gigabytes
    --tb calculate cost based on this number of Terabytes
    --rate calculation rate ($/GB)

=head1 OPTIONS

=over

=item B<--help>

Print a brief help message and exits.

=item B<--man>

Prints the manual page and exits.

=item B<--gb>

Calculate cost based on number of Gigabytes.

=item B<--tb>

Calculate cost based on number of Gigabytes.

=item B<--rate>

Rate at which calculations are made $/GB

=back

=head1 DESCRIPTION

Quick calculation of storage costs.  Takes GB or TB (which are converted to GB).
Must specify the rate at which calculations are made (per GB).

=cut

my %opts;
GetOptions(\%opts, "tb=i", "gb=i", "rate=f" ) or pod2usage(2);
pod2usage(-exitstatus => 0, -verbose => 2) if $opts{'man'};

my $in = $opts{'tb'} or $opts{'gb'} or pod2usage(2);
my $calc_space = $opts{'gb'} || ($opts{'tb'} * 1024);
my $total_cost = $calc_space * $opts{'rate'};

if ($opts{'tb'}) {
  printf "%dG (%dT) @ \$%.2f = \$%.2f\n", $calc_space, $opts{'tb'}, $opts{'rate'}, $total_cost;
} else {
  printf "%dG @ \$%.2f = \$%.2f\n", $calc_space, $opts{'rate'}, $total_cost;
}


