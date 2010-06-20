#!/usr/bin/env perl
# Web front-end.

use lib '/opt/pkomon/lib';

use DateTime;
use Mojolicious::Lite;

use PKOMon;
use PKOMon::Data;

my $schema = PKOMon::Data->connect(
	'dbi:mysql:pkomon;host=localhost',
	PKOMon->config->db_user,
	PKOMon->config->db_pass
);

get '/' => sub {
	my ($self) = @_;
	$self->redirect_to('rank');
} => 'index';

get '/rank/:day' => [ day => qr/(\d{4}-\d{2}-\d{2})/ ] => { day => 'today' } => sub {
	my ($self) = @_;
	my $day = $self->stash('day');

	if ( $day eq 'today' ) {
		$day = DateTime->today( time_zone => PKOMon::DEFAULT_TZ )->ymd;
	}

	my $rankings = $schema->storage->dbh->selectall_arrayref(
		q{
			SELECT     r.rank, r.server, r.character_name, r.level, d.difference
			FROM       rank r
			LEFT JOIN  diff d
			USING     (server, character_name, date)
			WHERE      r.date = ?
			GROUP BY   r.server, r.character_name
			ORDER BY   r.rank
		},
		{ Slice => {} },
		$day
	);

	my %rank_for_server;
	foreach my $rank (@$rankings) {
		$rank_for_server{ $rank->{server} } ||= [];

		push @{ $rank_for_server{ $rank->{server} } }, $rank;
	}

	$self->render(
		template        => 'rank',
		date            => $day,
		rank_for_server => \%rank_for_server,
	);
} => 'rank';

get '/character/:server/:char' => sub {
	my ($self) = @_;
	my $server = $self->stash('server');
	my $char   = $self->stash('char');

	my @char_rankings = $schema->resultset('Rank')->search(
		{
			server         => $server,
			character_name => $char,
		},
		{ order_by => 'date' }
	);

	$self->render(
		template  => 'character',
		server    => $server,
		character => $char,
		rankings  => \@char_rankings,
	);
} => 'character';

shagadelic;

__DATA__

@@ layouts/pkomon.html.ep
<html>
	<head>
		<title>PKO Monitor</title>

		<style type="text/css">
			table {
				-moz-border-radius: 5px;
				border: 1px solid #000;
				border-collapse: collapse;
				width: 100%;
			}

			h1 { text-align: center; }

			div.rank_list { width: 40%; }
			div.left  { float: left; }
			div.right { float: right; }

			th {
				background-color: #c0c0c0;
				text-align: left;
			}
			tr:hover {
				background-color: #f5f5f5;
			}

			td.changed {
				background-color: #c0c0c0;
			}

			a, a:visited {
				text-decoration: none;
				color: #336699;
			}
			a:hover {
				text-decoration: underline;
				color: #6699ff;
			}
		</style>
	</head>

	<body>
<%= content %>
	</body>
</html>

@@ rank.html.ep
<% my $server_table = {%>
	<% my ($ranks, $server, $align) = @_; %>

	<div class="rank_list <%= $align %>">
	<h2><%= ucfirst $server %></h2>
	<table>
		<tr>
			<th>Rank</th>
			<th>Player</th>
			<th>Level</th>
			<th>Difference</th>
		</tr>
		<% foreach my $rank (@$ranks) { %>
		<tr>
			<td><%= $rank->{rank} %></td>
			<td>
				<a href="/character/<%= $server %>/<%= $rank->{character_name} %>"><%= $rank->{character_name} %></a>
			</td>
			<td><%= $rank->{level} %></td>
			<td class="<%= $rank->{difference} > 0 ? 'changed' : '' %>"><%= $rank->{difference} %></td>
		</tr>
		<% } %>
	</table>
	</div>
<%}%>
% layout 'pkomon';
<h1><%= $date %></h1>
<%== $server_table->( $rank_for_server->{azov}, 'azov', 'left' ) %>
<%== $server_table->( $rank_for_server->{crete}, 'crete', 'right' ) %>

@@ character.html.ep
% layout 'pkomon';
<h1><%= $character %></h1>
<table>
	<tr>
		<th>Date</th>
		<th>Level</th>
		<th>Rank</th>
	</tr>
	<% foreach my $ranking (@$rankings) { %>
		<tr>
			<td>
				<a href="/rank/<%= $ranking->date %>"><%= $ranking->date %></a>
			</td>
			<td><%= $ranking->level %></td>
			<td><%= $ranking->rank %></td>
		</tr>
	<% } %>
</table>
