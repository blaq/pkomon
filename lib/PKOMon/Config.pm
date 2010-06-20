package PKOMon::Config;

use warnings;
use strict;
use vars qw/$AUTOLOAD/;

use base 'Config::ApacheFormat';

sub AUTOLOAD {
	 my ( $self, $arg ) = @_;
	 my ($item) = $AUTOLOAD =~ m{ .* :: (.*) \Z }xms;

	 return undef unless $item;

	 if ($arg) {
		my $block = $self->block($item);
		$block->get($arg);
	 }
	 else {
		$self->get($item);
	 }
}

1;

