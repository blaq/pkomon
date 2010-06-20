#!/usr/bin/env perl
# Dump the rankings from a range of dates into an Excel spreadsheet.

use lib '/opt/pkomon/lib';

use warnings;
use strict;

use Carp;
use DateTime;
use Getopt::Long;
use Spreadsheet::WriteExcel;
use XML::Tiny;

use PKOMon;
use PKOMon::Data;

my ( $server, $start_date, $end_date, $outputfile );

GetOptions(
	'server=s'     => \$server,
	'start=s'      => \$start_date,
	'end=s'        => \$end_date,
	'outputfile=s' => \$outputfile
);

die "usage: $0 --server <server> --start <yyyy-mm-dd> --end <yyyy-mm-dd> --outputfile <outputfile>\n"
	unless $server and $start_date and $end_date and $outputfile;

my $schema = PKOMon::Data->connect(
	'dbi:mysql:pkomon;host=localhost',
	PKOMon->config->db_user,
	PKOMon->config->db_pass
);

my @rankings = $schema->resultset('Rank')->search(
	{
		server => $server,
		date   => {
			'>=' => $start_date,
			'<'  => $end_date,
		},
	},
	{ order_by => 'date, rank' }
);

my $spreadsheet = Spreadsheet::WriteExcel->new($outputfile);

# For the headers
my $bold_format = $spreadsheet->add_format;
$bold_format->set_bold;

# $VAR1 = {
#  '2010-05-01' => [ rank_object ]
# }
my $data_for;

# Fill our data structure
foreach my $ranking (@rankings) {
	$data_for->{ $ranking->date } ||= [];
	push @{ $data_for->{ $ranking->date } }, $ranking;
}

# Write that shit out
foreach my $date ( sort { $a cmp $b } keys %$data_for ) {
	my $worksheet = $spreadsheet->add_worksheet($date);

	$worksheet->write( 0, 0, 'Character', $bold_format );
	$worksheet->write( 0, 1, 'Level', $bold_format );

	foreach my $ranking ( @{ $data_for->{$date} } ) {
		$worksheet->write( $ranking->rank, 0, $ranking->character_name );
		$worksheet->write( $ranking->rank, 1, $ranking->level );
	}
}

$spreadsheet->close;

