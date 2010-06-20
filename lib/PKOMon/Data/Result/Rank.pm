package PKOMon::Data::Result::Rank;

use warnings;
use strict;

use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components( qw/InflateColumn::DateTime/ );
__PACKAGE__->table('rank');
__PACKAGE__->add_columns( qw/date server character_name rank class level/ );

1;
