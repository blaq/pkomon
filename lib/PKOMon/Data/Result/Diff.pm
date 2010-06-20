package PKOMon::Data::Result::Diff;

use warnings;
use strict;

use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components( qw/InflateColumn::DateTime/ );
__PACKAGE__->table('diff');
__PACKAGE__->add_columns( qw/date server character_name difference/ );

1;
