#!/usr/bin/env python
# Do a diff of PKO Top 100 data.
# DEPRECATED

import os
import os.path
import pprint
import re
import sys

from xml.etree.ElementTree import ElementTree

def parse_top100(filename):
    ''' Parse an XML file with Top 100 data in it. '''
    tree = ElementTree()
    tree.parse(filename)
    rankings = []
    chars = tree.getiterator('char')
    for index in xrange(len(chars)):
        char   = chars[index]
        player = char.find('name').text
        level  = char.find('level').text
        rank   = index + 1
        rankings.append( (rank, player, int(level)) )
    return rankings

def level_diff(previous, current):
    ''' Compare player levels from one day to another. '''

    # Map player names to levels
    previous_levels = dict((player, level) for rank, player, level in previous[1])
    current_levels  = dict((player, level) for rank, player, level in current[1])

    diff = []

    for player in set(list(previous_levels) + list(current_levels)):
        previous_level = None
        current_level  = None

        if player in previous_levels:
            previous_level = previous_levels[player]
        else:
            # If we don't know what level they were before, we assume, in the
            # worst case, that they were the same level as the lowest level in
            # the previous list.
            previous_level = min(previous_levels.values())

        if player in current_levels:
            current_level = current_levels[player]
        else:
            # If we don't know what level they are now, then their level has
            # dropped. We assume it has dropped to, in the worst case, the
            # lowest level in the current list.
            current_level = min(current_levels.values())

        diff.append( (player, current_level - previous_level) )

    return diff

def rank_diff(previous, current):
    ''' Compare player ranks from one day to another. '''
    previous_ranks = dict((player, rank) for rank, player, level in previous[1])
    current_ranks  = dict((player, rank) for rank, player, level in current[1])

    diff = []

    for player in set(list(previous_ranks) + list(current_ranks)):
        previous_rank = None
        current_rank  = None

        if player in previous_ranks:
            previous_rank = previous_ranks[player]
        else:
            # If we didn't have their rank in the previous list, worst case:
            # they were 1 outside the list.
            previous_rank = max(previous_ranks.values()) + 1

        if player in current_ranks:
            current_rank = current_ranks[player]
        else:
            # If we don't have their rank now, worst case: they got dropped to
            # just outside the list.
            current_rank = max(current_ranks.values()) + 1

        diff.append( (player, previous_rank - current_rank) )

    return diff

def pairs(items):
    ''' Returns pairs of items as a generator. '''
    num_items = len(items)
    for x in xrange(num_items):
        if x < num_items and x+1 < num_items:
            yield items[x], items[x+1]

def main(argv):
    if len(argv) == 0:
        print 'Usage: top100_diff.py <directory>'
        return 1

    if not os.path.isdir(argv[0]):
        print 'Error: directory "%s" does not exist' % argv[0]
        return 1
    
    data_by_day = []
    for root, dirs, files in os.walk(argv[0]):
        for filename in files:
            full_path = '%s/%s' % (root, filename)
            # yyyy-mm-dd.xml
            if not re.match(r'\d{4}-\d{2}-\d{2}.xml', filename):
                continue

            date = filename.split('.')[0]
            parsed_data = parse_top100(full_path)
            data_by_day.append( (date, parsed_data) )

    data_by_day.sort(key=lambda a: a[0])

    top100_level_diffs = []
    top100_rank_diffs  = []
    for previous, current in pairs(data_by_day):
        top100_level_diffs.append(
            level_diff(previous, current)
        )

        top100_rank_diffs.append(
            rank_diff(previous, current)
        )

    pprint.pprint(top100_level_diffs)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
