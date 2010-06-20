#!/usr/local/bin/python
# Fetch current Top 100 lists and output the XML
# DEPRECATED for Perl/DBIC equivalent

from datetime import date
import urllib2

CRETE_TOP100_URL = r'http://www.piratekingonline.com/uploadfile/rankXML/Crete.xml'
AZOV_TOP100_URL  = r'http://www.piratekingonline.com/uploadfile/rankXML/Azov.xml'
OUTPUT_DIRECTORY = r'/opt/pkomon_data'

if __name__ == '__main__':
    datestamp = date.today().isoformat()

    crete_outputfile = '%s/crete/%s.xml' % (OUTPUT_DIRECTORY, datestamp)
    with open(crete_outputfile, 'wb') as fh:
        fh.write(urllib2.urlopen(CRETE_TOP100_URL).read())

    azov_outputfile = '%s/azov/%s.xml' % (OUTPUT_DIRECTORY, datestamp)
    with open(azov_outputfile, 'wb') as fh:
        fh.write(urllib2.urlopen(AZOV_TOP100_URL).read())
