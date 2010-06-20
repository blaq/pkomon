#!/usr/local/bin/perl
# Fetch current Top 100 data, save the XML, import it into the database and
# calculate the diffs.

use lib '/opt/pkomon/lib';

use warnings;
use strict;

use DateTime;
use LWP::Simple qw/getstore is_success/;

use PKOMon qw/diff/;
use PKOMon::Data;

my $today       = DateTime->today( time_zone => PKOMon::DEFAULT_TZ );
my $today_stamp = $today->ymd;
my $yesterday   = $today->clone->subtract( days => 1 );

my $crete_xml_file = PKOMon->config->data_directory . "/crete/$today_stamp.xml";
my $azov_xml_file  = PKOMon->config->data_directory . "/azov/$today_stamp.xml";

# No more than 5 attempts
foreach ( 1 .. 5 ) {
	last if is_success( getstore( PKOMon->config->crete_top100_url, $crete_xml_file ) );
}

foreach ( 1 .. 5 ) {
	last if is_success( getstore( PKOMon->config->azov_top100_url, $azov_xml_file ) );
}

my $schema = PKOMon::Data->connect(
	'dbi:mysql:pkomon;host=localhost',
	PKOMon->config->db_user,
	PKOMon->config->db_pass
);

$schema->resultset('Rank')->slurp_xml( $today_stamp, 'crete', $crete_xml_file );
$schema->resultset('Rank')->slurp_xml( $today_stamp, 'azov', $azov_xml_file );

foreach my $server ( qw/crete azov/ ) {
	my @yesterday = $schema->resultset('Rank')->search(
		{
			date   => $yesterday,
			server => $server
		},
	)->all;
	my @today = $schema->resultset('Rank')->search(
		{
			date   => $today,
			server => $server
		},
	)->all;

	foreach my $diff ( diff( \@yesterday, \@today ) ) {
		my $new_diff = $schema->resultset('Diff')->new( {
			date           => $today,
			server         => $server,
			character_name => $diff->[0],
			difference     => $diff->[1],
		} );

		$new_diff->insert;
	}
}

