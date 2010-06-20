#!/usr/bin/env perl
# Import raw XML data into the database. Imports to both the 'rank' and
# 'diff' tables.

use lib '/opt/pkomon/lib';

use warnings;
use strict;

use PKOMon qw/pairs diff/;
use PKOMon::Data;

die "usage: $0 <file.xml> [file2.xml] .. [fileN.xml]\n" unless @ARGV > 0;

my $schema = PKOMon::Data->connect(
	'dbi:mysql:pkomon;host=localhost',
	PKOMon->config->db_user,
	PKOMon->config->db_pass
);

my @dates;
my @servers;

foreach my $file (@ARGV) {
	print "Processing $file ...\n";

	my ( $server, $date ) = $file =~ m{ / ([^/]+) / ([0-9\-]+) \.xml \Z }xms;

	next unless $server and $date;

	push @dates, $date;
	push @servers, $server;

	$schema->resultset('Rank')->slurp_xml( $date, $server, $file );
}

{
	my %dedupe;
	@dedupe{ @dates } = ();
	@dates = sort { $a cmp $b } keys %dedupe;

	%dedupe = ();
	@dedupe{ @servers } = ();
	@servers = keys %dedupe;
}

foreach my $server (@servers) {
	print "Doing diffs for $server ...\n";
	foreach my $pair ( pairs @dates ) {
		my ( $first_date, $second_date ) = @$pair;

		print "... $first_date <=> $second_date\n";

		my @first = $schema->resultset('Rank')->search(
			{
				date   => $first_date,
				server => $server
			},
		)->all;
		my @second = $schema->resultset('Rank')->search(
			{
				date   => $second_date,
				server => $server
			},
		)->all;

		next if scalar @first == 0 || scalar @second == 0;

		foreach my $diff ( diff( \@first, \@second ) ) {
			my $new_diff = $schema->resultset('Diff')->new( {
				date           => $second_date,
				server         => $server,
				character_name => $diff->[0],
				difference     => $diff->[1],
			} );

			$new_diff->insert;
		}
	}
}
