package PKOMon;

use warnings;
use strict;

use base 'Exporter';
use vars qw/@EXPORT_OK/;

use List::Util qw/min/;
use PKOMon::Config;

@EXPORT_OK = qw/diff pairs/;

use constant HOME_DIRECTORY => '/opt/pkomon';
use constant CONFIG_FILE    => '/opt/pkomon/etc/pkomon.conf';
use constant DEFAULT_TZ     => 'Asia/Singapore';

# Singleton, of sorts...
my $config;

sub config { return $config }

sub import {
	my ($package) = @_;

	$config = PKOMon::Config->new( autoload_support => 1 );
	$config->read(CONFIG_FILE);

	# If this isn't here, the module won't export any functions.
	__PACKAGE__->export_to_level( 1, @_ );
}

# Do a level diff on 2 sets of records.
# Parameters should be arrays of PKOMon::Data::Result::Rank objects.
sub diff {
	my ( $previous, $current ) = @_;

	return undef unless scalar @$previous == scalar @$current;

	my %previous_levels = map {
		$_->character_name => $_->level
	} @$previous;

	my %current_levels = map {
		$_->character_name => $_->level
	} @$current;

	my @characters = keys(%previous_levels), keys(%current_levels);

	{
		my %dedupe;
		@dedupe{ @characters } = ();
		@characters = keys %dedupe;
	}

	my @diff;

	foreach my $player (@characters) {
		my ( $previous_level, $current_level );

		if ( exists $previous_levels{$player} ) {
			$previous_level = $previous_levels{$player};
		}
		else {
			# If we don't know what level they were before, we assume, in the
			# worst case, that they were the same level as the lowest level in
			# the previous list.
			$previous_level = min( values %previous_levels );
		}

		if ( exists $current_levels{$player} ) {
			$current_level = $current_levels{$player};
		}
		else {
			# If we don't know what level they are now, then their level has
			# dropped. We assume it has dropped to, in the worst case, the
			# lowest level in the current list.
			$current_level = min( values %current_levels );
		}

		push @diff, [ $player => $current_level - $previous_level ];
	}

	return @diff;
}

# Return pairs of items as a list.
sub pairs {
	my @items = @_;
	my $num_items = scalar @items;
	my @pairs;

	for my $x ( 0 .. $num_items ) {
		if ( $x < $num_items && $x+1 < $num_items ) {
			push @pairs, [ $items[$x], $items[$x+1] ];
		}
	}

	return @pairs;
}

1;
