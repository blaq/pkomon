package PKOMon::Data::ResultSet::Rank;

use warnings;
use strict;

use base qw/DBIx::Class::ResultSet/;

use PKOMon::XML;

# Pull raw XML data into the database
sub slurp_xml {
	my ( $self, $date, $server, $xml_path ) = @_;

	my $rank_data = PKOMon::XML->from_xml($xml_path);

	foreach my $rank (@$rank_data) {
		my $new_record = $self->new( {
			date           => $date,
			server         => $server,
			character_name => $rank->{character_name},
			rank           => $rank->{rank},
			class          => $rank->{class},
			level          => $rank->{level},
		} );

		# Should probably check for errors here
		$new_record->insert;
	}
}

1;
