package PKOMon::XML;

use warnings;
use strict;

use Carp;
use XML::Tiny;

# Parse an XML file into a Perl-ish data structure
sub from_xml {
	my ( $class, $xml_path ) = @_;

	my $data = [];
	if ( -r $xml_path ) {
		my $document = XML::Tiny::parsefile($xml_path);
		my $rank = 1;

		foreach my $character ( @{ $document->[0]->{content} } ) {
			my ( $char_name, $level, $class );

			# Don't assume the tags are always going to be in the same order.
			foreach my $tag ( @{ $character->{content} } ) {
				my $data = $tag->{content}->[0]->{content};

				$char_name = $data if $tag->{name} eq 'name';
				$level     = $data if $tag->{name} eq 'level';
				$class     = $data if $tag->{name} eq 'class';
			}

			push @$data, {
				character_name => $char_name,
				level          => $level,
				class          => $class,
				rank           => $rank,
			};

			$rank += 1;
		}
	}
	else {
		croak "File '$xml_path' is not readable";
	}

	return $data;
}

1;
