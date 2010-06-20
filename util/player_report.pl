#!/usr/bin/env perl
# Dump rankings of a player into an Excel spreadsheet.

use lib '/opt/pkomon/lib';

use warnings;
use strict;

use Getopt::Long;
use Spreadsheet::WriteExcel;

use PKOMon;
use PKOMon::Data;

my ( $player, $outputfile );

GetOptions(
	'player=s'     => \$player,
	'outputfile=s' => \$outputfile,
);

die "usage: $0 --player <player name> --outputfile <file.xls>\n"
	unless $player;

$outputfile ||= "$player.xls";

my $schema = PKOMon::Data->connect(
	'dbi:mysql:pkomon;host=localhost',
	PKOMon->config->db_user,
	PKOMon->config->db_pass
);

my @daily_results = $schema->resultset('Rank')->search(
	{ character_name => $player },
	{ order_by => 'date' }
);

my $spreadsheet = Spreadsheet::WriteExcel->new($outputfile);
my $worksheet   = $spreadsheet->add_worksheet($player);
my $format      = $spreadsheet->add_format;
$format->set_bold;

$worksheet->write( 0, 0, 'Date',  $format );
$worksheet->write( 0, 1, 'Level', $format );

my $row = 1;
foreach my $result (@daily_results) {
	$worksheet->write( $row, 0, $result->date );
	$worksheet->write( $row, 1, $result->level );

	$row += 1;
}

$spreadsheet->close;

