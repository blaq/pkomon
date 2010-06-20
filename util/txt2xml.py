#!/usr/bin/env python
# Convert the .txt copy/paste dumps of the Top 100 to formatted XML.
# Very hacky. No XML modules used... But the output is correct and it's a
# one-off, so I don't care.

import os
import re

def txt2xml(filename):
    date = filename.split('.')[0]
    with open(filename, 'r') as fin:
        with open('%s.xml' % date, 'wb') as fout:
            fout.write('<?xml version="1.0" encoding="utf-8"?>\n')
            fout.write('<PKRanking>\n')
            for line in [x.strip() for x in fin.readlines()]:
                _, name, class_number, level = re.split(r'\s+', line)
                fout.write('<char>\n')
                fout.write('\t<name><![CDATA[%s]]></name>\n' % name)
                fout.write('\t<level>%s</level>\n' % level)
                fout.write('\t<class><![CDATA[%s]]></class>\n' % class_number)
                fout.write('</char>\n')
            fout.write('</PKRanking>\n')

if __name__ == '__main__':
    for root, dirs, files in os.walk('.'):
        for filename in files:
            if not re.match(r'\d{4}-\d{2}-\d{2}.txt', filename):
                continue

            txt2xml(filename)
